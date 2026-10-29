"""Generate the authorized additive contact-area density catalogue (#502)."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads((Path(__file__).with_name('contamination_physical.json')).read_text(encoding='utf-8'))
lines = [
    '// Generado por generate_contamination_physical.py; referencias en su JSON.',
    'class CaelumPhysicalSurfaceData : Object play',
    '{',
    '    static double FoodDensity(int kind)',
    '    {',
    '        static const double density[]={'+','.join(str(x) for x in DATA['food_density_kg_m3'])+'};',
    '        return kind>=0 && kind<'+str(len(DATA['food_density_kg_m3']))+'?density[kind]:0;',
    '    }',
    '    static double MaterialDensity(int kind,int tier)',
    '    {',
    '        if(CaelumStackSurfaceData.AbstractMaterial(kind))return CaelumStackSurfaceData.ABSTRACT_DENSITY_KG_M3;',
    '        switch(kind)',
    '        {'
]
seen=set()
for row in DATA['materials']:
    for kind in row['material_ids']:
        assert kind not in seen, kind
        seen.add(kind)
    lines.append('            '+' '.join('case '+str(k)+':' for k in row['material_ids'])+' return '+str(row['density_kg_m3'])+';')
lines += [
    '        }',
    '        // Componentes: misma materia prima y tier que su receta vigente.',
    '        if(kind>=CaelumConstants.MATERIAL_BLADE && kind<=CaelumConstants.MATERIAL_OPAL_BROOCH)',
    '            return MaterialDensity(CaelumCraftingRules.GetComponentBaseMaterial(kind,tier),tier);',
    '        return 0;',
    '    }',
    '}', ''
]
out=ROOT/'src/caelum/data/CaelumPhysicalSurfaceData.zs'
out.write_text('\n'.join(lines),encoding='utf-8',newline='\n')
print(f'Generated {out.relative_to(ROOT)}: {len(seen)} direct material references')
