---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [viewport-menu, operators, pie-menus, mesh-selection]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, viewport-menu, custom-geometry, menu-systems]
last_updated: 2026-04-29
search_keywords: [pie menu, mesh select mode, operator_enum, bpy.types.Menu, VIEW3D_MT_PIE_template, layout.menu_pie, selection modes, register, unregister]
---

# Template - UI Pie Menu

```python
import bpy
from bpy.types import Menu

# spawn an edit mode selection pie (run while object is in edit mode to get a valid output)


class VIEW3D_MT_PIE_template(Menu):
    # label is displayed at the center of the pie menu.
    bl_label = "Select Mode"

    def draw(self, context):
        layout = self.layout

        pie = layout.menu_pie()
        # operator_enum will just spread all available options
        # for the type enum of the operator on the pie
        pie.operator_enum("mesh.select_mode", "type")


def register():
    bpy.utils.register_class(VIEW3D_MT_PIE_template)


def unregister():
    bpy.utils.unregister_class(VIEW3D_MT_PIE_template)


if __name__ == "__main__":
    register()

    bpy.ops.wm.call_menu_pie(name="VIEW3D_MT_PIE_template")

```
