from pathlib import Path
h=Path(__file__).resolve().parent
root=Path(__file__).resolve().parents[2]
original=root/'assets/validation_v5_17_107/run_wardrobe857.py'
s=original.read_text(encoding='utf-8');fixture=(h/'hand_cache861.zs').read_text(encoding='utf-8')
s=s.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture))
s=s.replace("'issue':857", "'issue':861")
s=s.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Actual native clothing/armor hand selector candidate; diagnostic-only lookup counters, five1000-call warm batches; elapsed time includes instrumentation and does not establish production frame performance.')
exec(compile(s,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
