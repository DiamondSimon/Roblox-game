"""Extract four normalized, material-batched GLBs from the inspected 3D Jutsu scene.
No image edits or invented geometry: bake node transforms, preserve exported PBR materials.
"""
import json,struct,hashlib
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]/'assets/custom'
b=(ROOT/'scrapyard-heroes.glb').read_bytes();length=struct.unpack_from('<I',b,12)[0]
g=json.loads(b[20:20+length]);offset=20+length
binary=b[offset+8:offset+8+struct.unpack_from('<I',b,offset)[0]]
DT={5126:'<f4',5125:'<u4',5123:'<u2',5121:'u1'};WIDTH={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}
def read(i):
 a=g['accessors'][i];v=g['bufferViews'][a['bufferView']];dt=np.dtype(DT[a['componentType']]);w=WIDTH[a['type']]
 return np.ndarray((a['count'],w),dtype=dt,buffer=binary,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(v.get('byteStride',dt.itemsize*w),dt.itemsize)).copy()
def matrix(n):
 if 'matrix' in n:return np.array(n['matrix']).reshape(4,4).T
 x,y,z,w=n.get('rotation',[0,0,0,1]);R=np.array([[1-2*y*y-2*z*z,2*x*y-2*z*w,2*x*z+2*y*w],[2*x*y+2*z*w,1-2*x*x-2*z*z,2*y*z-2*x*w],[2*x*z-2*y*w,2*y*z+2*x*w,1-2*x*x-2*y*y]])
 m=np.eye(4);m[:3,:3]=R@np.diag(n.get('scale',[1,1,1]));m[:3,3]=n.get('translation',[0,0,0]);return m
reports={}
for name in ['reactor','pod','singularity','compactor']:
 root=next(i for i,n in enumerate(g['nodes']) if n.get('name')==name);groups={}
 def visit(i,parent):
  n=g['nodes'][i];m=parent@matrix(n)
  if 'mesh' in n:
   for p in g['meshes'][n['mesh']]['primitives']:
    assert p.get('mode',4)==4
    pos=read(p['attributes']['POSITION']);norm=read(p['attributes']['NORMAL'])
    pos=pos@m[:3,:3].T+m[:3,3];norm=norm@np.linalg.inv(m[:3,:3]);norm/=np.linalg.norm(norm,axis=1)[:,None]
    idx=read(p['indices']).ravel();groups.setdefault(p['material'],[]).append((pos,norm,idx))
  for child in n.get('children',[]):visit(child,m)
 visit(root,np.eye(4))
 allpos=np.concatenate([p for parts in groups.values() for p,_,_ in parts]);lo=allpos.min(axis=0);hi=allpos.max(axis=0);center=np.array([(lo[0]+hi[0])/2,lo[1],(lo[2]+hi[2])/2])
 out={'asset':{'version':'2.0','generator':'SCRAPYARD 0.3.6 / Higgsfield 3D Jutsu'},'scene':0,'scenes':[{'nodes':[0]}],'nodes':[{'name':name,'children':[]}],'meshes':[],'materials':[],'accessors':[],'bufferViews':[],'buffers':[],'extensionsUsed':['KHR_materials_emissive_strength']};data=bytearray();tri=0
 def add(a,kind,target):
  while len(data)%4:data.append(0)
  vi=len(out['bufferViews']);out['bufferViews'].append({'buffer':0,'byteOffset':len(data),'byteLength':a.nbytes,'target':target});data.extend(a.tobytes())
  acc={'bufferView':vi,'componentType':5125 if kind=='SCALAR' else 5126,'count':len(a),'type':kind}
  if kind=='VEC3':acc.update(min=a.min(axis=0).tolist(),max=a.max(axis=0).tolist())
  ai=len(out['accessors']);out['accessors'].append(acc);return ai
 for mi,(original,parts) in enumerate(groups.items()):
  ps=[];ns=[];ids=[];count=0
  for p,n,i in parts:ps.append((p-center)*np.array([-1,1,-1]));ns.append(n*np.array([-1,1,-1]));ids.append(i+count);count+=len(p)
  p=np.concatenate(ps).astype('<f4');n=np.concatenate(ns).astype('<f4');i=np.concatenate(ids).astype('<u4');tri+=len(i)//3
  pa=add(p,'VEC3',34962);na=add(n,'VEC3',34962);ia=add(i,'SCALAR',34963)
  out['materials'].append(g['materials'][original]);out['meshes'].append({'name':name+'_'+g['materials'][original]['name'],'primitives':[{'attributes':{'POSITION':pa,'NORMAL':na},'indices':ia,'material':mi}]})
  out['nodes'][0]['children'].append(len(out['nodes']));out['nodes'].append({'name':name+'_'+str(mi),'mesh':mi})
 out['buffers']=[{'byteLength':len(data)}]
 js=json.dumps(out,separators=(',',':')).encode();js+=b' '*((-len(js))%4);data.extend(b'\0'*((-len(data))%4))
 payload=struct.pack('<III',0x46546c67,2,12+8+len(js)+8+len(data))+struct.pack('<II',len(js),0x4e4f534a)+js+struct.pack('<II',len(data),0x004e4942)+data
 path=ROOT/(name+'.glb');path.write_bytes(payload)
 reports[name]={'triangles':tri,'mesh_primitives':len(groups),'materials':len(groups),'textures':0,'dimensions_m':[round(float(x),4) for x in hi-lo],'pivot':'floor center, Y up','front':'-Z','bytes':len(payload),'sha256':hashlib.sha256(payload).hexdigest()}
(ROOT/'export-metrics.json').write_text(json.dumps(reports,indent=2)+'\n');print(json.dumps(reports,indent=2))
