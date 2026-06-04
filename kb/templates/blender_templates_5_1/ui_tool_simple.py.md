---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [objects, operators, mesh, add-ons, viewport-menu, workspace-tools]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, custom-geometry, viewport-menu, tool-customization, object-creation]
last_updated: 2026-04-29
search_keywords: [create workspace tool, WorkSpaceTool, custom tools, view3d select, bl_keymap, draw_settings, register_tool, unregister_tool, tool customization, viewport toolbar]
---

# Template - UI Tool Simple

```python
# This example adds an object mode tool to the toolbar.
# This is just the circle-select and lasso tools tool.
import bpy
from bpy.types import WorkSpaceTool


class MyTool(WorkSpaceTool):
    bl_space_type = 'VIEW_3D'
    bl_context_mode = 'OBJECT'

    # The prefix of the idname should be your add-on name.
    bl_idname = "my_template.my_circle_select"
    bl_label = "My Circle Select"
    bl_description = (
        "This is a tooltip\n"
        "with multiple lines"
    )
    bl_icon = "ops.generic.select_circle"
    bl_widget = None
    bl_keymap = (
        ("view3d.select_circle", {"type": 'LEFTMOUSE', "value": 'PRESS'},
         {"properties": [("wait_for_input", False)]}),
        ("view3d.select_circle", {"type": 'LEFTMOUSE', "value": 'PRESS', "ctrl": True},
         {"properties": [("mode", 'SUB'), ("wait_for_input", False)]}),
    )

    def draw_settings(context, layout, tool):
        props = tool.operator_properties("view3d.select_circle")
        layout.prop(props, "mode")
        layout.prop(props, "radius")


class MyOtherTool(WorkSpaceTool):
    bl_space_type = 'VIEW_3D'
    bl_context_mode = 'OBJECT'

    bl_idname = "my_template.my_other_select"
    bl_label = "My Lasso Tool Select"
    bl_description = (
        "This is a tooltip\n"
        "with multiple lines"
    )
    bl_icon = "ops.generic.select_lasso"
    bl_widget = None
    bl_keymap = (
        ("view3d.select_lasso", {"type": 'LEFTMOUSE', "value": 'PRESS'}, None),
        ("view3d.select_lasso", {"type": 'LEFTMOUSE', "value": 'PRESS', "ctrl": True},
         {"properties": [("mode", 'SUB')]}),
    )

    def draw_settings(context, layout, tool):
        props = tool.operator_properties("view3d.select_lasso")
        layout.prop(props, "mode")


class MyWidgetTool(WorkSpaceTool):
    bl_space_type = 'VIEW_3D'
    bl_context_mode = 'OBJECT'

    bl_idname = "my_template.my_gizmo_translate"
    bl_label = "My Gizmo Tool"
    bl_description = "Short description"
    bl_icon = "ops.transform.transform"
    bl_widget = "VIEW3D_GGT_tool_generic_handle_free"
    bl_widget_properties = [
        ("radius", 75.0),
        ("backdrop_fill_alpha", 0.0),
    ]
    bl_keymap = (
        ("transform.transform", {"type": 'LEFTMOUSE', "value": 'PRESS'}, None),
    )

    def draw_settings(context, layout, tool):
        props = tool.operator_properties("transform.transform")
        layout.prop(props, "mode")


def register():
    bpy.utils.register_tool(MyTool, after={"builtin.scale_cage"}, separator=True, group=True)
    bpy.utils.register_tool(MyOtherTool, after={MyTool.bl_idname})
    bpy.utils.register_tool(MyWidgetTool, after={MyTool.bl_idname})


def unregister():
    bpy.utils.unregister_tool(MyTool)
    bpy.utils.unregister_tool(MyOtherTool)
    bpy.utils.unregister_tool(MyWidgetTool)


if __name__ == "__main__":
    register()

```
