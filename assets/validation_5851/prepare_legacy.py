"""Build original-runtime and upgrade fixtures without changing saved map geometry."""
from pathlib import Path
import hashlib
import shutil
import zipfile

R = Path(__file__).resolve().parents[2]
H = Path(__file__).resolve().parent
W = R / "build/issue415-rounds"
BASE = R.parent / "issue502-physical-work/build/issue502-adapters/final50b/caelum_argenteum_dev.pk3"
assert hashlib.sha256(BASE.read_bytes()).hexdigest() == "b713cdf358963eb1b4f0b8ee0aa4093d82a9c2b755c1da86e8b629dd1a04396d"
old = W / "original50/caelum_argenteum_dev.pk3"
old.parent.mkdir(parents=True, exist_ok=True)
if old.exists():
    assert old.read_bytes() == BASE.read_bytes()
else:
    shutil.copyfile(BASE, old)

source = (H / "legacy.zs").read_text(encoding="utf-8")
upgrade = '''Check(Port.AbsentBattle==null && !Port.UnvisitedCalendarPending,"legacy fields default to no summary and no first-visit replay");
        CaelumAbsentBattles.FirstArrival(Port);
        Check(Port.AbsentBattle==null && !Port.SiegeStarted,"first-arrival hook is idempotent for an observed legacy city");
        Port.ChangeStatNum(Thinker.STAT_DEFAULT);
        Start=CaelumHouseAwayWork.Civil(user);CaelumAbsentBattles.Capture(user);
        Port.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        Check(Port.AbsentBattle!=null && Port.AbsentBattle.Stamp==Start && Port.AbsentBattle.Rounds==0,"first departure starts tracking at the actual update date without backfill");
        if(Port.AbsentBattle==null)return;
        Check(Port.AbsentBattle.ScheduleWaiting && Port.AbsentBattle.ScheduledCivil==Start,"overdue existing event remains due at tracking start");
        Check(Resident.health==Life && Possession.Owner==Resident && Possession.Amount==17,"capture preserves observed resources");'''
resume = '''Check(Port.AbsentBattle!=null && Port.AbsentBattle.Stamp==Start && Port.AbsentBattle.Rounds==0,"upgraded save retains the migration boundary and no fabricated rounds");
        CaelumAbsentBattles.FirstArrival(Port);
        Check(Port.AbsentBattle.Stamp==Start && !Port.SiegeStarted,"repeat load hook does not restart history");'''
for label, text in [("original", source), ("upgrade", source.replace("// CURRENT_UPGRADE", upgrade).replace("// CURRENT_RESUME", resume))]:
    with zipfile.ZipFile(W / f"legacy-{label}.pk3", "w", zipfile.ZIP_STORED) as archive:
        for name, data in sorted({"ZSCRIPT": 'version "4.14"\n#include "legacy.zs"\n', "legacy.zs": text,
                                 "MAPINFO": 'GameInfo {AddEventHandlers="CA415LegacyChecks"}\n'}.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data.encode("utf-8"))
commands = {
    "legacyseed": "wait 105; netevent ca415legacy_seed; save original50-city; wait 10; quit",
    "legacyupgrade": "wait 1; netevent ca415legacy_upgrade; save upgraded51-city; wait 10; quit",
    "legacyresume": "wait 1; netevent ca415legacy_resume; wait 1; quit",
    "legacyrollback": "wait 1; netevent ca415legacy_rollback; wait 1; quit",
}
for name, text in commands.items():
    (W / f"{name}.cfg").write_text(text + "\n", encoding="utf-8")
print("Prepared byte-verified 5.8.50 seed, upgrade, reload and original-save rollback")
