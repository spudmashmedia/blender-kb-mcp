---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [panels, viewport-ui, property-groups, register-unregister, ui-list]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, custom-geometry, viewport-menu, object-creation, panel-creation]
last_updated: 2026-04-29
search_keywords: [bpy.types.Panel, draw_ui_list, property-group, scene properties, register classes, unregister classes, VIEW_3D, UI list, bl_category, custom-panel]
---

# Template - UI List Generic

```python
import bpy
from bl_ui.generic_ui_list import draw_ui_list


class MyPropGroup(bpy.types.PropertyGroup):
    name: bpy.props.StringProperty()


class MyPanel(bpy.types.Panel):
    bl_label = "My Label"
    bl_idname = "SCENE_PT_list_demo"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "My Category"

    def draw(self, context):
        layout = self.layout
        draw_ui_list(
            layout,
            context,
            list_path="scene.my_list",
            active_index_path="scene.my_list_active_index",
            unique_id="my_list_id",
        )


classes = [
    MyPropGroup,
    MyPanel,
]

class_register, class_unregister = bpy.utils.register_classes_factory(classes)


def register():
    class_register()
    bpy.types.Scene.my_list = bpy.props.CollectionProperty(type=MyPropGroup)
    bpy.types.Scene.my_list_active_index = bpy.props.IntProperty()


def unregister():
    class_unregister()
    del bpy.types.Scene.my_list
    del bpy.types.Scene.my_list_active_index


register()

```
