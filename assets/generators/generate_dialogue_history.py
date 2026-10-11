"""Emit the reviewed informational-reply catalogue; preserve stable text keys."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def generate():
    data = json.loads((ROOT / 'assets/dialogue_history.json').read_text(encoding='utf-8'))
    rows = data['entries']
    code = '// Generado desde assets/dialogue_history.json; no editar a mano.\n'
    code += 'class CaelumDialogueHistoryData : Object\n{\n'
    code += f'    const REVISION = {data["revision"]};\n    const COUNT = {len(rows)};\n'
    for field in ('source', 'reply', 'answer'):
        code += f'    static String {field.title()}(int id)\n    {{\n        switch(id)\n        {{\n'
        for i, row in enumerate(rows):
            code += f'            case {i}: return "{row[field]}";\n'
        code += '        }\n        return "";\n    }\n'
    code += '''    static int Find(String source, String reply)
    {
        for(int i=0;i<COUNT;i++) if(Source(i)==source && Reply(i)==reply)return i;
        return -1;
    }
    static String Key(int id) { return Source(id).."|"..Reply(id); }
}
'''
    (ROOT / 'src/caelum/dialogue/CaelumDialogueHistoryData.zs').write_text(code, encoding='utf-8', newline='\n')


if __name__ == '__main__':
    generate()
