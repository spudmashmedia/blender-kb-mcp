---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [menu, operators, viewport-menu, custom, bpy.types.Menu]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, menus, viewport-menu, custom-geometry, object-creation]
last_updated: 2026-04-29
search_keywords: [create menu, menu operator, bpy.types.Menu, INFO_HT_header, operator_menu_enum, register unregister, wm.call_menu, VIEW3D_MT_uv_map]
---

# Template - UI Menu

```python
import bpy


class CustomMenu(bpy.types.Menu):
    bl_label = "Custom Menu"
    bl_idname = "OBJECT_MT_custom_menu"

    def draw(self, context):
        layout = self.layout

        layout.operator("wm.open_mainfile")
        layout.operator("wm.save_as_mainfile").copy = True

        layout.operator("object.shade_smooth")

        layout.label(text="Hello world!", icon='WORLD_DATA')

        # use an operator enum property to populate a sub-menu
        layout.operator_menu_enum(
            "object.select_by_type",
            property="type",
            text="Select All by Type",
        )
        # call another menu
        layout.operator("wm.call_menu", text="Unwrap").name = "VIEW3D_MT_uv_map"


def draw_item(self, context):
    layout = self.layout
    layout.menu(CustomMenu.bl_idname)


def register():
    bpy.utils.register_class(CustomMenu)

    # lets add ourselves to the main header
    bpy.types.INFO_HT_header.append(draw_item)


def unregister():
    bpy.utils.unregister_class(CustomMenu)

    bpy.types.INFO_HT_header.remove(draw_item)


if __name__ == "__main__":
    register()

    # The menu can also be called from scripts
    bpy.ops.wm.call_menu(name=CustomMenu.bl_idname)

```
