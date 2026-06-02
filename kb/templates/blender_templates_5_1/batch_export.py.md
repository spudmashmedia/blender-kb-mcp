---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [export, objects, operators, file-io, fb-export]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, export, file-io, object-management]
last_updated: 2026-04-29
search_keywords: [export objects, fb-export, scene export, selection handling, filepath management, bpy.ops.export_scene.fbx, batch export, object naming] 
---

# Template - Batch Export

```python
# exports each selected object into its own file

import bpy
import os

# export to blend file location
basedir = os.path.dirname(bpy.data.filepath)

if not basedir:
    raise Exception("Blend file is not saved")

view_layer = bpy.context.view_layer

obj_active = view_layer.objects.active
selection = bpy.context.selected_objects

bpy.ops.object.select_all(action='DESELECT')

for obj in selection:

    obj.select_set(True)

    # some exporters only use the active object
    view_layer.objects.active = obj

    name = bpy.path.clean_name(obj.name)
    fn = os.path.join(basedir, name)

    bpy.ops.export_scene.fbx(filepath=fn + ".fbx", use_selection=True)

    # Can be used for multiple formats
    # bpy.ops.export_scene.x3d(filepath=fn + ".x3d", use_selection=True)

    obj.select_set(False)

    print("written:", fn)


view_layer.objects.active = obj_active

for obj in selection:
    obj.select_set(True)

```
