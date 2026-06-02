---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [operators, viewport-menu, object-properties, scene-access]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, custom-ui, viewport-menu, object-iteration]
last_updated: 2026-04-29
search_keywords: [create operator, bpy.types.Operator, VIEW3D_MT_object, context.scene.objects, poll function, register unregister, menu customization, iterate objects]
---

# Template - Operator Simple

```python
import bpy


def main(context):
    for ob in context.scene.objects:
        print(ob)


class SimpleOperator(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "object.simple_operator"
    bl_label = "Simple Object Operator"

    @classmethod
    def poll(cls, context):
        return context.active_object is not None

    def execute(self, context):
        main(context)
        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(SimpleOperator.bl_idname, text=SimpleOperator.bl_label)


# Register and add to the "object" menu (required to also use F3 search "Simple Object Operator" for quick access).
def register():
    bpy.utils.register_class(SimpleOperator)
    bpy.types.VIEW3D_MT_object.append(menu_func)


def unregister():
    bpy.utils.unregister_class(SimpleOperator)
    bpy.types.VIEW3D_MT_object.remove(menu_func)


if __name__ == "__main__":
    register()

    # Test call.
    bpy.ops.object.simple_operator()

```
