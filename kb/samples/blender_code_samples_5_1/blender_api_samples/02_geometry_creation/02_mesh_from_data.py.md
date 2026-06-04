---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, geometry, creation, bmesh, mesh-data]
related_files: [02_geometry_creation/01_bmesh_primitives.py.md, 07_advanced_geometry/01_vertex_editing.py.md]
difficulty: intermediate
categories: [geometry, meshes, creation, data-structures]
last_updated: 2024-01-15
search_keywords: [create mesh, from_pydata, vertex data, polygon indices, mesh object, programmatic geometry]
---

# Mesh Creation from Data - Blender 5.1 API Sample

## Purpose
This document demonstrates how to create mesh objects programmatically using Blender's Python API by defining vertex coordinates and face connectivity data. It covers both basic usage for learning purposes and advanced production-ready patterns with error handling, context validation, and optional features like UV mapping and vertex colors.


### Key Concepts:

- Creating mesh data-blocks independent of objects
- Defining geometry via from_pydata() method
- Converting vertex/face definitions to visible 3D objects
- Safe object management in Blender's scene graph

## Use Cases
|Use Case|	Description|	Recommended Version|
|---|---|---|
|Quick Prototyping|	Create simple shapes for testing or visualization|	Basic Example|
|Procedural Generation|	Generate geometry algorithmically from parameters	|Advanced Example|
|Add-on Development|	Production tools requiring error handling and validation|	Advanced Example|
|Batch Processing Scripts|	Process multiple files without manual intervention|	Advanced Example|
|Learning Blender API|	Understand mesh data structure and object lifecycle	|
Basic Example|

## Basic Example
```python
"""
Basic Mesh Creation from Data - Blender 5.1 API Sample
Demonstrates creating mesh geometry using from_pydata() method
"""

import bpy
from mathutils import Vector

def basic_example():
    """Create a simple cube and pyramid from vertex/face data"""
    
    # Clean up any previous test objects
    for obj in ['MeshFromData_Cube', 'MeshFromData_Pyramid']:
        if obj in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[obj], do_unlink=True)
    
    print("=== Creating Mesh from Data ===")
    
    # ------------------------------------------------------------------
    # Example 1: Create a Cube using from_pydata()
    # ------------------------------------------------------------------
    cube_name = "MeshFromData_Cube"
    
    # Define vertices (x, y, z coordinates for each corner)
    vertices = [
        (-1.0, -1.0, -1.0),  # 0: Bottom-left-back
        ( 1.0, -1.0, -1.0),  # 1: Bottom-right-back
        (-1.0,  1.0, -1.0),  # 2: Top-left-back
        ( 1.0,  1.0, -1.0),  # 3: Top-right-back
        (-1.0, -1.0,  1.0),  # 4: Bottom-left-front
        ( 1.0, -1.0,  1.0),  # 5: Bottom-right-front
        (-1.0,  1.0,  1.0),  # 6: Top-left-front
        ( 1.0,  1.0,  1.0),  # 7: Top-right-front
    ]
    
    # Define faces as lists of vertex indices (polygon loops)
    polygons = [
        [0, 1, 3, 2],  # Back face
        [4, 5, 7, 6],  # Front face
        [0, 1, 5, 4],  # Bottom face
        [2, 3, 7, 6],  # Top face
        [0, 2, 6, 4],  # Left face
        [1, 3, 7, 5],  # Right face
    ]
    
    # Create new mesh data-block
    mesh = bpy.data.meshes.new(cube_name)
    
    # Populate mesh with vertex and polygon data
    mesh.from_pydata(vertices, [], polygons)
    
    # Update mesh to calculate edge loops and normals
    mesh.update()
    
    # Create object from the mesh
    cube_obj = bpy.data.objects.new(cube_name, mesh)
    
    # Link object to current collection (make it visible in 3D Viewport)
    if hasattr(bpy.context, 'collection') and bpy.context.collection:
        bpy.context.collection.objects.link(cube_obj)
    
    print(f"✓ Cube created: {len(mesh.vertices)} vertices, {len(mesh.polygons)} faces")
    
    # ------------------------------------------------------------------
    # Example 2: Create a Pyramid from data (diamond base orientation)
    # ------------------------------------------------------------------
    pyramid_name = "MeshFromData_Pyramid"
    
    # Diamond-shaped base + apex above center (appears rotated 45° on Z-axis)
    pyramid_vertices = [
        (-1.5, 0.0, 0.0),   # 0: Base front-left (diamond point)
        ( 0.0, 1.5, 0.0),   # 1: Base top-right (diamond point)
        ( 1.5, 0.0, 0.0),   # 2: Base back-right (diamond point)
        ( 0.0,-1.5, 0.0),   # 3: Base bottom-left (diamond point)
        ( 0.0, 0.0, 2.0),    # 4: Pyramid apex (peak)
    ]
    
    pyramid_polygons = [
        [0, 1, 4],           # Side face front-right
        [1, 2, 4],           # Side face back-right
        [2, 3, 4],           # Side face back-left
        [3, 0, 4],           # Side face front-left
        [0, 1, 2, 3],        # Base (quad)
    ]
    
    pyramid_mesh = bpy.data.meshes.new(pyramid_name)
    pyramid_mesh.from_pydata(pyramid_vertices, [], pyramid_polygons)
    pyramid_mesh.update()
    
    pyramid_obj = bpy.data.objects.new(pyramid_name, pyramid_mesh)
    
    if hasattr(bpy.context, 'collection') and bpy.context.collection:
        bpy.context.collection.objects.link(pyramid_obj)
    
    print(f"✓ Pyramid created: {len(pyramid_mesh.vertices)} vertices, {len(pyramid_mesh.polygons)} faces")
    
    # ------------------------------------------------------------------
    # Summary Output
    # ------------------------------------------------------------------
    print("\n=== Objects in Scene ===")
    for obj in bpy.context.collection.objects:
        if isinstance(obj.data, bpy.types.Mesh):
            mesh_data = obj.data
            print(f"  {obj.name}: {len(mesh_data.vertices)} verts, {len(mesh_data.polygons)} faces")

# Run the basic example
if __name__ == "__main__":
    basic_example()

```

## Advanced Example
```python
"""
Advanced Mesh Creation from Data - Blender 5.1 API Sample
Production-ready implementation with error handling and context validation
"""

import bpy
from mathutils import Vector, Matrix
from typing import List, Tuple, Optional, Dict, Any

# ============================================================================
# Type Hints for Better IDE Support
# ============================================================================
Vertex = Tuple[float, float, float]  # (x, y, z) coordinates
FaceIndices = List[int]              # Polygon vertex indices
MeshDataDict = Dict[str, Any]        # Mesh data structure


class MeshCreationError(Exception):
    """Custom exception for mesh creation failures"""
    pass


def validate_mesh_data(
    vertices: List[Vertex], 
    edges: List[Tuple[int, int]], 
    polygons: List[FaceIndices]
) -> Tuple[bool, str]:
    """
    Validate mesh data before creating mesh object
    
    Args:
        vertices: List of (x, y, z) vertex coordinates
        edges: List of edge index pairs (optional for this example)
        polygons: List of polygon vertex indices
        
    Returns:
        Tuple[bool, str]: (is_valid, error_message)
    """
    
    if not vertices:
        return False, "Mesh must have at least one vertex"
    
    if not polygons:
        return False, "Mesh must have at least one face/polygon"
    
    # Validate polygon indices are within range
    max_vertex_index = len(vertices) - 1
    for i, poly in enumerate(polygons):
        for vert_idx in poly:
            if not (0 <= vert_idx <= max_vertex_index):
                return False, f"Polygon {i} contains invalid vertex index {vert_idx}"
    
    # Check for degenerate faces (single or duplicate vertices)
    for i, poly in enumerate(polygons):
        unique_verts = set(poly)
        if len(unique_verts) < 3:
            return False, f"Polygon {i} has fewer than 3 unique vertices (degenerate)"
    
    return True, "Valid mesh data"


def create_mesh_from_data(
    name: str,
    vertices: List[Vertex],
    polygons: List[FaceIndices],
    edges: Optional[List[Tuple[int, int]]] = None,
    location: Vector = Vector((0.0, 0.0, 0.0)),
    rotation_euler: Optional[Vector] = None,
    scale: Vector = Vector((1.0, 1.0, 1.0)),
    enable_uvs: bool = False,
    enable_vertex_colors: bool = False,
    collection_name: str = "Collection",
    cleanup_existing: bool = True,
    log_level: int = 2  # 0=none, 1=errors only, 2=full output
) -> Optional[bpy.types.Object]:
    """
    Create a mesh object from vertex and polygon data with safety checks
    
    Production Features:
        - Context validation (collection existence, scene state)
        - Data validation before creation
        - Transaction-safe cleanup of existing objects
        - Optional UV map and vertex color layers
        - Comprehensive logging for debugging
        
    Args:
        name: Name for the new mesh object
        vertices: List of 3D coordinates [(x,y,z), ...]
        polygons: List of face indices [[0,1,2], [0,1,3], ...]
        edges: Optional list of edge pairs [(v1,v2), ...] (default [])
        location: Vector for object position in world space
        rotation_euler: Optional Euler rotation (x,y,z)
        scale: Vector scaling factors (x,y,z)
        enable_uvs: Whether to create UV map layer
        enable_vertex_colors: Whether to create vertex color layer
        collection_name: Name of target collection for linking
        cleanup_existing: Remove existing object with same name first
        log_level: Logging verbosity level
        
    Returns:
        bpy.types.Object on success, None on failure
        
    Raises:
        MeshCreationError: On validation or creation failures
    """
    
    # Log output helper
    def log(msg: str):
        if log_level >= 2:
            print(f"[Mesh Creation] {msg}")
        elif log_level == 1 and "ERROR" in msg:
            print(f"[Mesh ERROR] {msg}")

    try:
        # ==========================================================================
        # STEP 1: Context Validation - Blender 5.1 Safe Checks
        # ==========================================================================
        
        if not hasattr(bpy.context, 'collection') or bpy.context.collection is None:
            log("ERROR: Cannot access current collection")
            return None
        
        target_collection = bpy.context.collection
        
        if collection_name != "Collection":
            try:
                target_collection = bpy.data.collections[collection_name]
                log(f"Using custom collection: {collection_name}")
            except KeyError:
                log(f"ERROR: Collection '{collection_name}' not found")
                return None
        
        # ==========================================================================
        # STEP 2: Data Validation - Prevent Invalid Mesh Creation
        # ==========================================================================
        
        is_valid, validation_msg = validate_mesh_data(vertices, edges or [], polygons)
        if not is_valid:
            log(f"ERROR: {validation_msg}")
            raise MeshCreationError(validation_msg)
        
        log(f"✓ Data validation passed: {len(vertices)} verts, {len(polygons)} faces")
        
        # ==========================================================================
        # STEP 3: Cleanup Existing Object (if requested) - Transaction Safe
        # ==========================================================================
        
        if cleanup_existing and name in bpy.data.objects:
            existing_obj = bpy.data.objects[name]
            log(f"Cleaning up existing object: {name}")
            
            if bpy.context.object == existing_obj:
                bpy.ops.object.mode_set(mode='OBJECT')
                
            for col in bpy.data.collections:
                if existing_obj in col.objects:
                    try:
                        col.objects.unlink(existing_obj)
                    except RuntimeError as e:
                        log(f"WARNING: Could not unlink from {col.name}: {e}")
            
            bpy.data.objects.remove(existing_obj, do_unlink=True)
            log(f"✓ Removed existing object")
        
        # ==========================================================================
        # STEP 4: Create Mesh Data Block - Core Blender API Call
        # ==========================================================================
        
        mesh = bpy.data.meshes.new(name)
        log(f"Created mesh data-block: {name}")
        
        mesh.from_pydata(vertices, edges or [], polygons)
        mesh.update()
        
        # ==========================================================================
        # STEP 5: Optional UV Map Layer Creation
        # ==========================================================================
        
        if enable_uvs and len(mesh.polygons) > 0:
            try:
                uv_layer = mesh.uv_layers.new(name="UVMap")
                log(f"✓ Created UV map layer: {uv_layer.name}")
                
                for poly in mesh.polygons:
                    for loop_idx in poly.loop_indices:
                        uv_layer.data[loop_idx].uv = (0.5, 0.5)
                        
            except Exception as e:
                log(f"WARNING: UV map creation failed: {e}")
        
        # ==========================================================================
        # STEP 6: Optional Vertex Color Layer Creation
        # ==========================================================================
        
        if enable_vertex_colors and len(mesh.vertices) > 0:
            try:
                color_layer = mesh.color_attributes.new(
                    name="Color", 
                    type='COLOR',
                    domain='POINT'
                )
                log(f"✓ Created vertex color layer: {color_layer.name}")
                
                for vert in mesh.vertices:
                    color_layer.data[vert.index].color = (1.0, 0.0, 0.0, 1.0)
                    
            except Exception as e:
                log(f"WARNING: Vertex color creation failed: {e}")
        
        # ==========================================================================
        # STEP 7: Create Object and Apply Transforms
        # ==========================================================================
        
        obj = bpy.data.objects.new(name, mesh)
        obj.location = location
        
        if rotation_euler is not None:
            obj.rotation_mode = 'XYZ'
            obj.rotation_euler = Vector(rotation_euler)
        
        obj.scale = scale
        
        log(f"✓ Object created with transforms")
        
        # ==========================================================================
        # STEP 8: Link to Collection - Make Visible in Viewport
        # ==========================================================================
        
        try:
            target_collection.objects.link(obj)
            log(f"✓ Linked object to collection")
            
            bpy.context.view_layer.objects.active = obj
            
        except RuntimeError as e:
            log(f"ERROR: Could not link to collection: {e}")
            raise MeshCreationError(f"Collection linking failed: {e}")
        
        return obj
        
    except MeshCreationError as e:
        raise
    except Exception as e:
        log(f"ERROR: Unexpected failure during mesh creation: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        return None


def advanced_example():
    """Demonstrate production-ready mesh creation with all features"""
    
    print("=" * 60)
    print("ADVANCED MESH CREATION EXAMPLE - Blender 5.1 API")
    print("=" * 60)
    
    try:
        # --------------------------------------------------------------------------
        # Example 1: Cube with UV Mapping and Vertex Colors
        # --------------------------------------------------------------------------
        
        cube_vertices = [
            (-1.0, -1.0, -1.0), ( 1.0, -1.0, -1.0),
            (-1.0,  1.0, -1.0), ( 1.0,  1.0, -1.0),
            (-1.0, -1.0,  1.0), ( 1.0, -1.0,  1.0),
            (-1.0,  1.0,  1.0), ( 1.0,  1.0,  1.0),
        ]
        
        cube_polygons = [
            [0, 1, 3, 2], [4, 5, 7, 6], [0, 1, 5, 4],
            [2, 3, 7, 6], [0, 2, 6, 4], [1, 3, 7, 5],
        ]
        
        cube_obj = create_mesh_from_data(
            name="Advanced_Cube",
            vertices=cube_vertices,
            polygons=cube_polygons,
            location=Vector((0.0, 0.0, 0.0)),
            enable_uvs=True,
            enable_vertex_colors=False,
            log_level=2,
        )
        
        if cube_obj:
            print(f"✓ Cube created successfully with UV map")
            
        # --------------------------------------------------------------------------
        # Example 2: Pyramid with Vertex Colors (Red base, White apex)
        # --------------------------------------------------------------------------
        
        pyramid_vertices = [
            (-1.5, 0.0, 0.0),   # 0
            ( 0.0, 1.5, 0.0),   # 1
            ( 1.5, 0.0, 0.0),   # 2
            ( 0.0,-1.5, 0.0),   # 3
            ( 0.0, 0.0, 2.0),    # 4 - apex
        ]
        
        pyramid_polygons = [
            [0, 1, 4], [1, 2, 4], [2, 3, 4], [3, 0, 4], [0, 1, 2, 3]
        ]
        
        pyramid_obj = create_mesh_from_data(
            name="Advanced_Pyramid",
            vertices=pyramid_vertices,
            polygons=pyramid_polygons,
            location=Vector((5.0, 0.0, 0.0)),
            rotation_euler=(0.0, 0.0, 0.0),
            scale=Vector((1.0, 1.0, 1.0)),
            enable_uvs=False,
            enable_vertex_colors=True,
            log_level=2,
        )
        
        if pyramid_obj:
            print(f"✓ Pyramid created successfully with vertex colors")
            
    except Exception as e:
        print(f"✗ Unexpected exception: {e}")


if __name__ == "__main__":
    advanced_example()

```

## Key API Elements Used
|Element|	Purpose|	Notes|
|---|---|---|
|bpy.data.meshes.new(name)|	Creates new mesh data-block|	Does not create object, only mesh data|
|mesh.from_pydata(vertices, edges, polygons)|	Populates mesh with geometry|	vertices=3-tuples, edges=[], polygons=vertex index lists|
|mesh.update()|	Refreshes internal calculations|	Required after modifications to calculate edge loops and normals|
|bpy.data.objects.new(name, mesh)|	Creates object from mesh data-link|	Links object to existing mesh data-block|
|context.collection.objects.link(obj)|	Adds object to scene|	Makes object visible in 3D Viewport|
|mesh.uv_layers.new(name="UVMap")|	Creates UV mapping layer	|Required for textured materials|
|mesh.color_attributes.new()	|Creates vertex color attribute	|Blender 5.1 native color system (POINT domain)|
|Vector, Matrix from mathutils	|Transform operations|	Position, rotation, and scaling utilities|

## Common Pitfalls & Solutions
|Problem	|Solution	|Prevention|
|---|---|---|
|Mesh not appearing in viewport|	Call collection.objects.link(obj) after creating object|	Always link objects to collections for visibility|
|mesh.update() warning/error	Call update() after from_pydata()	|Include update() call immediately after geometry definition|
|Objects appear but no geometry visible	|Verify polygons use valid vertex indices (0-based, within range)|	Use validation function before mesh creation|
|Mesh appears inverted/flipped	|Check polygon winding order (counter-clockwise for front face)|	Test with simple shapes first to verify orientation|
|"Name already exists" error	|Clean up existing objects with same name before creating new ones|	Implement cleanup logic as shown in Advanced Example|
|Objects appear at wrong location|	Use obj.location = Vector((x, y, z)) to position after linking|	Set transforms explicitly after object creation|
|Edit-Mode crashes on data access|	Exit Edit-Mode before accessing mesh data via bpy.context.object.data|	Check mode and switch if necessary before operations|
|UV map not appearing in viewport	|Ensure materials reference the UV layer	|Create material nodes connected to UV coordinates|

## Related Functions
|Function	|File Reference	|Description|
|---|---|---|
|bmesh.ops.create_cone()	|02_geometry_creation/01_bmesh_primitives.py.md	|Create cone using BMesh operations (alternative to from_pydata)|
|bmesh.new().to_mesh(mesh)	|02_geometry_creation/01_bmesh_primitives.py.md	|Convert BMesh data structure to mesh object|
|mesh.calc_loop_triangles()	|07_advanced_geometry/01_vertex_editing.py.md	|Calculate triangle topology for n-gon meshes|
|bpy.ops.object.mode_set(mode='OBJECT')	|08_error_handling_patterns/02_context_validation.py.md	|Switch context to Object Mode before mesh operations|

Tags: #objects #meshes #geometry #creation #primitives #bmesh #vertex-data #uv-mapping #vertex-colors #error-handling #production-ready
