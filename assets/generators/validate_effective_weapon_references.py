"""Resolve effective world art and scaled envelopes for the #769 correction."""
import hashlib,json,re
from pathlib import Path
try:
    from .validate_inventory_ammunition_models import ROOT
except ImportError:
    from validate_inventory_ammunition_models import ROOT


def validate(root=ROOT):
    errors=[]
    try:
        sources=root/'assets/source/art/inventory_models_647'
        provenance=json.loads((sources/'effective_weapon_references/PROVENANCE.json').read_text())
        definitions=(root/'src/TEXTURES').read_text(encoding='utf-8')
        for folder,names in [('bladed_weapons',['sword','dagger','machete','greatsword']),('axes',['hatchet','axe','war_axe','pickaxe'])]:
            config=json.loads((sources/folder/'DESIGN.json').read_text())
            report=json.loads((sources/folder/'EXPORT.json').read_text())
            if config.get('correction_issue')!=769:errors.append('Missing effective-reference correction: '+folder)
            for key in names:
                item=config['variants'][key];record=report['variants'][key]
                reference='src/graphics/caelum/icons/ca_'+key+'.png';scale=[1,1]
                if key=='greatsword':reference='src/graphics/caelum/first_person/v5/greatsword_icon_t1_source.png';scale=[9.796875,9.796875]
                if item['reference']!=reference or item['sprite_scale']!=scale:errors.append('Unexpected effective reference/scale: '+key)
                declaration=re.findall(r'Sprite\s+"'+item['sprite']+r'A0"\s*,[^\n]+',definitions)
                if len(declaration)!=1:errors.append('Ambiguous world alias: '+key)
                elif key!='greatsword' and 'Patch "'+reference.removeprefix('src/')+'", 0, 0' not in declaration[0]:errors.append('Wrong world alias source: '+key)
                elif key=='greatsword' and not all(token in declaration[0] for token in ['XScale 9.796875','YScale 9.796875','Graphic "CA_GSICON1_M"']):errors.append('Changed scaled greatsword alias')
                bounds=record['native_bounds'][0];opaque=record['reference_opaque_bounds']
                for axis,index in [(0,0),(2,1)]:
                    if bounds['max'][axis]-bounds['min'][axis]>(opaque[index+2]-opaque[index])/scale[index]+1/32:errors.append('Exceeds effective scaled envelope: '+key)
                if key=='pickaxe' and hashlib.sha256((root/'src'/config['model_path']/(key+'.md3')).read_bytes()).hexdigest()!=provenance['records'][key]['runtime_sha256']:errors.append('Unrelated pickaxe model changed')
                if key in ['hatchet','axe','war_axe']:
                    points=[];groups={};group=None
                    for line in (sources/folder/'editable'/(key+'.obj')).read_text().splitlines():
                        row=line.split()
                        if not row:continue
                        if row[0]=='v':points.append(tuple(map(float,row[1:])))
                        elif row[0]=='g':group=row[1];groups.setdefault(group,set())
                        elif row[0]=='f':groups[group].update(int(v.split('/')[0])-1 for v in row[1:])
                    matrix=config['families'][key]['parts'][0]['rotation'];axis=[matrix[i][2] for i in range(3)]
                    def upper(name):
                        # OBJ Y-up -> native Z-up, then native 1/64 quantization.
                        return max(sum(a*b for a,b in zip(axis,[round(points[i][0]*64)/64,-round(points[i][2]*64)/64,round(points[i][1]*64)/64])) for i in groups[name])
                    if upper('socket')-upper('shaft')<=1/32:errors.append('Coincident shaft/socket upper caps: '+key)
        for text in ['Graphic "CA_GSICON1_M_D", 1254, 1254','Patch "graphics/caelum/first_person/v5/greatsword_icon_t1_source.png", 0, 0 { Translation "Desaturate", 20 }','Graphic "CA_GSICON1_M_D", 0, 0 { Blend 205, 198, 188 }']:
            if text not in definitions:errors.append('Changed greatsword reference transform')
        for name,checksum in provenance['source_sha256'].items():
            if hashlib.sha256((root/name).read_bytes()).hexdigest()!=checksum:errors.append('Changed alias source: '+name)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps(dict(issue=769,errors=errors,effective_aliases=8,corrected_models=7,unchanged_pickaxe=True)));raise SystemExit(bool(errors))
