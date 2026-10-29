"""Derive the approved transport catalogue; deterministic, no network access."""
from pathlib import Path
import argparse
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/transport/network.json"


def calculate(data):
    geometry = data["geographic_model"]

    def path(points):
        total = 0.0
        for first, second in zip(points, points[1:]):
            lat1, lon1 = map(math.radians, first)
            lat2, lon2 = map(math.radians, second)
            a = math.sin((lat2-lat1)/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin((lon2-lon1)/2)**2
            total += 2*geometry["earth_radius_km"]*math.asin(math.sqrt(min(1, a)))
        return total

    rail = data["rail"]
    total_rail = rail["buenos_aires_mar_del_plata_miles"]*rail["km_per_mile"]
    distances = {
        "road": [path(geometry["road_buenos_aires_barracas"]), path(geometry["road_barracas_mar_del_plata"])],
        "sea": [path(geometry["sea_buenos_aires_barracas"]), path(geometry["sea_barracas_mar_del_plata"])],
        "rail": [rail["buenos_aires_barracas_km"], total_rail-rail["buenos_aires_barracas_km"]],
    }
    return {"segment_km": {key: [round(x, 6) for x in values] for key, values in distances.items()},
            "train_running_kmh": round(total_rail/(rail["end_to_end_hours"]-rail["barracas_stop_minutes"]/60), 9),
            "ship_kmh": data["ship"]["knots"]*data["ship"]["km_per_nautical_mile"],
            "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest()}


def render(data, derived):
    lines = ["// Generado desde assets/transport/network.json; no editar a mano.",
             "// Fuentes, limites y estimaciones estan registrados en el manifiesto.",
             "class CaelumTransportData : Object", "{",
             "    const REVISION = 1;", "    const MODE_HORSE = 5;", "    const MODE_TRAIN = 6;",
             f"    const LAND_MOVING_HOURS = {data['land']['moving_hours_per_day']};",
             f"    const LAND_SLEEP_HOURS = {data['land']['sleep_hours_per_day']};"]
    for method, member in [("Origin", "origin"), ("Destination", "destination")]:
        lines += [f"    static clearscope int {method}(int route)", "    {", "        switch(route)", "        {"]
        lines += [f"            case {row['id']}: return {row[member]};" for row in data["routes"]]
        lines += ["        }", "        return -1;", "    }"]
    for method, member, kind, fallback in [("Location", "location_id", "int", "0"), ("Map", "map", "String", '""'), ("NameKey", "key", "String", '"CA_WORLD_UNREGISTERED"')]:
        values = ",".join(json.dumps(row[member]) for row in data["nodes"])
        lines += [f"    static clearscope {kind} {method}(int node)", "    {",
                  f"        {kind} values[] = {{{values}}};",
                  f"        return node>=0 && node<3 ? values[node] : {fallback};", "    }"]
    lines += ["    static clearscope double SegmentKm(int segment,int mode)", "    {",
              "        if(segment<0 || segment>1)return 0;"]
    for key, condition in [("road", "mode==3 || mode==MODE_HORSE"), ("sea", "mode==4"), ("rail", "mode==MODE_TRAIN")]:
        a, b = derived["segment_km"][key]
        lines.append(f"        if({condition})return segment==0?{a:.6f}:{b:.6f};")
    lines += ["        return 0;", "    }"]
    methods = {
        "SpeedKmh": {3: data["land"]["cart_kmh"], 4: derived["ship_kmh"], 5: data["land"]["horse_kmh"], 6: derived["train_running_kmh"]},
        "FareRate": {index: data["fares_copper_per_km_per_traveler"][name] for index, name in [(3, "cart"), (4, "ship"), (5, "horse"), (6, "train")]},
        "StopHours": {4: data["ship"]["barracas_stop_minutes"]/60, 6: data["rail"]["barracas_stop_minutes"]/60},
        "PeriodHours": {4: 24*data["ship"]["period_days"], 6: 24*data["rail"]["period_days"]},
        "TerminalDepartureHours": {4: data["ship"]["departure_minute"]/60, 6: data["rail"]["departure_minute"]/60},
    }
    for method, table in methods.items():
        lines += [f"    static clearscope double {method}(int mode)", "    {"]
        lines += [f"        if(mode=={key})return {value:.9f};" for key, value in table.items()]
        lines += ["        return 0;", "    }"]
    lines += ["}", ""]
    return "\n".join(lines).encode("utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    derived = calculate(data)
    outputs = {
        ROOT / "src/caelum/data/CaelumTransportData.zs": render(data, derived),
        ROOT / "assets/transport/derived.json": (json.dumps(derived, indent=2) + "\n").encode("utf-8"),
    }
    for path, payload in outputs.items():
        if args.check:
            if not path.exists() or path.read_bytes() != payload:
                raise SystemExit(f"Stale generated transport file: {path}")
        else:
            path.write_bytes(payload)
    print(json.dumps(derived))


if __name__ == "__main__":
    main()
