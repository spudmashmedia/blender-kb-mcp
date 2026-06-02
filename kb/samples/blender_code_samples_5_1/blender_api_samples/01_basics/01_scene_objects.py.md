---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, basics, scene-management, transforms, primitives]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: beginner
categories: [objects, transformations, operators, primitives]
last_updated: 2026-04-29
search_keywords: [create object, cube, sphere, location, rotation, scale, selection, active_object, bpy.ops.mesh.primitive_cube_add, primitive_uv_sphere_add, get_object_by_name, set_object_transform, create_cube]
---

# Scene Objects - Basic Object Manipulation in Blender 5.1

## Purpose
This module demonstrates fundamental object operations in Blender's Python API, including creation, transformation, selection, and management of objects within a scene.

## Use Cases
- Creating basic primitives (cubes, spheres) programmatically
- Setting object transforms (location, rotation, scale)
- Selecting objects by type
- Managing object lifecycle (create, rename, delete)
- Safely retrieving objects from the scene database

## Basic Example

```python
import bpy
from mathutils import Vector

# Create a cube at specific location
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(3, 1, 0))
cube = bpy.context.active_object
cube.name = "MyCube"

# Create a sphere with custom radius
bpy.ops.mesh.primitive_uv_sphere_add(radius=1.5)
sphere = bpy.context.active_object
sphere.name = "MySphere"
```

## Advanced Example
```python
import bpy
from mathutils import Vector, Euler
from math import radians
from typing import List, Optional


def create_cube(
    name: str = "Cube", 
    location=(0, 0, 0), 
    size=2.0
) -> Optional[bpy.types.Object]:
    """Create a cube object and return the reference."""
    
    # Remove existing object with same name to avoid conflicts
    if name in bpy.data.objects:
        print(f"⚠ Object '{name}' exists, removing...")
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    
    try:
        # Add cube using operator (Blender's recommended way for primitives)
        result = bpy.ops.mesh.primitive_cube_add(
            size=size,
            location=location,
            align='WORLD'
        )
        print(f"✓ Operator returned: {result}")
        
    except RuntimeError as e:
        print(f"✗ Operator failed with context error: {e}")
        return None
    
    # CRITICAL FIX: Retrieve by name instead of relying on active_object
    new_obj = bpy.data.objects.get(name)
    
    if not new_obj:
        # Fallback: get the last object in scene (last created)
        new_obj = next(
            (obj for obj in reversed(list(bpy.data.objects)) 
             if obj.type == 'MESH'), 
            None
        )
        
        if new_obj:
            new_obj.name = name
    
    if new_obj:
        print(f"✓ Created object: {new_obj.name} at {new_obj.location}")
    
    return new_obj


def set_object_transform(
    obj_name: str, 
    location=None, 
    rotation_degrees=None, 
    scale=None
) -> bool:
    """Set transform properties of an object. Rotation in DEGREES for user convenience."""
    
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    # Set location (vector or tuple/list)
    if location is not None:
        obj.location = Vector(location) if isinstance(location, (tuple, list)) else location
        print(f"  Location set to: {obj.location}")
    
    # Set rotation - CONVERT DEGREES TO RADIANS using math.radians()
    if rotation_degrees is not None:
        try:
            if isinstance(rotation_degrees, Euler):
                obj.rotation_euler = rotation_degrees
            else:
                # Convert degrees to radians properly
                obj.rotation_euler = Euler([radians(r) for r in rotation_degrees])
            print(f"  Rotation set to (degrees): {[round(radians(r)*180/3.14159, 2) for r in rotation_degrees]}")
        except Exception as e:
            print(f"✗ Failed to set rotation: {e}")
    
    # Set scale (vector or tuple/list)
    if scale is not None:
        obj.scale = Vector(scale) if isinstance(scale, (tuple, list)) else scale
        print(f"  Scale set to: {obj.scale}")
    
    return True


def get_object_by_name(name: str) -> Optional[bpy.types.Object]:
    """Safely retrieve an object by name."""
    try:
        obj = bpy.data.objects[name]
        if obj:
            print(f"✓ Found object '{name}'")
        return obj
    except KeyError:
        print(f"✗ Object '{name}' not found")
        return None


# --- Test Usage Example ---
if __name__ == "__main__":
    cube = create_cube("TestCube", location=(3, 1, 0), size=2.0)
    
    if cube:
        set_object_transform(
            "TestCube", 
            rotation_degrees=[90, 45, 0],
            scale=(1.5, 1.5, 1.5)
        )

```

## Key API Elements Used
|Element|Description|Usage|
|---|---|---|
|bpy.ops.mesh.primitive_cube_add()|	Create cube primitive via operator|	Recommended for creating primitives|
|bpy.ops.mesh.primitive_uv_sphere_add()|	Create sphere primitive	Supports segments/radius customization|
|bpy.context.active_object	|Reference to last selected/created object|	Must be used immediately after operators|
|bpy.data.objects[name]|	Access objects by name from scene database|	Safe retrieval when not active|
|obj.location|	Object position (X, Y, Z in meters)|	Vector or tuple/list accepted|
|obj.rotation_euler|	Object rotation in radians|	Blender stores rotations internally as radians|
|obj.scale|	Object scale multiplier per axis|	Vector or tuple/list accepted|
|obj.dimensions|	Object size after applying scale|	Read-only property showing actual mesh bounds|

## Common Pitfalls & Solutions
|Problem|	Solution|
|---|---|
|Objects not visible in viewport but exist in outliner|	Check if objects are hidden (eye icon) or outside view frustum|
|Rotation values seem wrong|	|Blender uses radians internally - convert degrees: radians = degrees * π/180|
|Dimensions show as {0,0,0} after creation|	Use specific primitive operators (primitive_cube_add) instead of generic add operator|
|KeyError when accessing object by name|	Always check existence first with if name in bpy.data.objects:|
|Iteration errors during object deletion|	Use list copy: for obj in list(bpy.data.objects):|
|Operators not working outside viewport context|	Some operators require 3D viewport to be active and visible|

## Related Functions & Files
- See also: 02_geometry_creation/01_bmesh_primitives.py.md for BMesh-based creation
- See also: 08_error_handling_patterns/01_safe_operations.py.md for error handling templates
- Related operators: bpy.ops.object.add, bpy.data.objects.remove()
- 
## Blender Version Notes
- **Tested**: Blender 5.1
- **Rotation API**: Always in radians internally, but we provide degree conversion helper
- **Operator behavior**: primitive_cube_add creates properly initialized mesh vs generic add operator
  
*Tags: #objects #basics #scene-management #transform #operators #primitives*

