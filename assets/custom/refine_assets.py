import bpy
from mathutils import Vector
old=bpy.data.objects['Inner capsule'];parent=old.parent;mat=old.data.materials[0]
bpy.data.objects.remove(old,do_unlink=True)
bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,radius=1,location=(0,-.08,1.4))
o=bpy.context.object;o.name='Inner capsule';o.scale=(.55,.48,1.12);o.parent=parent;o.data.materials.append(mat)
bpy.data.materials['Charcoal steel'].node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.62
bpy.data.materials['Oxidized industrial ochre'].node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.72
mat.node_tree.nodes['Principled BSDF'].inputs['Emission Strength'].default_value=.7
scene=bpy.context.scene
scene.render.image_settings.file_format='PNG'
out=artifacts.file(name='scrapyard-custom-lineup.png',media_type='image/png');scene.render.filepath=out.path;bpy.ops.render.render(write_still=True);out.publish()
result={'change':'Tapered pod capsule contained inside shell; softened gloss and emission','capsule_dimensions':list(o.dimensions)}
