---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [asset-shelf, viewport-menu, bpy.types.AssetShelf, custom-ui, object-creation]
related_files: [02_object_properties.py.md, 03_asset_management/01_custom_shelves.py.md]
difficulty: intermediate
categories: [operators, asset-management, viewport-menu, custom-ui]
last_updated: 2026-04-29
search_keywords: [asset shelf, VIEW_3D_AST, AssetShelf class, register, unregister, data-block filters, context.mode, poll method, bpy.types, bl_space_type]
---

# Template - UI Asset Shelf

```python
import bpy


class MyAssetShelf(bpy.types.AssetShelf):
    bl_space_type = 'VIEW_3D'
    bl_idname = "VIEW3D_AST_my_asset_shelf"

    # Tell the shelf which data-block types to show. It is highly recommended
    # to use these filters, as they avoid slowdowns when there are many assets
    # of irrelevant data-block types.
    # If no filter is set, all data-block types will show.
    filter_material = True
    filter_object = True

    @classmethod
    def poll(cls, context):
        return context.mode == 'OBJECT'


def register():
    bpy.utils.register_class(MyAssetShelf)


def unregister():
    bpy.utils.unregister_class(MyAssetShelf)


if __name__ == "__main__":
    register()

```
