---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [objects, operators, mesh, add-ons, viewport-menu]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, custom-geometry, viewport-menu, object-creation]
last_updated: 2026-04-29
search_keywords: [create menu, custom menu, operator, bpy.types.Menu, VIEW3D_MT_mesh_add, register, unregister, wm.open_mainfile, wm.save_as_mainfile]
---

# Template - UI Menu Simple

```python
import bpy


class SimpleCustomMenu(bpy.types.Menu):
    bl_label = "Simple Custom Menu"
    bl_idname = "OBJECT_MT_simple_custom_menu"

    def draw(self, context):
        layout = self.layout

        layout.operator("wm.open_mainfile")
        layout.operator("wm.save_as_mainfile")


def register():
    bpy.utils.register_class(SimpleCustomMenu)


def unregister():
    bpy.utils.unregister_class(SimpleCustomMenu)


if __name__ == "__main__":
    register()

    # The menu can also be called from scripts
    bpy.ops.wm.call_menu(name=SimpleCustomMenu.bl_idname)

```
