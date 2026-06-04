---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [objects, operators, mesh, viewport-menu, modal-operators]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [operators, custom-geometry, viewport-menu, object-manipulation]
last_updated: 2026-04-29
search_keywords: [modal operator, move object with mouse, bpy.types.Operator, VIEW3D_MT_object, IntProperty, FloatProperty, invoke, modal, register, unregister]
---

# Template - Operator Modal

```python
import bpy
from bpy.props import IntProperty, FloatProperty


class ModalOperator(bpy.types.Operator):
    """Move an object with the mouse, example"""
    bl_idname = "object.modal_operator"
    bl_label = "Simple Modal Operator"

    first_mouse_x: IntProperty()
    first_value: FloatProperty()

    def modal(self, context, event):
        if event.type == 'MOUSEMOVE':
            delta = self.first_mouse_x - event.mouse_x
            context.object.location.x = self.first_value + delta * 0.01

        elif event.type == 'LEFTMOUSE':
            return {'FINISHED'}

        elif event.type in {'RIGHTMOUSE', 'ESC'}:
            context.object.location.x = self.first_value
            return {'CANCELLED'}

        return {'RUNNING_MODAL'}

    def invoke(self, context, event):
        if context.object:
            self.first_mouse_x = event.mouse_x
            self.first_value = context.object.location.x

            context.window_manager.modal_handler_add(self)
            return {'RUNNING_MODAL'}
        else:
            self.report({'WARNING'}, "No active object, could not finish")
            return {'CANCELLED'}


def menu_func(self, context):
    self.layout.operator(ModalOperator.bl_idname, text=ModalOperator.bl_label)


# Register and add to the "view" menu (required to also use F3 search "Simple Modal Operator" for quick access).
def register():
    bpy.utils.register_class(ModalOperator)
    bpy.types.VIEW3D_MT_object.append(menu_func)


def unregister():
    bpy.utils.unregister_class(ModalOperator)
    bpy.types.VIEW3D_MT_object.remove(menu_func)


if __name__ == "__main__":
    register()

    # Test call.
    bpy.ops.object.modal_operator('INVOKE_DEFAULT')

```
