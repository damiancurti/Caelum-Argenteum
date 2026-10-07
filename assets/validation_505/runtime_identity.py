"""Compare runtime content independently of ZIP metadata and text line endings."""
import hashlib

def canonical_bytes(data):
    if b'\0' not in data:
        try:data.decode('utf-8')
        except UnicodeDecodeError:pass
        else:return data.replace(b'\r\n',b'\n')
    return data

def tree_hash(members,canonical=False):
    digest=hashlib.sha256()
    for name,data in sorted(members.items()):
        if canonical:data=canonical_bytes(data)
        digest.update(name.encode()+b'\0'+hashlib.sha256(data).digest())
    return digest.hexdigest()
