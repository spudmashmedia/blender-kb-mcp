---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [bmesh, mesh, vertices, geometry-modification]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [operators, custom-geometry, viewport-menu, object-creation]
last_updated: 2026-04-29
search_keywords: [bmesh, mesh vertices, vertex manipulation, coordinate modification, bm.from_mesh, bm.to_mesh, bm.free, geometry editing, bpy.context.object.data]
---

# Template - BMesh Simple

```python
# This example assumes we have a mesh object selected

import bpy
import bmesh

# Get the active mesh
me = bpy.context.object.data


# Get a BMesh representation
bm = bmesh.new()   # create an empty BMesh
bm.from_mesh(me)   # fill it in from a Mesh


# Modify the BMesh, can do anything here...
for v in bm.verts:
    v.co.x += 1.0


# Finish up, write the bmesh back to the mesh
bm.to_mesh(me)
bm.free()  # free and prevent further access

```
