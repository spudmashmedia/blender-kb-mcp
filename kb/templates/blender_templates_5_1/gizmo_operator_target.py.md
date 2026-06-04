---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [gizmos, operators, viewport-menu, camera, custom-gizmo]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md, gizmo_examples/03_camera_dial_gizmo.py.md]
difficulty: intermediate
categories: [operators, gizmos, viewport-customization, object-creation, camera-tools]
last_updated: 2026-04-29
search_keywords: [gizmo, dial gizmo, transform operator, camera roll, GIZMO_GT_dial_3d, GizmoGroup, poll method, VIEW_3D, matrix_basis, register gizmos]
---

# Template - Gizmo Operator Target

```python
# Example of a gizmo that activates an operator
# using the predefined dial gizmo to change the camera roll.
#
# Usage: Run this script and select a camera in the 3D view.
#
import bpy
from bpy.types import (
    GizmoGroup,
)


class MyCameraWidgetGroup(GizmoGroup):
    bl_idname = "OBJECT_GGT_test_camera"
    bl_label = "Object Camera Test Widget"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'WINDOW'
    bl_options = {'3D', 'PERSISTENT'}

    @classmethod
    def poll(cls, context):
        ob = context.object
        return (ob and ob.type == 'CAMERA')

    def setup(self, context):
        # Run an operator using the dial gizmo
        ob = context.object
        gz = self.gizmos.new("GIZMO_GT_dial_3d")
        props = gz.target_set_operator("transform.rotate")
        props.constraint_axis = False, False, True
        props.orient_type = 'LOCAL'
        props.release_confirm = True

        gz.matrix_basis = ob.matrix_world.normalized()
        gz.line_width = 3

        gz.color = 0.8, 0.8, 0.8
        gz.alpha = 0.5

        gz.color_highlight = 1.0, 1.0, 1.0
        gz.alpha_highlight = 1.0

        self.roll_gizmo = gz

    def refresh(self, context):
        ob = context.object
        gz = self.roll_gizmo
        gz.matrix_basis = ob.matrix_world.normalized()


bpy.utils.register_class(MyCameraWidgetGroup)

```
