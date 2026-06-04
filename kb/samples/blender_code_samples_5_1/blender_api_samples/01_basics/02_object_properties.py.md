---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, properties, custom-data, materials, constraints, collections, animation]
related_files: [01_scene_objects.py.md, 03_materials_textures.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [properties, materials, constraints, collections, custom_data]
last_updated: 2026-04-29
search_keywords: [custom property, material creation, node tree, copy location constraint, damped track, collection organization, object visibility, obj["prop"], bpy.data.materials.new, mat.use_nodes, constraints.new, mute, collections.link, move_object_to_collection]
---

# Object Properties - Custom Data, Materials & Constraints Management in Blender 5.1

## Purpose
This module demonstrates comprehensive object property management in Blender's Python API, including custom properties, materials with node trees, constraints (COPY_LOCATION, Damped Track), and collection organization.

## Use Cases
- Storing user-defined data on objects via custom properties
- Creating materials programmatically with proper node tree setup
- Adding and managing object constraints for animation/rigging
- Organizing objects into collections for scene management
- Toggling object visibility programmatically

## Basic Example

```python
"""
Blender 5.1 API - Object Properties Management
Category: #objects #properties #custom-data #materials #constraints

This script demonstrates managing various properties of objects including custom data, constraints, materials, and collections.
"""

import bpy
from mathutils import Vector, Euler
from typing import List, Optional


def create_cube(name: str = "Cube", location=(0, 0, 0), size=2.0) -> bpy.types.Object:
    """Create a cube object and return the reference."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    
    bpy.ops.mesh.primitive_cube_add(
        size=size,
        location=location,
        align='WORLD'
    )
    
    new_obj = bpy.context.active_object
    if new_obj:
        new_obj.name = name
    
    return new_obj


def create_sphere(name: str = "Sphere", radius: float = 1.0, location=(0, 0, 0)) -> bpy.types.Object:
    """Create a UV sphere with custom radius."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=32,
        ring_count=16,
        radius=radius,
        location=location,
        align='WORLD'
    )
    
    new_obj = bpy.context.active_object
    if new_obj:
        new_obj.name = name
    
    return new_obj


def set_custom_property(obj_name: str, prop_name: str, value):
    """Set a custom property on an object (user-defined data)."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    obj[prop_name] = value
    print(f"✓ Set custom property '{prop_name}' on {obj.name}: {value}")
    return True


def get_custom_property(obj_name: str, prop_name: str, default=None):
    """Get a custom property from an object with fallback."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return None
    
    obj = bpy.data.objects[obj_name]
    value = obj.get(prop_name, default)
    
    if prop_name in obj:
        print(f"  Found custom property '{prop_name}': {value}")
    else:
        print(f"  Custom property '{prop_name}' not found (using default)")
    
    return value


def list_custom_properties(obj_name: str):
    """List all custom properties on an object."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return []
    
    obj = bpy.data.objects[obj_name]
    custom_props = {k: v for k, v in obj.items() if k.startswith('custom_')}
    
    print(f"\n=== Custom Properties on {obj.name} ===")
    if custom_props:
        for key, value in custom_props.items():
            print(f"  {key}: {value}")
    else:
        print("  No custom properties found")
    
    return list(custom_props.keys())


def remove_custom_property(obj_name: str, prop_name: str):
    """Remove a custom property from an object."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    if prop_name in obj:
        del obj[prop_name]
        print(f"✓ Removed custom property '{prop_name}' from {obj.name}")
        return True
    else:
        print(f"✗ Custom property '{prop_name}' not found on {obj.name}")
        return False


def assign_material_to_object(obj_name: str, material_name: str):
    """Assign a material to an object's first material slot."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    if material_name not in bpy.data.materials:
        print(f"✗ Material '{material_name}' does not exist")
        return False
    
    mat = bpy.data.materials[material_name]
    obj.data.materials.append(mat)
    print(f"✓ Assigned material '{mat.name}' to {obj.name} ({len(obj.data.materials)} materials)")
    return True


def create_material(name: str, color=(0.8, 0.2, 0.2)):
    """Create a new material with basic properties using node tree."""
    if name in bpy.data.materials:
        print(f"Material '{name}' already exists")
        return bpy.data.materials[name]
    
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    
    # Properly set up the node tree (Principled BSDF connected to Output Material)
    if mat.use_nodes:
        nodes = mat.node_tree.nodes
        links = mat.node_tree.links
        
        # Clear default nodes
        for n in list(nodes):
            nodes.remove(n)
        
        # Create Principled BSDF node
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        
        # Create Output Material node
        output = nodes.new(type='ShaderNodeOutputMaterial')
        output.location = (300, 0)
        
        # Link BSDF to Output
        links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
    
    print(f"✓ Created material '{name}'")
    return mat


def add_constraint(obj_name: str, constraint_type: str, target_obj_name: Optional[str] = None):
    """Add a constraint to an object."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    if target_obj_name and target_obj_name in bpy.data.objects:
        target = bpy.data.objects[target_obj_name]
    else:
        target = None
    
    try:
        if constraint_type == 'COPY_LOCATION':
            con = obj.constraints.new('COPY_LOCATION')
            con.target = target
        
        elif constraint_type == 'COPY_ROTATION':
            con = obj.constraints.new('COPY_ROTATION')
            con.target = target
        
        elif constraint_type == 'COPY_SCALE':
            con = obj.constraints.new('COPY_SCALE')
            con.target = target
        
        elif constraint_type == 'LIMIT_LOCATION':
            con = obj.constraints.new('LIMIT_LOCATION')
            con.use_min_x = True
            con.min_x = -10.0
            con.use_max_x = True
            con.max_x = 10.0
        
        elif constraint_type == 'Damped Track':
            con = obj.constraints.new('DAMPED_TRACK')
            con.target_axis = 'Y'
            con.track_axis = '-Z'
        
        else:
            print(f"✗ Unknown constraint type: {constraint_type}")
            return False
        
        # Use mute to enable/disable constraint (verified in Blender 5.1 docs)
        con.mute = False
        print(f"✓ Added '{constraint_type}' constraint on {obj.name}")
        return True
    
    except Exception as e:
        print(f"✗ Failed to add constraint: {e}")
        return False


def remove_constraint(obj_name: str, constraint_type: str):
    """Remove a specific type of constraint from an object."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    removed_count = 0
    for con in list(obj.constraints):
        if con.type == constraint_type:
            obj.constraints.remove(con)
            removed_count += 1
    
    print(f"✓ Removed {removed_count} '{constraint_type}' constraint(s) from {obj.name}")
    return removed_count > 0


def list_constraints(obj_name: str):
    """List all constraints on an object."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return []
    
    obj = bpy.data.objects[obj_name]
    
    print(f"\n=== Constraints on {obj.name} ===")
    if obj.constraints:
        for i, con in enumerate(obj.constraints, 1):
            target_name = con.target.name if con.target else "None"
            # Use mute property (not use_mute) - verified in Blender 5.1 docs
            enabled = "✓" if not con.mute else "✗"
            print(f"{i}. [{enabled}] {con.type} → Target: {target_name}")
    else:
        print("  No constraints on this object")
    
    return [con.type for con in obj.constraints]


def move_object_to_collection(obj_name: str, collection_name: str):
    """Move an object to a specific collection."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    # Get or create target collection
    if collection_name in bpy.data.collections:
        coll = bpy.data.collections[collection_name]
    else:
        coll = bpy.data.collections.new(name=collection_name)
        print(f"  Created new collection: {collection_name}")
        bpy.context.scene.collection.children.link(coll)
    
    # Remove from all collections first, then add to target
    for c in obj.users_collection:
        c.objects.unlink(obj)
    
    coll.objects.link(obj)
    print(f"✓ Moved '{obj.name}' to collection '{collection_name}'")
    return True


def get_all_collections():
    """List all collections in the current scene."""
    print("\n=== Collections ===")
    for i, col in enumerate(bpy.data.collections, 1):
        obj_count = len(col.objects)
        print(f"{i}. {col.name:20s} | Objects: {obj_count}")
    return [col.name for col in bpy.data.collections]


def get_object_collections(obj_name: str):
    """Get all collections an object belongs to."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return []
    
    obj = bpy.data.objects[obj_name]
    collections = [col.name for col in obj.users_collection]
    
    print(f"\n=== Collections containing {obj.name} ===")
    if collections:
        for col_name in collections:
            print(f"  - {col_name}")
    else:
        print("  Object not in any collection (unlinked)")
    
    return collections


def set_object_visibility(obj_name: str, visible: bool = True):
    """Set object visibility (in viewport)."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    obj.hide_viewport = not visible
    obj.hide_select = not visible
    
    status = "hidden" if not visible else "visible"
    print(f"✓ {obj.name.capitalize()} is now {status}")
    return True


def main():
    """Execute all demonstration functions."""
    # Clear scene first (optional)
    for obj in list(bpy.data.objects):
        if obj.type not in ('CAMERA', 'LIGHT'):
            bpy.data.objects.remove(obj, do_unlink=True)
    
    print("=== Object Properties Demo ===\n")
    
    # Create objects to work with
    cube = create_cube(name="PropertyCube", location=(0, 0, 0))
    sphere = create_sphere(name="PropSphere", radius=1.0, location=(3, 0, 0))
    
    # Set custom properties on cube
    set_custom_property("PropertyCube", "custom_type", "building")
    set_custom_property("PropertyCube", "custom_height", 50)
    set_custom_property("PropertyCube", "custom_color", "#FF5733")
    
    # List and retrieve custom properties
    list_custom_properties("PropertyCube")
    height = get_custom_property("PropertyCube", "custom_height", default=0)
    print(f"  Retrieved custom_height: {height}\n")
    
    # Create material
    blue_mat = create_material("BlueMat", color=(0.2, 0.5, 0.8))
    assign_material_to_object("PropertyCube", "BlueMat")
    
    # Add constraints
    add_constraint("PropSphere", 'COPY_LOCATION', target_obj_name="PropertyCube")
    add_constraint("PropSphere", 'DAMPED_TRACK')
    
    # List all constraints on the sphere
    list_constraints("PropSphere")
    
    # Move object to new collection
    move_object_to_collection("PropertyCube", "CustomObjects")
    get_all_collections()
    
    # Get collections for sphere
    get_object_collections("PropSphere")
    
    # Set visibility
    set_object_visibility("PropertyCube", visible=False)
    set_object_visibility("PropertyCube", visible=True)
    
    print("\n=== Demo Complete ===\n")


# Execute when run directly in Blender Text Editor
if __name__ == "__main__":
    main()

```

## Advanced Example
```python
import bpy
from mathutils import Vector, Euler
from typing import List, Optional

def create_cube(name: str = "Cube", location=(0, 0, 0), size=2.0) -> bpy.types.Object:
    """Create a cube object and return the reference."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    
    bpy.ops.mesh.primitive_cube_add(
        size=size,
        location=location,
        align='WORLD'
    )
    
    new_obj = bpy.context.active_object
    if new_obj:
        new_obj.name = name
    
    return new_obj

def create_sphere(name: str = "Sphere", radius: float = 1.0, location=(0, 0, 0)) -> bpy.types.Object:
    """Create a UV sphere with custom radius."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)
    
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=32,
        ring_count=16,
        radius=radius,
        location=location,
        align='WORLD'
    )
    
    new_obj = bpy.context.active_object
    if new_obj:
        new_obj.name = name
    
    return new_obj

def create_material(name: str, color=(0.8, 0.2, 0.2)) -> bpy.types.Material:
    """Create a new material with basic properties using node tree."""
    if name in bpy.data.materials:
        print(f"Material '{name}' already exists")
        return bpy.data.materials[name]
    
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    
    if mat.use_nodes:
        nodes = mat.node_tree.nodes
        links = mat.node_tree.links
        
        for n in list(nodes):
            nodes.remove(n)
        
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        
        output = nodes.new(type='ShaderNodeOutputMaterial')
        output.location = (300, 0)
        
        links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
    
    return mat

def add_constraint(obj_name: str, constraint_type: str, target_obj_name=None):
    """Add a constraint to an object. FIXED VERSION"""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    try:
        if constraint_type == 'COPY_LOCATION':
            con = obj.constraints.new('COPY_LOCATION')
            if target_obj_name and target_obj_name in bpy.data.objects:
                con.target = bpy.data.objects[target_obj_name]
        
        elif constraint_type == 'DAMPED_TRACK':
            con = obj.constraints.new('DAMPED_TRACK')
            con.track_axis = 'TRACK_NEGATIVE_Z'  # FIXED: proper enum value
            
            if target_obj_name and target_obj_name in bpy.data.objects:
                con.target = bpy.data.objects[target_obj_name]
        
        else:
            print(f"✗ Unknown constraint type: {constraint_type}")
            return False
        
        con.mute = False  # Verified for Blender 5.1
        print(f"✓ Added '{constraint_type}' constraint on {obj.name}")
        return True
    
    except Exception as e:
        print(f"✗ Failed to add constraint: {e}")
        import traceback
        traceback.print_exc()
        return False

def set_custom_property(obj_name: str, prop_name: str, value):
    """Set a custom property on an object (user-defined data)."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    # Dictionary-style access works automatically - no update call needed!
    obj[prop_name] = value
    
    print(f"✓ Set custom property '{prop_name}' on {obj.name}: {value}")
    return True

def move_object_to_collection(obj_name: str, collection_name: str):
    """Move an object to a specific collection."""
    if obj_name not in bpy.data.objects:
        print(f"✗ Object '{obj_name}' not found")
        return False
    
    obj = bpy.data.objects[obj_name]
    
    if collection_name in bpy.data.collections:
        coll = bpy.data.collections[collection_name]
    else:
        coll = bpy.data.collections.new(name=collection_name)
        bpy.context.scene.collection.children.link(coll)
    
    for c in obj.users_collection:
        c.objects.unlink(obj)
    
    coll.objects.link(obj)
    print(f"✓ Moved '{obj.name}' to collection '{collection_name}'")
    return True

def test_script():
    """Test function to verify all fixes work correctly."""
    print("=== Advanced Script Test ===\n")
    
    # Clear scene first (optional)
    for obj in list(bpy.data.objects):
        if obj.type not in ('CAMERA', 'LIGHT'):
            bpy.data.objects.remove(obj, do_unlink=True)
    
    # Create test objects
    cube = create_cube("TestCube", location=(0, 0, 0))
    target = create_sphere("TargetSphere", radius=0.5, location=(3, 0, 0))
    
    print(f"✓ Created {cube.name} at {cube.location}")
    print(f"✓ Created {target.name} at {target.location}\n")
    
    # Test custom properties (dictionary access works automatically!)
    set_custom_property("TestCube", "custom_type", "building")
    set_custom_property("TestCube", "custom_height", 50)
    print()
    
    # Test material creation
    blue_mat = create_material("BlueMat", color=(0.2, 0.5, 0.8))
    cube.data.materials.append(blue_mat)
    print(f"✓ Assigned {blue_mat.name} to {cube.name}\n")
    
    # Test constraints - FIXED VERSION
    print("--- Testing Constraints ---")
    add_constraint("TestCube", 'COPY_LOCATION', target_obj_name="TargetSphere")
    add_constraint("TestCube", 'DAMPED_TRACK', target_obj_name="TargetSphere")
    
    # Verify constraints were added correctly
    print("\n--- Verifying Constraints on TestCube ---")
    for i, con in enumerate(bpy.data.objects["TestCube"].constraints, 1):
        if hasattr(con, 'track_axis'):
            print(f"{i}. {con.type} - track_axis: {con.track_axis}")
        else:
            print(f"{i}. {con.type}")
    
    # Test collection management
    move_object_to_collection("TestCube", "CustomObjects")
    print()
    
    # Select cube so its custom properties appear in Object Properties panel
    bpy.context.view_layer.objects.active = cube
    cube.select_set(True)
    for obj in bpy.context.scene.objects:
        if obj.name != "TestCube":
            obj.select_set(False)
    
    print("✓ Test Complete - Check Object Properties > Custom Properties section\n")

# Execute test when run directly in Blender Text Editor
if __name__ == "__main__":
    test_script()

```

## Key API Elements Used

|Element|	Description|	Usage|
|---|---|---|
|obj["prop"] = value|	Set custom property (dictionary-like access)|	User-defined data storage on objects|
|obj.get("prop", default)|	Get custom property with fallback|	Safe retrieval without KeyError|
|bpy.data.materials.new(name)|	Create new material block|	Material creation for assignment|
|mat.use_nodes = True|	Enable node-based shading|	Required for shader network setup|
|nodes.new(type='ShaderNodeBsdfPrincipled')|	Create Principled BSDF node|	Modern Blender material workflow|
|links.new(output, input)	Link nodes together|	Connect BSDF to Output Material|
|obj.constraints.new('COPY_LOCATION')|	Add constraint via API|	Constraint creation for animation|
|con.mute = False|	Enable/disable constraint|	Use .mute property (not .use_mute)|
|coll.objects.link(obj)|	Add object to collection|	Collection-based scene organization|
|obj.users_collection|	Get all collections containing object|	Read-only access to parent collections|

## Common Pitfalls & Solutions (Blender 5.1)

| Problem | Cause | Solution |
|---------|-------|----------|
| `track_axis` value error | Used invalid string like `'-Z'` | Use proper enum: `'TRACK_NEGATIVE_Z'`, `'TRACK_X'`, etc. |
| Damped Track not tracking target | Missing target assignment | Add conditional check: `if target_obj_name and target in bpy.data.objects: con.target = ...` |
| Custom properties not visible in UI | Object not selected as active | Select object with `bpy.context.view_layer.objects.active = obj` before checking panel |
| Constraint type string error | Used display name instead of API constant | Use uppercase with underscores: `'DAMPED_TRACK'`, NOT `'Damped Track'` |
| AttributeError on constraint mute | Tried using `.use_mute` property | Use `.mute = False/True` in Blender 5.1 (verified in official docs) |

## Related Functions & Files
- See also: 01_basics/01_scene_objects.py.md for basic object creation and transforms
- See also: 01_basics/02_object_properties.py.md (this file) - full properties management
- See also: 08_error_handling_patterns/01_safe_operations.py.md for error handling templates

## Official Blender Documentation
- [bpy.types.Object.constraints](https://docs.blender.org/api/current/bpy.types.Object.html)
- [Custom Properties API Reference](https://docs.blender.org/api/current/bpy.types.PropertyGroup.html)


## Blender Version Notes

- **Tested**: Blender 5.1
- **Constraint API**: Uses .mute property (not .use_mute) to enable/disable constraints - verified in official docs
- **Material Nodes**: Must explicitly create node tree connections after enabling use_nodes
- **Custom Properties**: Dictionary-like access with .get() method for safe retrieval with defaults
- **Collection Management**: Objects can belong to multiple collections simultaneously

### Constraint API Reference Table (Blender 5.1)

| Property | Valid Values | Notes |
|----------|--------------|-------|
| `constraint_type` string for `new()` | `'DAMPED_TRACK'`, `'COPY_LOCATION'`, etc. | Use uppercase with underscores, not display names like `'Damped Track'` ❌ |
| `track_axis` (DampedTrackConstraint) | `'TRACK_X'`, `'TRACK_Y'`, `'TRACK_Z'`, `'TRACK_NEGATIVE_X'`, `'TRACK_NEGATIVE_Y'`, `'TRACK_NEGATIVE_Z'` | ❌ NOT `'-Z'` or `'-X'` - must use TRACK_* enum values |
| `.mute` property | `True/False` | ✅ Use `.mute` (not `.use_mute`) in Blender 5.1 |

*Tags: #objects #properties #custom-data #materials #constraints #collections #animation #node-trees #blender51*
