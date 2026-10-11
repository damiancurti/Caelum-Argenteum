"""Read-only #164 evidence checks, including unchanged native conversation slots."""
from pathlib import Path
import hashlib,json,re,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue164'
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 old=subprocess.check_output(['git','show','6cae68bd:src/CAPALOMO'],cwd=ROOT).decode('utf-8')
 new=(ROOT/'src/CAPALOMO').read_text(encoding='utf-8')
 names=lambda s:re.findall(r'pagename\s*=\s*"([^"]+)"',s)
 checks={'conversation_page_slots_unchanged':names(old)==names(new),'no_tool_return_choice': 'giveitem = "CaelumM00ReturnRepairSwordAction"' not in new}
 with zipfile.ZipFile(OUT/'production.pk3') as z:
  members={n:z.read(n) for n in z.namelist()}
 checks['runtime_members_match_source']=all(members[p.relative_to(ROOT/'src').as_posix()]==p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file())
 result={'checks':checks,'conversation_pages':len(names(new)),'production_sha256':digest(OUT/'production.pk3'),'passed':all(checks.values())}
 (OUT/'static.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(result,indent=2))
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
