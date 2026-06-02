---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [bmesh, mesh-editing, vertices, edit-mode, viewport-manipulation]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md, 03_bmesh_workflows.py.md]
difficulty: intermediate
categories: [operators, custom-geometry, bmesh-workflows, mesh-editing, edit-mode]
last_updated: 2026-04-29
search_keywords: [bmesh from_edit_mesh, bmesh update_edit_mesh, edit mode scripting, vertex manipulation, mesh modification, bpy.context.edit_object, loop_triangles, n-gon tessellation]
---

# Template - BMesh Simple Edit Mode

```python
# This example assumes we have a mesh object in edit-mode

import bpy
import bmesh

# Get the active mesh
obj = bpy.context.edit_object
me = obj.data


# Get a BMesh representation
bm = bmesh.from_edit_mesh(me)

bm.faces.active = None

# Modify the BMesh, can do anything here...
for v in bm.verts:
    v.co.x += 1.0


# Show the updates in the viewport
# and recalculate n-gon tessellation.
bmesh.update_edit_mesh(me, loop_triangles=True)

```
