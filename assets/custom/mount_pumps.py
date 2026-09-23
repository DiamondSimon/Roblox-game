import bpy
from mathutils import Vector
parent=bpy.data.objects['compactor'];steel=bpy.data.materials['Charcoal steel']
for side in [-1,1]:
 a=Vector((side*.7,1,1));b=Vector((side*1.25,.87,1))
 bpy.ops.mesh.primitive_cube_add(size=1,location=(a+b)/2);o=bpy.context.object;o.name='Motor mounting bracket';o.dimensions=(.22,.22,(b-a).length);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();o.parent=parent;o.data.materials.append(steel)
 m=o.modifiers.new('Edge bevel','BEVEL');m.width=.025;m.segments=2
scene=bpy.context.scene
out=artifacts.file(name='scrapyard-custom-lineup.png',media_type='image/png');scene.render.filepath=out.path;bpy.ops.render.render(write_still=True);out.publish()
result={'fixed':'Both rear pump motors now mount to the press columns with solid brackets'}
