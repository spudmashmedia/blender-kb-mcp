---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [operators, uv-mapping, mesh, viewport-menu, bmesh]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [operators, uv-mapping, custom-geometry, viewport-menu, mesh-editing]
last_updated: 2026-04-29
search_keywords: [uv operator, bmesh uv, vertex to uv mapping, edit mode operator, custom uv tools, bpy.types.Operator, IMAGE_MT_uvs, UV mapping automation, loop layer, uv coordinate editor]
---

# Template - Operator Mesh UV

```python
import bpy
import bmesh


def main(context):
    obj = context.active_object
    me = obj.data
    bm = bmesh.from_edit_mesh(me)

    uv_layer = bm.loops.layers.uv.verify()

    # Adjust UV coordinates.
    for face in bm.faces:
        for loop in face.loops:
            loop_uv = loop[uv_layer]
            # Use XY position of the vertex as a uv coordinate.
            loop_uv.uv = loop.vert.co.xy

    bmesh.update_edit_mesh(me)


class UvOperator(bpy.types.Operator):
    """UV Operator description"""
    bl_idname = "uv.simple_operator"
    bl_label = "Simple UV Operator"

    @classmethod
    def poll(cls, context):
        obj = context.active_object
        return obj and obj.type == 'MESH' and obj.mode == 'EDIT'

    def execute(self, context):
        main(context)
        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(UvOperator.bl_idname, text="Simple UV Operator")


# Register and add to the "UV" menu (required to also use F3 search "Simple UV Operator" for quick access).
def register():
    bpy.utils.register_class(UvOperator)
    bpy.types.IMAGE_MT_uvs.append(menu_func)


def unregister():
    bpy.utils.unregister_class(UvOperator)
    bpy.types.IMAGE_MT_uvs.remove(menu_func)


if __name__ == "__main__":
    register()

    # Test call.
    bpy.ops.uv.simple_operator()

```
