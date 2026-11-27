"""Match historical source digests across Git text checkouts."""
import hashlib


def matches_source_digest(path, expected):
    data = path.read_bytes()
    if hashlib.sha256(data).hexdigest() == expected:
        return True
    if path.suffix.lower() not in {'.json', '.obj', '.py', '.textures', '.txt', '.zs'} or b'\0' in data:
        return False
    lf = data.replace(b'\r\n', b'\n')
    return any(hashlib.sha256(candidate).hexdigest() == expected
               for candidate in (lf, lf.replace(b'\n', b'\r\n')) if candidate != data)
