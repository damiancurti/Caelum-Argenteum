"""Exhaustive small-graph and deterministic eight-wall connectivity proof checks."""
from pathlib import Path
import argparse,hashlib,itertools,json,random,time,zipfile
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
with zipfile.ZipFile(a.candidate) as package:source=package.read('caelum/survival/CaelumThermalEnvironment.zs')
assert b'neighbors[first]>=2 || neighbors[second]>=2' in source
assert b'for(int second=first+1;second<count;second++)' in source
def reference(n,edges):
    # Independent connected-component construction, unrelated to vertex degree.
    parent=list(range(n));sizes=[1]*n
    def root(v):
        while parent[v]!=v:v=parent[v]
        return v
    for x,y in edges:
        x,y=root(x),root(y)
        if x!=y:parent[y]=x;sizes[x]+=sizes[y]
    return any(sizes[root(v)]>=3 for v in range(n))
def candidate(n,edges):
    degree=[0]*n
    for x,y in edges:
        degree[x]+=1;degree[y]+=1
        if degree[x]>=2 or degree[y]>=2:return True
    return False
def original(n,edges):
    adjacent=[set() for _ in range(n)]
    for x,y in edges:adjacent[x].add(y);adjacent[y].add(x)
    for first in range(n):
        reached={first}
        for _ in range(n):
            for i in range(n):
                if i not in reached and any(j in reached for j in adjacent[i]):reached.add(i)
        if len(reached)>=3:return True
    return False
counts={};truth={False:0,True:0};started=time.monotonic()
for n in range(7):
    pairs=list(itertools.combinations(range(n),2));counts[n]=1<<len(pairs)
    for bits in range(counts[n]):
        edges=[pair for i,pair in enumerate(pairs) if bits&(1<<i)]
        expected=reference(n,edges);assert candidate(n,edges)==original(n,edges)==expected,(n,bits);truth[expected]+=1
randomizer=random.Random(842)
negative_complete={}
def matchings(vertices):
    if not vertices:yield [];return
    first,*rest=vertices
    yield from matchings(rest)
    for index,other in enumerate(rest):
        for edges in matchings(rest[:index]+rest[index+1:]):yield [(first,other)]+edges
for n in (7,8):
    pairs=list(itertools.combinations(range(n),2));counts[n]=10000
    for _ in range(counts[n]):
        bits=randomizer.getrandbits(len(pairs));edges=[pair for i,pair in enumerate(pairs) if bits&(1<<i)]
        expected=reference(n,edges);assert candidate(n,edges)==original(n,edges)==expected,(n,bits);truth[expected]+=1
    negative_complete[n]=0
    for edges in matchings(list(range(n))):
        assert not reference(n,edges) and not candidate(n,edges) and not original(n,edges)
        negative_complete[n]+=1;truth[False]+=1
report=dict(issue=842,passed=True,graphs=sum(counts.values())+sum(negative_complete.values()),by_vertices=counts,additional_exhaustive_matchings=negative_complete,all_negative_graphs_through=8,exhaustive_through=6,deterministic_random_seed=842,positive=truth[True],negative=truth[False],elapsed_seconds=time.monotonic()-started,candidate_source_sha256=hashlib.sha256(source).hexdigest(),qualification='For an undirected graph, a connected component with at least three vertices exists iff some vertex has two distinct neighbors. Independent union-find, original reachability and candidate degree tests agree; separate native oracle validates traced/deduplicated wall inputs. No geometry sampler or game threshold changes.')
a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
