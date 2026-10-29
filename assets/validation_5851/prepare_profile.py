"""Add diagnostic timers only to a private package; gameplay sources stay intact."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / "build/issue415-rounds"
with zipfile.ZipFile(WORK / "probe/caelum_argenteum_dev.pk3") as archive:
    members = {name: archive.read(name) for name in archive.namelist()}
name = "caelum/world/CaelumAbsentBattle.zs"
source = members[name].decode("utf-8").replace("\r\n", "\n")


def replace(old, new):
    global source
    assert source.count(old) == 1, old
    source = source.replace(old, new)


replace("class CaelumAbsentBattle : Object play\n{",
        "class CaelumAbsentBattle : Object play\n{\n    double ProfileThermal,ProfileContamination,ProfileOther;")
replace("void Physiology(double worldEnd,double activeSeconds)\n    {",
        "void Physiology(double worldEnd,double activeSeconds)\n    {\n        double profileStart=MSTimeF(),profileT=0,profileC=0;")
replace("ThermalStep(Max(0,worldEnd-absent.Stamp),activeSeconds,absent);",
        "double pt=MSTimeF();ThermalStep(Max(0,worldEnd-absent.Stamp),activeSeconds,absent);profileT=MSTimeF()-pt;Battle.ProfileThermal+=profileT;")
replace("absent.Life=Body.health;absent.SyncTo(Body,worldEnd);Body.health=absent.Life;",
        "double pc=MSTimeF();absent.Life=Body.health;absent.SyncTo(Body,worldEnd);Body.health=absent.Life;profileC=MSTimeF()-pc;Battle.ProfileContamination+=profileC;")
replace("CaelumDemonService.UpdatePotions(Body);",
        "CaelumDemonService.UpdatePotions(Body);Battle.ProfileOther+=MSTimeF()-profileStart-profileT-profileC;")
replace("void FinishRestore()\n    {",
        'void FinishRestore()\n    {\n        Console.Printf("CA415P TIMING thermal_ms=%.6f contamination_ms=%.6f other_ms=%.6f",ProfileThermal,ProfileContamination,ProfileOther);')
members[name] = source.encode("utf-8")
target = WORK / "profile/caelum_argenteum_dev.pk3"
target.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(target, "w", zipfile.ZIP_STORED) as archive:
    for key, value in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(key, (2000, 1, 1, 0, 0, 0)), value)
print("Prepared diagnostic timers; no production source mutation")
