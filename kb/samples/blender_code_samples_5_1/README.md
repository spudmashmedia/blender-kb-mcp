# Directory Structure Plan

```
blender_api_samples/
├── 01_basics/
│   ├── 01_scene_objects.py.md
│   ├── 02_object_properties.py.md
│   ├── 03_materials_textures.py.md
│   └── 04_collections_layers.py.md
├── 02_geometry_creation/
│   ├── 01_bmesh_primitives.py.md
│   ├── 02_mesh_from_data.py.md
│   ├── 03_modifier_operations.py.md
│   └── 04_boolean_operations.py.md
├── 03_transforms_animation/
│   ├── 01_location_rotation_scale.py.md
│   ├── 02_keyframe_animation.py.md
│   ├── 03_constraints.py.md
│   └── 04_rigging_basics.py.md
├── 04_rendering_output/
│   ├── 01_camera_settings.py.md
│   ├── 02_lighting_setup.py.md
│   ├── 03_material_nodes.py.md
│   └── 04_image_export.py.md
├── 05_ui_customization/
│   ├── 01_operator_registration.py.md
│   ├── 02_panel_creation.py.md
│   ├── 03_property_panels.py.md
│   └── 04_menu_widgets.py.md
├── 06_data_manipulation/
│   ├── 01_custom_properties.py.md
│   ├── 02_object_collections.py.md
│   ├── 03_scene_management.py.md
│   └── 04_asset_library.py.md
├── 07_advanced_geometry/
│   ├── 01_vertex_editing.py.md
│   ├── 02_face_selection.py.md
│   ├── 03_bone_weight_paint.py.md
│   └── 04_curve_surface_meshes.py.md
├── 08_error_handling_patterns/
│   ├── 01_safe_operations.py.md
│   ├── 02_context_validation.py.md
│   ├── 03_transaction_blocks.py.md
│   └── 04_logging_debugging.py.md
└── 09_real_world_workflows/
    ├── 01_procedural_generation.py.md
    ├── 02_batch_processing.py.md
    ├── 03_addon_development.py.md
    └── 04_plugin_integration.py.md
```

# 📝 File Naming Convention & Content Format
## Each file should follow this structure:

```markdown
# [Functionality Name] - Blender 5.1 API Sample

## Purpose
[What does this code accomplish?]

## Use Cases
- [Use case 1]
- [Use case 2]

## Basic Example
```python
# Minimal working example
import bpy

def basic_example():
    # Your code here
    pass
```

# Advanced Example

```
# Production-ready with error handling
import bpy
from mathutils import Vector, Euler

def advanced_example(context):
    try:
        # Your robust implementation
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False
```

# Key API Elements Used
- bpy.ops.object.add() - Description of usage
- mathutils.Vector - Vector operations explained
- etc.

# Common Pitfalls & Solutions

|Problem|	Solution|
|---|---|
|[Issue]|	[Fix]|

# Related Functions
- See also: [related_function_name] in [filename]

Tags: #objects #geometry #transform


## 🎯 Priority File List (Start Here)

### Phase 1 - Foundation (Essential for Basic Troubleshooting)
| File | Why Important |
|------|---------------|
| `01_basics/01_scene_objects.py.md` | Object manipulation basics |
| `01_basics/02_object_properties.py.md` | Custom properties & data storage |
| `04_data_manipulation/01_custom_properties.py.md` | Property system patterns |
| `08_error_handling_patterns/01_safe_operations.py.md` | Error handling templates |

### Phase 2 - Geometry Workflows (Most Common Use Case)
| File | Why Important |
|------|---------------|
| `02_geometry_creation/01_bmesh_primitives.py.md` | BMesh API reference |
| `02_geometry_creation/02_mesh_from_data.py.md` | Programmatic mesh creation |
| `07_advanced_geometry/01_vertex_editing.py.md` | Low-level geometry editing |

### Phase 3 - Animation & Transformations
| File | Why Important |
|------|---------------|
| `03_transforms_animation/02_keyframe_animation.py.md` | Animation keyframes |
| `03_transforms_animation/01_location_rotation_scale.py.md` | Transform operations |

### Phase 4 - UI & Operators (Add-on Development)
| File | Why Important |
|------|---------------|
| `05_ui_customization/01_operator_registration.py.md` | Operator creation |
| `05_ui_customization/02_panel_creation.py.md` | UI panels |

### Phase 5 - Real-World Patterns (Best Practices)
| File | Why Important |
|------|---------------|
| `09_real_world_workflows/01_procedural_generation.py.md` | Procedural workflows |
| `08_error_handling_patterns/02_context_validation.py.md` | Context checks |

## 🏷️ Tagging Strategy for Chromadb

Each file should include tags for semantic search:

```markdown
# Tags: #objects #bmesh #geometry #creation #primitives
Recommended tag categories:

#objects, #meshes, #materials, #cameras, #lights
#operators, #properties, #ui, #panels
#animation, #keyframes, #constraints, #rigging
#bmesh, #geometry, #vertices, #faces
#error-handling, #context, #validation
#procedural, #batch, #automation

# 🚀 Implementation Steps
- Start with Phase 1 files (4 essential files)
- Test ingestion into chromadb - verify searchability
- Add Phase 2 files (geometry focus)
- Continue through phases based on need
- Update tags as you discover new patterns

# 💡 Pro Tips for File Creation
- Include error cases: Show what happens when things go wrong
- Document context requirements: When bpy.context.object is needed vs bpy.data.objects
- Version notes: Mark any 5.1-specific features or changes from previous versions
- Performance warnings: Note expensive operations that should be batched
```

# Markdown Headings formatting 

|Element|	Heading Level|	Markdown Syntax|
|---|---|---|
|Document Title|	H1| (only one)|	# Collections & Layers Management - Blender 5.1 API Sample|
|Purpose|	H2|	## Purpose|
|Use Cases|	H2|	## Use Cases|
|Basic Example|	H2|	## Basic Example|
|Advanced Example|	H2|	## Advanced Example|
|Key API Elements Used|	H2|	## Key API Elements Used|
|Common Pitfalls & Solutions|	H2|	## Common Pitfalls & Solutions||
Related Functions|	H2|	## Related Functions|

# Markdown Indexing

NOTE: the markdown files appear to have less precedence than than the HTML files when chunked and pushed into Chromadb. To push up the priority, use this header template at the beginning of every markdown and fill in the details based on the context of the markdown document:

```
---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, basics, scene-management, transforms, primitives]
related_files: [...list of related docs...]
difficulty: beginner
categories: [objects, transformations, operators, primitives]
last_updated: 2024-01-15
search_keywords: [create object, cube, sphere, location, rotation, scale, ...]
---
```
