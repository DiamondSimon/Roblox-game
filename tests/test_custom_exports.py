import hashlib,json,struct,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]/'assets/custom'
class CustomExports(unittest.TestCase):
 def test_export_budgets_materials_pivots_and_hashes(self):
  metrics=json.loads((ROOT/'export-metrics.json').read_text())
  for name,report in metrics.items():
   with self.subTest(asset=name):
    data=(ROOT/(name+'.glb')).read_bytes();magic,version,size=struct.unpack_from('<III',data)
    self.assertEqual((magic,version,size),(0x46546c67,2,len(data)))
    self.assertEqual(hashlib.sha256(data).hexdigest(),report['sha256'])
    n=struct.unpack_from('<I',data,12)[0];g=json.loads(data[20:20+n]);binary=data[28+n:]
    self.assertEqual(len(g['materials']),3);self.assertEqual(len(g['meshes']),3)
    self.assertFalse(g.get('textures'));self.assertFalse(g.get('cameras'))
    self.assertEqual(g['scenes'][0]['nodes'],[0]);self.assertEqual(g['nodes'][0]['name'],name)
    triangles=0;positions=[]
    for mesh in g['meshes']:
     for p in mesh['primitives']:
      idx=g['accessors'][p['indices']];triangles+=idx['count']//3
      a=g['accessors'][p['attributes']['POSITION']];v=g['bufferViews'][a['bufferView']]
      start=v.get('byteOffset',0)+a.get('byteOffset',0)
      positions.extend(struct.iter_unpack('<fff',binary[start:start+a['count']*12]))
    self.assertEqual(triangles,report['triangles']);self.assertLess(triangles,10000)
    lo=[min(p[i] for p in positions) for i in range(3)];hi=[max(p[i] for p in positions) for i in range(3)]
    self.assertAlmostEqual(lo[1],0,places=5)
    self.assertAlmostEqual(lo[0]+hi[0],0,places=5);self.assertAlmostEqual(lo[2]+hi[2],0,places=5)
    for i in range(3):self.assertAlmostEqual(hi[i]-lo[i],report['dimensions_m'][i],places=3)
