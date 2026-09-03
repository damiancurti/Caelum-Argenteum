"""Migra la carpeta de texturas de la mansión al conjunto canónico v2.

El parche 4.30.0f incorpora los 58 PNG nuevos, pero una extracción encima de
un árbol de desarrollo anterior no puede borrar los 48 recursos retirados.
Este ayudante los mueve a ``build/mansion_pre_4_30_0f_backup`` para que la
migración sea reversible. No elimina archivos desconocidos del autor.
"""

from __future__ import annotations

import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_TARGET = ROOT / "src/graphics/caelum/textures/mansion"
DEFAULT_BACKUP = ROOT / "build/mansion_pre_4_30_0f_backup"

CANONICAL_FAMILIES = {
    "CMBS": 5,
    "CMCR": 3,
    "CMDR": 5,
    "CMDT": 5,
    "CMEX": 5,
    "CMGR": 3,
    "CMGT": 2,
    "CMIN": 5,
    "CMPW": 2,
    "CMRL": 4,
    "CMSP": 5,
    "CMST": 5,
    "CMTB": 4,
    "CMWD": 5,
}
CANONICAL = {
    f"{prefix}{index:02d}.png"
    for prefix, count in CANONICAL_FAMILIES.items()
    for index in range(1, count + 1)
}

OBSOLETE = {
    *(f"CMCL{index:02d}.png" for index in range(1, 7)),
    *(f"CMCR{index:02d}.png" for index in range(4, 7)),
    *(f"CMDM{index:02d}.png" for index in range(1, 8)),
    "CMEX06.png",
    *(f"CMFD{index:02d}.png" for index in range(1, 5)),
    "CMGR01A.png",
    "CMGR01B.png",
    "CMGR01C.png",
    "CMGR04.png",
    "CMPC01.png",
    "CMPF01.png",
    "CMPF02.png",
    *(f"CMRF{index:02d}.png" for index in range(1, 5)),
    *(f"CMST{index:02d}.png" for index in range(6, 9)),
    *(f"CMTR{index:02d}.png" for index in range(1, 7)),
    *(f"CMWA{index:02d}.png" for index in range(1, 4)),
    *(f"CMWD{index:02d}.png" for index in range(6, 9)),
    "CMWV01.png",
}


def migrate(target: Path, backup: Path) -> int:
    if not target.is_dir():
        raise FileNotFoundError(f"No existe la carpeta de mansión: {target}")

    present = {path.name for path in target.glob("*.png")}
    missing = sorted(CANONICAL - present)
    if missing:
        raise ValueError(
            "Faltan PNG canónicos v2; extraiga primero el parche: "
            + ", ".join(missing)
        )

    retired = sorted(present & OBSOLETE)
    if retired:
        backup.mkdir(parents=True, exist_ok=True)
    for name in retired:
        source = target / name
        destination = backup / name
        if destination.exists():
            raise FileExistsError(
                f"El respaldo ya contiene {destination}; no se sobrescribió nada"
            )
        source.rename(destination)

    remaining = {path.name for path in target.glob("*.png")}
    if remaining & OBSOLETE:
        raise ValueError("Persisten texturas obsoletas después de la migración")

    unknown = sorted(remaining - CANONICAL)
    print(f"Texturas canónicas v2 presentes: {len(CANONICAL)}")
    print(f"Texturas anteriores movidas al respaldo: {len(retired)}")
    if unknown:
        print("Archivos adicionales conservados: " + ", ".join(unknown))
    return len(retired)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "target",
        nargs="?",
        type=Path,
        default=DEFAULT_TARGET,
        help="carpeta mansion del proyecto",
    )
    parser.add_argument(
        "--backup",
        type=Path,
        default=DEFAULT_BACKUP,
        help="carpeta recuperable para los PNG retirados",
    )
    arguments = parser.parse_args()
    migrate(arguments.target.resolve(), arguments.backup.resolve())


if __name__ == "__main__":
    main()
