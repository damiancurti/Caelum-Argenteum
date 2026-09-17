#!/usr/bin/env python3
"""Genera las tablas regionales a partir de la transcripción del SMN citada."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[2]
data=json.loads((root/'assets/climate/smn_1991_2020.json').read_text())['stations']
metrics=['tmean','tmax','tmin','rh','rain_mm','rain_days','cloud','wind']
s=['// Generado por generate_climate_normals.py. SMN 1991-2020; viento 2011-2020.', '// Fuente y páginas: assets/climate/smn_1991_2020.json.', 'class CaelumClimateNormals : Object {', '    const REGION_COUNT = 9;']
s.append('    static clearscope bool Valid(int region) { return region>=1 && region<=REGION_COUNT; }')
for key,field in [('Latitude','latitude'),('Longitude','longitude'),('AnnualMean','annual_mean')]:
 s.append('    static clearscope double '+key+'For(int region) {')
 s.append('        static const double values[] = {'+', '.join(str(r[field]) for r in data)+'};')
 s.append('        return Valid(region)?values[region-1]:0; }')
s.append('    static clearscope double Value(int region,int month,int metric) {')
s.append('        if(!Valid(region) || month<1 || month>12 || metric<0 || metric>7)return 0;')
s.append('        switch(region) {')
for r in data:s.append('        case '+str(r['id'])+': return Station'+str(r['id'])+'(month,metric);')
s += ['        } return 0;', '    }']
for r in data:
 s.append('    // '+r['name'])
 s.append('    static clearscope double Station'+str(r['id'])+'(int month,int metric) {')
 s.append('        static const double monthly[] = {')
 for m in metrics:s.append('            '+', '.join(str(v) for v in r[m])+',')
 s[-1]=s[-1].rstrip(',')
 s += ['        };', '        return monthly[metric*12+month-1];', '    }']
s.append('}')
(root/'src/caelum/world/CaelumClimateNormals.zs').write_text('\n'.join(s)+'\n')
