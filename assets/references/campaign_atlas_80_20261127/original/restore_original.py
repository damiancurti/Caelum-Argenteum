"""Reassemble the original atlas ZIP from the ten files beside this script."""
from hashlib import sha256
from pathlib import Path
from tempfile import NamedTemporaryFile


archive = 'Caelum_mapas_y_texturas.zip'
expected = '23153b292a6ba6ac3e75f7e1d1b252e42b8eb5fe6513a4261f32f9821993aa29'
folder = Path(__file__).resolve().parent
output = folder / archive
if output.exists():
    if sha256(output.read_bytes()).hexdigest() == expected:
        print(f'Archivo verificado: {output}')
        raise SystemExit(0)
    raise SystemExit(f'Ya existe otro archivo con ese nombre: {output}')

with NamedTemporaryFile(dir=folder, delete=False) as temporary:
    temporary_path = Path(temporary.name)
try:
    checksum = sha256()
    with temporary_path.open('wb') as joined:
        for number in range(1, 11):
            part = folder / f'{archive}.{number:03d}'
            data = part.read_bytes()
            joined.write(data)
            checksum.update(data)
    if checksum.hexdigest() != expected:
        raise SystemExit('La suma SHA-256 no coincide. Volvé a descargar las partes.')
    temporary_path.replace(output)
    print(f'Archivo verificado: {output}')
finally:
    temporary_path.unlink(missing_ok=True)
