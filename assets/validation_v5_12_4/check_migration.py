"""Verify the exact migration diff and refusal paths against a real native save."""
import io, json, sys, zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]))
from migrate_arena_save import migrate, MANIFEST, write_copy

original=Path(sys.argv[1]).read_bytes();converted=migrate(original)
assert migrate(converted)==converted
before=zipfile.ZipFile(io.BytesIO(original));after=zipfile.ZipFile(io.BytesIO(converted))
for name in before.namelist():
    a,b=before.read(name),after.read(name)
    if a==b:continue
    assert name.endswith('.map.json'),name
    a,b=json.loads(a),json.loads(b)
    a['teamdamage']=1.0
    assert a==b,name
assert set(after.namelist())-set(before.namelist())=={MANIFEST}
assert Path(sys.argv[1]).read_bytes()==original
try:migrate(b'corrupt native archive')
except zipfile.BadZipFile:pass
else:raise AssertionError('Corrupt archive accepted')
for version in (1,9999):
    target=io.BytesIO()
    with zipfile.ZipFile(target,'w') as z:
        z.writestr('info.json',json.dumps({'Engine':'GZDOOM','Save Version':version}))
    try:migrate(target.getvalue())
    except ValueError:pass
    else:raise AssertionError('Unsupported revision accepted')
try:write_copy(Path(sys.argv[1]),Path(sys.argv[1]))
except FileExistsError:pass
else:raise AssertionError('Original archive overwritten')
assert Path(sys.argv[1]).read_bytes()==original
print('PASS scalar-only diff, idempotence, corrupt/future refusal, exclusive copy, original preservation')
