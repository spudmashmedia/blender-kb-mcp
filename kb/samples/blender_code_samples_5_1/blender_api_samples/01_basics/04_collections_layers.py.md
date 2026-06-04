---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, collections, layers, viewport, hierarchy]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/02_context_validation.py.md]
difficulty: intermediate
categories: [collections, layers, viewport, scene organization]
last_updated: 2026-04-29
search_keywords: [collection management, layer collection, view visibility, hide_viewport, link object to collection, bpy.data.collections.new, children.link, hide_render, find_layer_collection, recursive search, scene hierarchy, view layer]
---

# Collections & Layers Management - Blender 5.1 API Sample
## Purpose
Demonstrates how to create collections, link objects to collections, and manage layer collection visibility in the viewport using Blender 5.1's updated hierarchy system.

## Use Cases
- Organizing scene objects into logical groups for rendering or view management
- Creating independent object instances that can be hidden/show independently via collections
- Batch operations on grouped objects (select, hide, exclude from render)
- Managing view layer visibility without affecting data blocks

## Basic Example

```python
import bpy

def basic_collection_example():
    """Create collections and link objects to them"""
    
    # Clean up test objects first
    for obj in list(bpy.data.objects):
        if "Test" in obj.name:
            bpy.data.objects.remove(obj)
    
    # Create two separate cubes
    bpy.ops.mesh.primitive_cube_add(location=(0, 0, 1))
    cube_a = bpy.context.active_object
    cube_a.name = "Test Cube A"
    
    bpy.ops.mesh.primitive_cube_add(location=(2, 0, 1))
    cube_b = bpy.context.active_object
    cube_b.name = "Test Cube B"
    
    # Create collections for each
    coll_a = bpy.data.collections.new("Collection A")
    coll_b = bpy.data.collections.new("Collection B")
    bpy.context.scene.collection.children.link(coll_a)
    bpy.context.scene.collection.children.link(coll_b)
    
    # Link different objects to each collection
    coll_a.objects.link(cube_a)
    coll_b.objects.link(cube_b)
    
    print(f"Cube A: {cube_a.name} in {len(coll_a.objects)} collection(s)")
    print(f"Cube B: {cube_b.name} in {len(coll_b.objects)} collection(s)")

basic_collection_example()
```

## Advanced Example

```python
import bpy
from mathutils import Vector, Euler

def advanced_collection_management(context):
    """Production-ready collection management with error handling"""
    
    try:
        view_layer = context.view_layer
        
        # Clean up any existing test collections/objects
        for obj in list(bpy.data.objects):
            if "Test" in obj.name or "Collection" in obj.name:
                bpy.data.objects.remove(obj)
        
        for coll in list(bpy.data.collections):
            if "Test" in coll.name:
                # Unlink all objects first
                for obj in list(coll.objects):
                    view_layer.objects.unlink(obj)
                bpy.data.collections.remove(coll)
        
        # Create collections with proper hierarchy
        root_coll = bpy.context.scene.collection
        
        test_coll_a = bpy.data.collections.new("Test Collection A")
        test_coll_b = bpy.data.collections.new("Test Collection B")
        
        # Link to scene
        root_coll.children.link(test_coll_a)
        root_coll.children.link(test_coll_b)
        
        # Create objects and link to collections
        bpy.ops.mesh.primitive_cube_add(location=(0, 0, 1))
        cube_a = context.active_object
        cube_a.name = "Test Cube A"
        test_coll_a.objects.link(cube_a)
        
        bpy.ops.mesh.primitive_cube_add(location=(2, 0, 1))
        cube_b = context.active_object
        cube_b.name = "Test Cube B"
        test_coll_b.objects.link(cube_b)
        
        # Find layer collections for visibility control (BLENDER 5.1)
        def find_layer_collection(layer_col, name):
            """Recursively search LayerCollection hierarchy"""
            if layer_col.name == name:
                return layer_col
            for child in layer_col.children:
                result = find_layer_collection(child, name)
                if result:
                    return result
            return None
        
        # Control viewport visibility via LayerCollection (BLENDER 5.1 feature)
        layer_coll_a = find_layer_collection(view_layer.layer_collection, "Test Collection A")
        if layer_coll_a:
            layer_coll_a.hide_viewport = True
            print(f"✓ Hide Collection A in viewport")
        
        # Verify independence - objects remain accessible via their data blocks
        print(f"\nObject Data Blocks:")
        print(f"  Cube A mesh ID: {id(cube_a.data)}")
        print(f"  Cube B mesh ID: {id(cube_b.data)}")
        print(f"  Objects independent: {cube_a is not cube_b}")
        
        # Restore visibility
        if layer_coll_a:
            layer_coll_a.hide_viewport = False
        
        return True
        
    except Exception as e:
        print(f"Error in collection management: {e}")
        import traceback
        traceback.print_exc()
        return False

# Usage in Blender text editor or script console
if __name__ == "__main__":
    advanced_collection_management(bpy.context)
```

## Key API Elements Used
|Element|	Description|
|---|---|
|bpy.data.collections.new(name)|	Creates a new collection data-block|
|bpy.context.scene.collection.children.link(collection)|	Adds collection as child of scene root|
|Collection.objects.link(object)|	Links object to collection (BLENDER 5.1)|
|LayerCollection.hide_viewport|	Temporarily hide in viewport (BLENDER 5.1, bool property)|
|view_layer.layer_collection|	Root LayerCollection for the current view layer|
|bpy.data.objects.remove(obj)|	Removes object from scene and data-blocks|

## Common Pitfalls & Solutions
|Problem|	Solution|
|---|---|
|Objects not appearing after linking to collection|	Verify hide_viewport is False on LayerCollection, check view layer|
|Collection visibility doesn't affect render|	Use collection.hide_render for render control (separate from viewport)|
|Objects persist in memory after deletion|	Ensure all references are cleared before removing data-blocks|
|LayerCollection not found by name|	Implement recursive search through children hierarchy|
|Multiple collections containing same object|	This is valid - objects can belong to multiple collections simultaneously|

## Related Functions
- See also: 01_basics/02_object_properties.py.md for custom properties on collections
- See also: 08_error_handling_patterns/02_context_validation.py.md for context checks

*Tags: #objects #collections #layers #viewport #BLENDER_5.1*
