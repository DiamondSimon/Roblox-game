"""Build a Studio XML place from source without third-party tooling."""
from pathlib import Path
import xml.etree.ElementTree as ET
import json
ROOT=Path(__file__).resolve().parents[1]
serial=0

def item(parent,cls,name):
 global serial
 serial+=1
 node=ET.SubElement(parent,'Item',{'class':cls,'referent':f'RBX{serial}'})
 props=ET.SubElement(node,'Properties')
 ET.SubElement(props,'string',{'name':'Name'}).text=name
 return node,props

def scripts(parent,path):
 for p in sorted(path.iterdir()):
  if p.is_dir():
   folder,_=item(parent,'Folder',p.name);scripts(folder,p)
  elif p.suffix=='.lua':
   cls='LocalScript' if p.name.endswith('.client.lua') else 'Script' if p.name.endswith('.server.lua') else 'ModuleScript'
   name=p.name.removesuffix('.lua').removesuffix('.client').removesuffix('.server')
   _,props=item(parent,cls,name)
   ET.SubElement(props,'ProtectedString',{'name':'Source'}).text=p.read_text()

root=ET.Element('roblox',{'version':'4'})
ET.SubElement(root,'External').text='null'
ET.SubElement(root,'External').text='nil'
ws,props=item(root,'Workspace','Workspace')
ET.SubElement(props,'bool',{'name':'StreamingEnabled'}).text='true'
item(root,'Lighting','Lighting')
rep,_=item(root,'ReplicatedStorage','ReplicatedStorage')
shared,_=item(rep,'Folder','Shared');scripts(shared,ROOT/'src/shared')
server,_=item(root,'ServerScriptService','ServerScriptService');scripts(server,ROOT/'src/server')
starter,_=item(root,'StarterPlayer','StarterPlayer')
client,_=item(starter,'StarterPlayerScripts','StarterPlayerScripts');scripts(client,ROOT/'src/client')
item(root,'StarterGui','StarterGui')
item(root,'ServerStorage','ServerStorage')
item(root,'Players','Players')
ET.indent(root)
output=ROOT/'build/SCRAPYARD-0.3.6.rbxlx';output.parent.mkdir(exist_ok=True)
ET.ElementTree(root).write(output,encoding='utf-8',xml_declaration=True)
parsed=ET.parse(output)
assert len(parsed.findall('.//ProtectedString'))==len(list((ROOT/'src').rglob('*.lua')))
print(f'Built {output.name}: {output.stat().st_size:,} bytes')
