---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [operators, modal, timer, event-handling, viewport-menu]
related_files: [01_operator_basics.py.md, 02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [operators, custom-geometry, viewport-menu, event-system]
last_updated: 2026-04-29
search_keywords: [modal timer operator, bpy.types.Operator, event_timer_add, VIEW3D_MT_view, modal handler, theme color, event handling, running modal, cancel operation, register unregister]
---

# Template - Operator Modal Timer

```python
import bpy


class ModalTimerOperator(bpy.types.Operator):
    """Operator which runs itself from a timer"""
    bl_idname = "wm.modal_timer_operator"
    bl_label = "Modal Timer Operator"

    _timer = None

    def modal(self, context, event):
        if event.type in {'RIGHTMOUSE', 'ESC'}:
            self.cancel(context)
            return {'CANCELLED'}

        if event.type == 'TIMER':
            # Change theme color, silly!
            color = context.preferences.themes[0].view_3d.space.gradients.high_gradient
            color.s = 1.0
            color.h += 0.01

        return {'PASS_THROUGH'}

    def execute(self, context):
        wm = context.window_manager
        self._timer = wm.event_timer_add(0.1, window=context.window)
        wm.modal_handler_add(self)
        return {'RUNNING_MODAL'}

    def cancel(self, context):
        wm = context.window_manager
        wm.event_timer_remove(self._timer)


def menu_func(self, context):
    self.layout.operator(ModalTimerOperator.bl_idname, text=ModalTimerOperator.bl_label)


def register():
    bpy.utils.register_class(ModalTimerOperator)
    bpy.types.VIEW3D_MT_view.append(menu_func)


# Register and add to the "view" menu (required to also use F3 search "Modal Timer Operator" for quick access).
def unregister():
    bpy.utils.unregister_class(ModalTimerOperator)
    bpy.types.VIEW3D_MT_view.remove(menu_func)


if __name__ == "__main__":
    register()

    # Test call.
    bpy.ops.wm.modal_timer_operator()

```
