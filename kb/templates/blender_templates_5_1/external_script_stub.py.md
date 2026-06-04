---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [scripts, execution, utilities, file-system]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [script-execution, file-operations, utilities, external-scripts]
last_updated: 2026-04-29
search_keywords: [run script, execute python, external script, blend file location, exec, os.path, global namespace, bpy.data.filepath, script execution]
---

# Template - External Script Stub

```python
# This stub runs a python script relative to the currently open
# blend file, useful when editing scripts externally.

import bpy
import os

# Use your own script name here:
filename = "my_script.py"

filepath = os.path.join(os.path.dirname(bpy.data.filepath), filename)
global_namespace = {"__file__": filepath, "__name__": "__main__"}
with open(filepath, "rb") as file:
    exec(compile(file.read(), filepath, 'exec'), global_namespace)

```
