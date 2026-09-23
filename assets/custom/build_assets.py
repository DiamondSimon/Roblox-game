# Executed in Higgsfield 3D Jutsu Blender 5.2. Original SCRAPYARD authored geometry.
import bpy, math
from mathutils import Vector
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene.render.engine='BLENDER_EEVEE';scene.render.resolution_x=1400;scene.render.resolution_y=650;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
scene.world=bpy.data.worlds.new('Scrapyard studio world')
scene.world.color=(0.16,0.19,0.22)
def material(name,color,metal,rough,glow=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
 if glow:p.inputs['Emission Color'].default_value=(*color,1);p.inputs['Emission Strength'].default_value=glow
 return m
steel=material('Charcoal steel',(0.055,0.085,0.10),0.65,0.4)
yellow=material('Oxidized industrial ochre',(0.7,0.32,0.045),0.35,0.55)
cyan=material('Cyan ceramic energy',(0.025,0.7,0.66),0.15,0.25,1.8)
roots={};current=None
def finish(o,name,mat):
 o.name=name;o.data.materials.append(mat);o.parent=current
 return o
def cube(name,pos,size,mat=steel,bevel=.07):
 bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.dimensions=size
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 finish(o,name,mat)
 if bevel:
  m=o.modifiers.new('Machined edge','BEVEL');m.width=bevel;m.segments=2
  o.modifiers.new('Weighted edge normals','WEIGHTED_NORMAL')
 return o
def cyl(name,pos,r,depth,mat=steel,rotation=(0,0,0),vertices=20):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=depth,location=pos,rotation=rotation)
 o=finish(bpy.context.object,name,mat);m=o.modifiers.new('Edge roll','BEVEL');m.width=.035;m.segments=2;return o
def ring(name,pos,r,minor,mat=steel,rot=(0,0,0)):
 bpy.ops.mesh.primitive_torus_add(major_segments=24,minor_segments=6,location=pos,major_radius=r,minor_radius=minor,rotation=rot)
 return finish(bpy.context.object,name,mat)
def beam(name,a,b,width,mat=steel):
 a,b=Vector(a),Vector(b);o=cube(name,(a+b)/2,(width,width,(b-a).length),mat,.025);o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();return o
def root(name,x):
 global current
 current=bpy.data.objects.new(name,None);bpy.context.collection.objects.link(current);roots[name]=current
 # Children are authored around origin; final positioning happens after construction.
 current['display_x']=x
root('reactor',-6)
cube('Reactor skid',(0,0,.16),(2.4,1.9,.32))
cyl('Energy vessel',(0,0,1.45),.55,2.2,cyan)
for z in [.45,1.1,1.8,2.5]:ring('Containment ring',(0,0,z),.72,.12,yellow if z in [.45,2.5] else steel)
for x in [-.9,.9]:
 for y in [-.65,.65]:
  beam('Angled load frame',(x,y,.3),(x*.8,y*.8,2.6),.24,yellow)
  cube('Foot clamp',(x,y,.38),(.45,.45,.22),steel)
cube('Top lock',(0,0,2.7),(1.85,1.4,.24),steel)
cube('Control housing',(.96,-.4,1.35),(.32,.7,.9),steel)
cube('Control glass',(1.135,-.4,1.4),(.025,.42,.44),cyan,.01)
for z in [.95,1.2,1.45]:cube('Cooling rib',(-1,0,z),(.3,1.25,.08),steel,.015)
root('pod',-2)
cyl('Pod landing ring',(0,0,.15),1.03,.3,steel)
# Custom asymmetric segmented shell with deliberately broad relief ribs.
verts=[];faces=[];N=24
levels=[(.27,.58),(.55,.9),(1.2,1.02),(1.9,.81),(2.45,.48),(2.7,.14)]
for z,r in levels:
 for j in range(N):
  a=2*math.pi*j/N;rad=r*(1+.09*math.sin(3*a+z));verts.append((rad*math.cos(a)+.14*z/2.7,rad*.82*math.sin(a),z))
for k in range(len(levels)-1):
 for j in range(N):
  if j not in [16,17,18,19]:faces.append((k*N+j,k*N+(j+1)%N,(k+1)*N+(j+1)%N,(k+1)*N+j))
faces.extend([tuple(reversed(range(N))),tuple((len(levels)-1)*N+j for j in range(N))])
mesh=bpy.data.meshes.new('Asymmetric pod shell');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('Split alien shell',mesh);bpy.context.collection.objects.link(o);finish(o,o.name,steel)
solid=o.modifiers.new('Shell thickness','SOLIDIFY');solid.thickness=.09
be=o.modifiers.new('Shell lips','BEVEL');be.width=.04;be.segments=2
cyl('Inner capsule',(0,-.08,1.4),.58,1.9,cyan,vertices=16)
for z,r in [(.55,.89),(1.2,1.03),(1.9,.82)]:ring('Alien armor band',(.07,0,z),r,.08,steel)
for i in range(3):
 a=i*2*math.pi/3;beam('Splayed landing claw',(.5*math.cos(a),.5*math.sin(a),.7),(.9*math.cos(a),.9*math.sin(a),.23),.23,yellow)
beam('Salvager clamp',(-.95,.1,.7),(-.75,.1,2.0),.25,yellow)
cube('Clamp collar',(-.78,.1,1.95),(.45,.8,.28),yellow)
root('singularity',2)
cube('Singularity skids',(0,0,.18),(2.5,1.8,.36))
for y in [-.56,.56]:
 ring('Containment arch',(0,y,1.55),1.05,.15,steel,(math.pi/2,0,0))
 for x in [-.9,.9]:beam('Arch brace',(x,y,.35),(x*.85,y,2.2),.2,yellow)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=.61,location=(0,0,1.55));finish(bpy.context.object,'Unstable core',cyan)
for i in range(4):
 a=i*math.pi/2+.2
 beam('Core retention strut',(.52*math.cos(a),0,1.55+.52*math.sin(a)),(1.05*math.cos(a),0,1.55+1.05*math.sin(a)),.17,yellow)
for x in [-.75,.75]:
 cube('Capacitor bank',(x,0,.57),(.52,.9,.44),steel)
 for y in [-.3,0,.3]:cube('Capacitor fin',(x,y,.7),(.6,.055,.4),yellow,.01)
root('compactor',6)
cube('Compactor base',(0,0,.15),(3.15,2.35,.3))
for x in [-1.25,1.25]:
 for y in [-.87,.87]:cube('Press column',(x,y,1.65),(.3,.3,3),yellow)
cube('Crown',(0,0,3.08),(3.15,2.35,.4),yellow)
cube('Press platen',(0,0,1.6),(2.38,1.65,.28))
for x in [-.7,.7]:
 cyl('Chrome ram',(x,0,2.35),.12,1.3,steel)
 cyl('Cylinder housing',(x,0,2.8),.22,.5,yellow)
 cube('Motor housing',(x,1,1.0),(.6,.42,.8),steel)
 for z in [.8,1,1.2]:cube('Motor fins',(x,1.03,z),(.67,.5,.06),yellow,.015)
# Crushed vehicle shell, visibly dented sheet profile; wheels attached to hull.
verts=[(-1,-.5,.36),(1,-.5,.36),(1,.5,.36),(-1,.5,.36),(-.9,-.48,.7),(.85,-.5,.58),(1,.46,.69),(-.8,.5,.61)]
mesh=bpy.data.meshes.new('Crushed salvage hull');mesh.from_pydata(verts,[],[(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7),(3,2,1,0)]);mesh.update();o=bpy.data.objects.new('Crushed unbranded hull',mesh);bpy.context.collection.objects.link(o);finish(o,o.name,yellow)
for x in [-.65,.65]:
 for y in [-.5,.5]:cyl('Crushed wheel',(x,y,.42),.23,.14,steel,(math.pi/2,0,0),12)
cube('Cabinet',(1.1,-1.0,1),(.45,.4,.75),steel)
cube('Screen',(1.1,-1.22,1.15),(.27,.04,.25),cyan,.01)
for x in [-1.3,1.3]:cyl('Warning lamp',(x,0,3.37),.1,.18,cyan,vertices=12)
for name,o in roots.items():o.location.x=o['display_x']
# Camera/key/fill are presentation-only, excluded from individual delivery exports.
bpy.ops.object.camera_add(location=(8,-20,12));cam=bpy.context.object;cam.name='Delivery camera';cam.rotation_euler=(Vector((0,0,1.3))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=18;scene.camera=cam
for name,pos,energy,color in [('Key',(0,-6,10),2200,(1,.85,.68)),('Fill',(-6,2,8),1800,(.55,.8,1)),('Rim',(6,5,8),2000,(.6,1,.95))]:
 bpy.ops.object.light_add(type='POINT',location=pos);light=bpy.context.object;light.name=name;light.data.energy=energy;light.data.color=color;light.data.shadow_soft_size=4
scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.13,.18,.22,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.5
scene.render.film_transparent=False
out=artifacts.file(name='scrapyard-custom-lineup.png',media_type='image/png');scene.render.filepath=out.path;bpy.ops.render.render(write_still=True);out.publish()
deps=bpy.context.evaluated_depsgraph_get();report={}
for name,rootobj in roots.items():
 tri=0;count=0
 for obj in rootobj.children:
  if obj.type=='MESH':
   ev=obj.evaluated_get(deps);me=ev.to_mesh();me.calc_loop_triangles();tri+=len(me.loop_triangles);count+=1;ev.to_mesh_clear()
 report[name]={'triangles_evaluated':tri,'mesh_objects':count,'materials':3,'textures':0}
result=report
