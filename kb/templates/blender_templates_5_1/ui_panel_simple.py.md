---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [objects, operators, viewport-menu, properties-panel, custom-ui]
related_files: [02_object_properties.py.md, 03_ui_panels/01_custom_panel_creation.py.md]
difficulty: beginner
categories: [operators, custom-geometry, viewport-menu, object-properties]
last_updated: 2026-04-29
search_keywords: [create panel, bpy.types.Panel, PROPERTIES space, custom UI, object context, HelloWorld Panel, draw method, register unregister, mesh.primitive_cube_add, VIEW3D_MT_mesh_add]
---

# Template - UI Panel Simple

```python
import bpy


class HelloWorldPanel(bpy.types.Panel):
    """Creates a Panel in the Object properties window"""
    bl_label = "Hello World Panel"
    bl_idname = "OBJECT_PT_hello"
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = "object"

    def draw(self, context):
        layout = self.layout

        obj = context.object

        row = layout.row()
        row.label(text="Hello world!", icon='WORLD_DATA')

        row = layout.row()
        row.label(text="Active object is: " + obj.name)
        row = layout.row()
        row.prop(obj, "name")

        row = layout.row()
        row.operator("mesh.primitive_cube_add")


def register():
    bpy.utils.register_class(HelloWorldPanel)


def unregister():
    bpy.utils.unregister_class(HelloWorldPanel)


if __name__ == "__main__":
    register()

```
