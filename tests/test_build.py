from pathlib import Path
import unittest
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]

class BuildTests(unittest.TestCase):
 def test_studio_place_contains_current_source_and_entrypoints(self):
  xml=ET.parse(ROOT/'build/SCRAPYARD-0.3.3.rbxlx')
  embedded={}
  def walk(node,path=''):
   for child in node.findall('Item'):
    name=child.findtext('Properties/string[@name="Name"]')
    full=path+'/'+name
    source=child.findtext('Properties/ProtectedString[@name="Source"]')
    if source is not None: embedded[full]=(child.attrib['class'],source)
    walk(child,full)
  walk(xml.getroot())
  for p in (ROOT/'src').rglob('*.lua'):
   relative=str(p.relative_to(ROOT/'src'))
   path=relative.replace('shared/','/ReplicatedStorage/Shared/',1) if relative.startswith('shared/') else relative.replace('server/','/ServerScriptService/',1) if relative.startswith('server/') else relative.replace('client/','/StarterPlayer/StarterPlayerScripts/',1)
   cls='Script' if path.endswith('.server.lua') else 'LocalScript' if path.endswith('.client.lua') else 'ModuleScript'
   path=path.removesuffix('.lua').removesuffix('.server').removesuffix('.client')
   self.assertEqual(embedded[path],(cls,p.read_text()))
  self.assertEqual(len(embedded),len(list((ROOT/'src').rglob('*.lua'))))

if __name__=='__main__': unittest.main(verbosity=2)
