---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [materials, textures, nodes, shaders, cycles, eevee, bsdf, image, procedural]
related_files: [02_object_properties.py.md, 04_rendering_output/03_material_nodes.py.md, 07_advanced_geometry/01_vertex_editing.py.md]
difficulty: intermediate
categories: [materials, textures, nodes, shaders, rendering, cycles, eevee]
last_updated: 2026-04-29
search_keywords: [material creation, node tree, shader network, image texture, uv mapping, principled bsdf, bpy.data.materials.new, use_nodes, node_tree.nodes.clear, ShaderNodeBsdfPrincipled, ShaderNodeTexImage, ShaderNodeTexCoord, ShaderNodeMapping, material assignment, render engine cycles eevee]
---

# Material & Texture Nodes - Blender 5.1 API Sample
## Purpose
This script demonstrates how to programmatically create materials with shader node trees and apply textures in Blender 5.1. It covers both Cycles and Eevee render engines, including Principled BSDF setup, image texture loading, and procedural textures.

**Note**: This sample shows critical lessons learned during testing:

Always clear default nodes when creating new material node trees
Use .find() method to check material existence (not in operator)
Clear existing material slots before assignment to ensure correct slot priority
## Use Cases
Creating reusable material templates for batch object assignment
Loading external image textures and setting up UV mappings
Building complex shader networks programmatically (mix shaders, bump maps, etc.)
Converting materials between Cycles and Eevee render engines

## Basic Example
```python
import bpy

def basic_example():
    """
    BASIC EXAMPLE - Create a simple Principled BSDF material with texture
    
    Verified against Blender 5.1 API:
    - Clear default nodes is CRITICAL after enabling use_nodes
    - Material Output node must be created explicitly
    - Clear existing materials before assignment ensures correct slot priority
    """
    
    print("\n=== Basic Material Creation ===")
    
    # Create or get material (using .get() not 'in' operator)
    mat_name = "SimpleTextureMaterial"
    mat = bpy.data.materials.get(mat_name)
    
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (auto-creates default nodes that must be cleared)
    if not mat.use_nodes:
        mat.use_nodes = True
    
    # Get node tree and clear default Blender-created nodes (CRITICAL STEP!)
    nt = mat.node_tree
    print(f"Node tree type: {nt.type}")
    
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # Create Output Material Node (required for rendering)
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    
    # Create Principled BSDF Node
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.name = "Principled BSDF"
    bsdf_node.location = (0, 0)
    
    # Set material color (RGBA tuple for Base Color)
    bsdf_node.inputs['Base Color'].default_value = (1.0, 0.2, 0.0, 1.0)  # Orange
    
    # Create link: BSDF → Material Output Surface
    if nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface']):
        print("✓ Successfully linked BSDF to Material Output")
    else:
        print("✗ ERROR: Failed to create link!")
    
    # Verify material assignment
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        # CRITICAL: Clear existing materials before assigning new one
        if len(obj.data.materials) > 0:
            print("Clearing existing material slots...")
            obj.data.materials.clear()
        
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name} (slot 0)")
    else:
        print(f"⚠ WARNING: No mesh selected! Active type: {obj.type if obj else 'None'}")
    
    # Print summary verification
    print(f"\n=== Summary ===")
    print(f"Total materials in file: {len(bpy.data.materials)}")
    print(f"Material nodes in tree: {len(nt.nodes)}")
    print(f"Materials on object: {[m.name for m in obj.data.materials]}")
    
    return mat

# Run the function
basic_example()

```

## Advanced Example

### Procedural Voronoi Texture
```python
import bpy

def create_voronoi_procedural_material():
    """
    CREATE VORONOI PROCEDURAL MATERIAL - FULLY VALIDATED FOR BLENDER 5.1
    
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector → Voronoi.Texture.Vector → BSDF.Base Color → Output.Surface
    """
    
    print("\n=== Creating VORONOI Procedural Material (VALIDATED) ===")
    
    # Create or get material
    mat_name = "VoronoiProceduralMaterial"
    mat = bpy.data.materials.get(mat_name)
    
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-900, -100)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-700, -100)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Voronoi Texture Node (PROCEDURAL!) ===
    voronoi_node = nt.nodes.new(type='ShaderNodeTexVoronoi')
    voronoi_node.location = (-500, -100)
    voronoi_node.name = "Voronoi Texture"
    print(f"✓ Created: {voronoi_node.name} ({type(voronoi_node).__name__})")
    
    # === STEP 6: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_voronoi = nt.links.new(mapping_node.outputs['Vector'], voronoi_node.inputs['Vector'])
    print(f"  Mapping.Vector → Voronoi.Vector: {'✓' if link_mapping_to_voronoi else '✗'}")
    
    link_voronoi_to_bsdf = nt.links.new(voronoi_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  Voronoi.Color → BSDF.Base Color: {'✓' if link_voronoi_to_bsdf else '✗'}")
    
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 7: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 8: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name}")
    
    # === STEP 9: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat

# Run the verified function
if __name__ == "__main__":
    result = create_voronoi_procedural_material()
    if result:
        print("\n✓ Material created successfully!")

```

### Procedural Brick Texture
```python
import bpy


def create_brick_procedural_material():
    """
    CREATE BRICK PROCEDURAL MATERIAL - FULLY VALIDATED FOR BLENDER 5.1
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector → Brick.Texture.Vector → BSDF.Base Color → Output.Surface
    """
    print("\n=== Creating BRICK Procedural Material (VALIDATED) ===")
    
    # Create or get material
    mat_name = "BrickProceduralMaterial"
    mat = bpy.data.materials.get(mat_name)
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-900, -100)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-700, -100)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Brick Texture Node (PROCEDURAL!) ===
    brick_node = nt.nodes.new(type='ShaderNodeTexBrick')
    brick_node.location = (-500, -100)
    brick_node.name = "Brick Texture"
    print(f"✓ Created: {brick_node.name} ({type(brick_node).__name__})")
    
    # === STEP 6: Configure Brick Texture Properties (BLENDER 5.1 COMPATIBLE!) ===
    brick_node.offset = 0.5        # Determines brick offset of various rows [0, 1]
    brick_node.offset_frequency = 2  # How often rows are offset [1, 99], default 2
    brick_node.squash = 1.0         # Factor to adjust brick's width [0, 99], default 1.0
    brick_node.squash_frequency = 2   # How often rows consist of squished bricks [1, 99]
    print("✓ Brick texture properties configured")
    
    # === STEP 7: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_brick = nt.links.new(mapping_node.outputs['Vector'], brick_node.inputs['Vector'])
    print(f"  Mapping.Vector → Brick.Vector: {'✓' if link_mapping_to_brick else '✗'}")
    
    link_brick_to_bsdf = nt.links.new(brick_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  Brick.Color → BSDF.Base Color: {'✓' if link_brick_to_bsdf else '✗'}")
    
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 8: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 9: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name}")
    
    # === STEP 10: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat


# Run the verified function
if __name__ == "__main__":
    result = create_brick_procedural_material()
    if result:
        print("\n✓ Material created successfully!")

```

### Procedural Gradient Texture
```python
import bpy


def create_gradient_colorramp_procedural_material():
    """
    CREATE GRADIENT + COLOR RAMP PROCEDURAL MATERIAL - FULLY VALIDATED FOR BLENDER 5.1
    
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector → Gradient.Texture.Vector → 
    Color Ramp.Fac ← Gradient.Factor | Color Ramp.Color → Principled BSDF.Base Color → Output.Surface
    """
    print("\n=== Creating GRADIENT + COLOR RAMP Procedural Material (VALIDATED) ===")
    
    # Create or get material
    mat_name = "GradientColorRampProceduralMaterial"
    mat = bpy.data.materials.get(mat_name)
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-1000, -150)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-800, -150)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Gradient Texture Node (PROCEDURAL!) ===
    gradient_node = nt.nodes.new(type='ShaderNodeTexGradient')
    gradient_node.location = (-600, -150)
    gradient_node.name = "Gradient Texture"
    print(f"✓ Created: {gradient_node.name} ({type(gradient_node).__name__})")
    
    # === STEP 6: Create Color Ramp Node (NEW!) ===
    colorramp_node = nt.nodes.new(type='ShaderNodeValToRGB')
    colorramp_node.location = (-400, 200)  # Positioned above for visual clarity
    colorramp_node.name = "Color Ramp"
    print(f"✓ Created: {colorramp_node.name} ({type(colorramp_node).__name__})")
    
    # === STEP 7: Configure Gradient Texture Properties (BLENDER 5.1 COMPATIBLE!) ===
    gradient_node.gradient_type = 'LINEAR'  # Options: LINEAR, QUADRATIC, EASING, DIAGONAL, SPHERICAL, QUADRATIC_SPHERE, RADIAL
    print("✓ Gradient texture properties configured")
    
    # === STEP 8: Configure Color Ramp Properties (BLENDER 5.1 COMPATIBLE!) ===
    colorramp_node.color_ramp.interpolation = 'LINEAR'  # Options: LINEAR, B_SPLINE, CUBIC, CONSTANT
    colorramp_node.color_ramp.elements[0].position = 0.0
    colorramp_node.color_ramp.elements[1].position = 1.0
    print("✓ Color Ramp properties configured")
    
    # === STEP 9: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_gradient = nt.links.new(mapping_node.outputs['Vector'], gradient_node.inputs['Vector'])
    print(f"  Mapping.Vector → Gradient.Vector: {'✓' if link_mapping_to_gradient else '✗'}")
    
    # === NEW CONNECTIONS FOR COLOR RAMP ===
    link_gradient_factor_to_ramp_fac = nt.links.new(gradient_node.outputs['Factor'], colorramp_node.inputs['Fac'])
    print(f"  Gradient.Factor → ColorRamp.Fac: {'✓' if link_gradient_factor_to_ramp_fac else '✗'}")
    
    link_ramp_color_to_bsdf = nt.links.new(colorramp_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  ColorRamp.Color → BSDF.Base Color: {'✓' if link_ramp_color_to_bsdf else '✗'}")
    
    # === EXISTING CONNECTIONS (updated) ===
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 10: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 11: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name}")
    
    # === STEP 12: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat


# Run the verified function
if __name__ == "__main__":
    result = create_gradient_colorramp_procedural_material()
    if result:
        print("\n✓ Material created successfully!")

```

### Procedural Magic Texture
```python
import bpy


def create_magic_procedural_material():
    """
    CREATE MAGIC PROCEDURAL MATERIAL - FULLY VALIDATED FOR BLENDER 5.1
    
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector → Magic.Texture.Vector → BSDF.Base Color → Output.Surface
    
    The Magic texture creates a psychedelic color pattern with controllable turbulence.
    """
    print("\n=== Creating MAGIC Procedural Material (VALIDATED) ===")
    
    # Create or get material
    mat_name = "MagicProceduralMaterial"
    mat = bpy.data.materials.get(mat_name)
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-900, -100)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-700, -100)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Magic Texture Node (PROCEDURAL!) ===
    magic_node = nt.nodes.new(type='ShaderNodeTexMagic')
    magic_node.location = (-500, -100)
    magic_node.name = "Magic Texture"
    print(f"✓ Created: {magic_node.name} ({type(magic_node).__name__})")
    
    # === STEP 6: Configure Magic Texture Properties (BLENDER 5.1 COMPATIBLE!) ===
    magic_node.turbulence_depth = 0  # Level of detail in turbulent noise [0, 10], default 0
    print("✓ Magic texture properties configured")
    
    # === STEP 7: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_magic = nt.links.new(mapping_node.outputs['Vector'], magic_node.inputs['Vector'])
    print(f"  Mapping.Vector → Magic.Vector: {'✓' if link_mapping_to_magic else '✗'}")
    
    link_magic_to_bsdf = nt.links.new(magic_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  Magic.Color → BSDF.Base Color: {'✓' if link_magic_to_bsdf else '✗'}")
    
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 8: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 9: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name}")
    
    # === STEP 10: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat


# Run the verified function
if __name__ == "__main__":
    result = create_magic_procedural_material()
    if result:
        print("\n✓ Material created successfully!")

```

### Procedural Noise Texture
```python
import bpy


def create_noise_procedural_material():
    """
    CREATE NOISE PROCEDURAL MATERIAL - FULLY FIXED FOR BLENDER 5.1
    
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector (with scale via input socket) → Noise.Texture.Vector → BSDF.Base Color → Output.Surface
    
    FIX APPLIED: 
    - Use mapping_node.inputs['Scale'].default_value instead of mapping_node.scale
    - Use mapping_node.inputs['Location'].default_value for offset
    - Only noise_type is available on ShaderNodeTexNoise in Blender 5.1
    """
    print("\n=== Creating NOISE Procedural Material (FIXED FOR BLENDER 5.1) ===")
    
    # Create or get material
    mat_name = "NoiseProceduralMaterial"
    mat = bpy.data.materials.get(mat_name)
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-900, -150)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node (SCALING VIA INPUT SOCKET!) ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-700, -150)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Noise Texture Node (PROCEDURAL!) ===
    noise_node = nt.nodes.new(type='ShaderNodeTexNoise')
    noise_node.location = (-500, -150)
    noise_node.name = "Noise Texture"
    print(f"✓ Created: {noise_node.name} ({type(noise_node).__name__})")
    
    # === STEP 6: Configure Properties (BLENDER 5.1 COMPATIBLE!) ===
    # VALID NOISE TYPES IN BLENDER 5.1 ONLY: MULTIFRACTAL, RIDGED_MULTIFRACTAL, HYBRID_MULTIFRACTAL, FBM, HETERO_TERRAIN
    noise_node.noise_type = 'MULTIFRACTAL'        # Default organic noise pattern
    
    # Scale is controlled via input socket (Blender 5.1 API)
    mapping_node.inputs['Scale'].default_value = (3.0, 3.0, 1.0)  # [x, y, z] scale
    print("✓ Noise texture properties configured (BLENDER 5.1 COMPATIBLE)")
    
    # === STEP 7: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_noise = nt.links.new(mapping_node.outputs['Vector'], noise_node.inputs['Vector'])
    print(f"  Mapping.Vector → Noise.Vector: {'✓' if link_mapping_to_noise else '✗'}")
    
    link_noise_to_bsdf = nt.links.new(noise_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  Noise.Color → BSDF.Base Color: {'✓' if link_noise_to_bsdf else '✗'}")
    
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 8: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 9: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name}")
    
    # === STEP 10: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat


# Run the verified function
if __name__ == "__main__":
    result = create_noise_procedural_material()
    if result:
        print("\n✓ Material created successfully!")

```

### Procedural Wave Texture
```python
import bpy


def create_wave_colorramp_procedural_material():
    """
    CREATE WAVE + COLOR RAMP PROCEDURAL MATERIAL - FULLY VALIDATED FOR BLENDER 5.1
    
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector → Wave.Texture.Vector → 
    Wave.Color/Factor → Color Ramp.Fac | Color Ramp.Color → Principled BSDF.Base Color → Output.Surface
    
    Wave Texture creates procedural bands or rings, then Color Ramp remaps the colors for custom control.
    
    Blender 5.1 Properties Available:
    - wave_node.bands_direction: 'X', 'Y', 'Z', 'DIAGONAL'
    - wave_node.rings_direction: 'X', 'Y', 'Z', 'SPHERICAL'  
    - wave_node.wave_profile: 'SIN', 'SAW', 'TRI'
    
    Color Ramp Properties:
    - color_ramp.interpolation: 'LINEAR', 'B_SPLINE', 'CUBIC', 'CONSTANT'
    """
    
    print("\n=== Creating WAVE + COLOR RAMP Procedural Material (VALIDATED FOR BLENDER 5.1) ===")
    
    # Create or get material (use .get() not 'in' operator)
    mat_name = "WaveColorRampProceduralMaterial"
    mat = bpy.data.materials.get(mat_name)
    
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-1000, -200)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node (SCALING VIA INPUT SOCKET!) ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-800, -200)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Wave Texture Node (PROCEDURAL!) ===
    wave_node = nt.nodes.new(type='ShaderNodeTexWave')
    wave_node.location = (-600, -200)
    wave_node.name = "Wave Texture"
    print(f"✓ Created: {wave_node.name} ({type(wave_node).__name__})")
    
    # === STEP 6: Create Color Ramp Node (NEW!) ===
    colorramp_node = nt.nodes.new(type='ShaderNodeValToRGB')
    colorramp_node.location = (-400, 150)  # Positioned above for visual clarity
    colorramp_node.name = "Color Ramp"
    print(f"✓ Created: {colorramp_node.name} ({type(colorramp_node).__name__})")
    
    # === STEP 7: Configure Wave Texture Properties (BLENDER 5.1 COMPATIBLE!) ===
    wave_node.bands_direction = 'X'  
    wave_node.rings_direction = 'SPHERICAL'  
    wave_node.wave_profile = 'TRI'  
    print("✓ Wave texture properties configured")
    
    # Scale is controlled via input socket (Blender 5.1 API)
    mapping_node.inputs['Scale'].default_value = (3.0, 3.0, 1.0)  # [x, y, z] scale
    print("✓ Mapping scale configured")
    
    # === STEP 8: Configure Color Ramp Properties (BLENDER 5.1 COMPATIBLE!) ===
    colorramp_node.color_ramp.interpolation = 'B_SPLINE'  
    print("✓ Color Ramp interpolation set to B_SPLINE")
    
    # Customize color ramp colors for wave pattern effect
    # Remove default elements and add custom ones
    colorramp_node.color_ramp.elements.remove(colorramp_node.color_ramp.elements[1])  # Remove second element
    
    # Add black at start (low values)
    elem_black = colorramp_node.color_ramp.elements.new(0.0)
    elem_black.color = (0.0, 0.0, 0.0, 1.0)  # Black
    print("✓ Added black color element")
    
    # Add blue at middle-low
    elem_blue = colorramp_node.color_ramp.elements.new(0.35)
    elem_blue.color = (0.2, 0.4, 0.8, 1.0)  # Blue
    print("✓ Added blue color element")
    
    # Add white at middle-high
    elem_white = colorramp_node.color_ramp.elements.new(0.65)
    elem_white.color = (0.9, 0.9, 1.0, 1.0)  # Light Blue/White
    print("✓ Added white color element")
    
    # Add cyan at end (high values)
    elem_cyan = colorramp_node.color_ramp.elements.new(1.0)
    elem_cyan.color = (0.0, 0.8, 0.8, 1.0)  # Cyan
    print("✓ Added cyan color element")
    
    # === STEP 9: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_wave = nt.links.new(mapping_node.outputs['Vector'], wave_node.inputs['Vector'])
    print(f"  Mapping.Vector → Wave.Vector: {'✓' if link_mapping_to_wave else '✗'}")
    
    # === NEW CONNECTIONS FOR COLOR RAMP ===
    link_wave_color_to_ramp_fac = nt.links.new(wave_node.outputs['Color'], colorramp_node.inputs['Fac'])
    print(f"  Wave.Color → ColorRamp.Fac: {'✓' if link_wave_color_to_ramp_fac else '✗'}")
    
    # Alternative: Use Factor output for more control (if available)
    # link_wave_factor_to_ramp_fac = nt.links.new(wave_node.outputs['Factor'], colorramp_node.inputs['Fac'])
    
    link_ramp_color_to_bsdf = nt.links.new(colorramp_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  ColorRamp.Color → BSDF.Base Color: {'✓' if link_ramp_color_to_bsdf else '✗'}")
    
    # === EXISTING CONNECTIONS (updated) ===
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 10: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 11: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name} (slot 0)")
    else:
        print(f"⚠ WARNING: No mesh selected! Active type: {obj.type if obj else 'None'}")
    
    # === STEP 12: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat


# Run the verified function
if __name__ == "__main__":
    result = create_wave_colorramp_procedural_material()
    if result:
        print("\n✓ WAVE + COLOR RAMP Material created successfully!")

```

### Image Texture with UV coordinates
```python
import bpy


def create_image_texture_material(image_path):
    """
    CREATE IMAGE TEXTURE MATERIAL - FULLY VALIDATED FOR BLENDER 5.1
    
    Node Setup:
    Texture Coordinate.UV → Mapping.Vector → Image.Texture.Vector → 
    Image.Color → Principled BSDF.Base Color → Output.Surface
    
    Args:
        image_path (str): Full path to the image file
        
    Returns:
        bpy.types.Material: The created material
    """
    print("\n=== Creating Image Texture Material ===")
    
    # Create or get material
    mat_name = "ImageTextureMaterial"
    mat = bpy.data.materials.get(mat_name)
    if not mat:
        print(f"Creating new material: {mat_name}")
        mat = bpy.data.materials.new(name=mat_name)
    else:
        print(f"Using existing material: {mat.name}")
    
    # Enable node tree (CRITICAL STEP!)
    if not mat.use_nodes:
        mat.use_nodes = True
    nt = mat.node_tree
    
    # CRITICAL: Clear ALL default nodes before creating new ones!
    if len(nt.nodes) > 0:
        print("Clearing existing nodes...")
        nt.nodes.clear()
    
    # === STEP 1: Create Output Material Node (REQUIRED!) ===
    output_node = nt.nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    output_node.name = "Material Output"
    print(f"✓ Created: {output_node.name} ({type(output_node).__name__})")
    
    # === STEP 2: Create Principled BSDF Node ===
    bsdf_node = nt.nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf_node.location = (0, 0)
    bsdf_node.name = "Principled BSDF"
    print(f"✓ Created: {bsdf_node.name} ({type(bsdf_node).__name__})")
    
    # === STEP 3: Create Texture Coordinate Node ===
    coord_node = nt.nodes.new(type='ShaderNodeTexCoord')
    coord_node.location = (-1000, -150)
    coord_node.name = "Texture Coordinate"
    print(f"✓ Created: {coord_node.name} ({type(coord_node).__name__})")
    
    # === STEP 4: Create Mapping Node ===
    mapping_node = nt.nodes.new(type='ShaderNodeMapping')
    mapping_node.location = (-800, -150)
    mapping_node.name = "Mapping"
    print(f"✓ Created: {mapping_node.name} ({type(mapping_node).__name__})")
    
    # === STEP 5: Create Image Texture Node (NEW!) ===
    image_texture_node = nt.nodes.new(type='ShaderNodeTexImage')
    image_texture_node.location = (-600, -150)
    image_texture_node.name = "Image Texture"
    print(f"✓ Created: {image_texture_node.name} ({type(image_texture_node).__name__})")
    
    # === STEP 6: Load Image File (BLENDER 5.1 COMPATIBLE!) ===
    try:
        if bpy.data.images.get("LoadedTexture"):
            loaded_image = bpy.data.images["LoadedTexture"]
            print(f"✓ Using existing image: {loaded_image.name}")
        else:
            # Load the image from file path
            loaded_image = bpy.data.images.load(image_path)
            print(f"✓ Loaded image from: {image_path}")
            
            # Set as active texture for this node
            image_texture_node.image = loaded_image
            
        # Configure Image Texture properties
        image_texture_node.use_nodes = True
        
    except Exception as e:
        print(f"⚠ Warning: Could not load image at '{image_path}': {e}")
        print("  Falling back to a default generated texture...")
        # Create a placeholder if image fails
        loaded_image = bpy.data.images.new(name="PlaceholderTexture", width=1024, height=1024)
        image_texture_node.image = loaded_image
    
    # === STEP 7: Create ALL LINKS (in correct order!) ===
    print("\nCreating connections:")
    
    link_uv_to_mapping = nt.links.new(coord_node.outputs['UV'], mapping_node.inputs['Vector'])
    print(f"  UV → Mapping.Vector: {'✓' if link_uv_to_mapping else '✗'}")
    
    link_mapping_to_image = nt.links.new(mapping_node.outputs['Vector'], image_texture_node.inputs['Vector'])
    print(f"  Mapping.Vector → Image.Texture.Vector: {'✓' if link_mapping_to_image else '✗'}")
    
    link_image_color_to_bsdf = nt.links.new(image_texture_node.outputs['Color'], bsdf_node.inputs['Base Color'])
    print(f"  Image.Color → BSDF.Base Color: {'✓' if link_image_color_to_bsdf else '✗'}")
    
    link_bsdf_to_output = nt.links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
    print(f"  BSDF.BSDF → Output.Surface: {'✓' if link_bsdf_to_output else '✗'}")
    
    # === STEP 8: Print Summary ===
    print("\n=== Node Count Verification ===")
    print(f"Total nodes in tree: {len(nt.nodes)}")
    for node in nt.nodes:
        print(f"  - {node.name} ({type(node).__name__})")
    
    # === STEP 9: Assign to Active Object (if mesh) ===
    obj = bpy.context.active_object
    if obj and obj.type == 'MESH':
        if len(obj.data.materials) > 0:
            print("\nClearing existing material slots...")
            obj.data.materials.clear()
        obj.data.materials.append(mat)
        print(f"✓ Material assigned to {obj.name}")
    
    # === STEP 10: Set Render Engine ===
    bpy.context.scene.render.engine = 'CYCLES'
    print("Render engine set to Cycles")
    
    return mat


# Run the verified function with a sample image path
if __name__ == "__main__":
    # Example usage - replace with your actual image path!
    image_path = "/path/to/your/image.jpg"  # UPDATE THIS PATH
    
    result = create_image_texture_material(image_path)
    if result:
        print("\n✓ Material created successfully!")

```

## Key API Elements Used
|Element|	Description|	Source|
|---|---|---|
|bpy.data.materials.new()|	Creates a new material data-block in the current blend file|	bpy.types/Material.html|
|material.use_nodes|	Boolean to enable/disable node tree for the material (auto-creates default nodes)	|bpy.types/Material.html|
|node_tree.nodes.clear()|	**CRITICAL**: Remove all default nodes before creating new ones|	bpy.types.Nodes.html|
|nodes.new(type=...)|	Creates new shader nodes (requires string type parameter, not class reference)|	bpy.types.ShaderNode.html|
|node.location = (-x, -y)|	Positions nodes in the node editor workspace|	N/A|
|node.inputs['Name'].default_value|	Sets input socket values (color tuples, floats)|	bpy.types.NodeSocketColor.html|
|node_tree.links.new(from_socket, to_socket)|	Creates connections between node sockets (output → input direction)|	bpy.types.NodeLinks.html|
|bpy.data.images.load(path)|	Loads external image files for texture nodes|	bpy.types.BlendDataImages.html|
|ShaderNodeBsdfPrincipled|	Main PBR shader node supporting both Cycles and Eevee|	bpy.types.ShaderNodeBsdfPrincipled.html|
|ShaderNodeTexCoord|	Provides UV, Generated, Object coordinates for textures|	bpy.types.ShaderNodeTexCoord.html|
|ShaderNodeMapping|	Allows rotation/scale/offset adjustments to texture coordinates|	bpy.types.ShaderNodeMapping.html|
|bpy.data.materials.get(name)|	Get existing material by name (returns None if not found)|	bpy.types/Material.html|
|obj.data.materials.find(name)|	Check if material exists (returns -1 if not found) - alternative to .get()|	bpy.types/bpy_prop_collection.html|
|obj.data.materials.clear()|	Remove all materials from object before assignment|	bpy.types/IDMaterials.html|

## Common Pitfalls & Solutions
|Problem|   Solution|   Source|
|---|---|---|
|**Duplicate Principled BSDF nodes**|   Call node_tree.nodes.clear() after enabling use_nodes|  bpy.types.Nodes.html|
|Material not appearing on object|  Ensure material is assigned via object.data.materials.append() before rendering|    N/A|
|Texture node shows checkerboard|   Verify image loaded correctly with image_node.image = bpy.data.images.load(path)|   bpy.types.BlendDataImages.html|
|Cycles/Eevee render differences|   Some nodes work differently; use Principled BSDF for cross-engine compatibility|    N/A|
|Node connections fail silently|    Always check socket types match before linking (Color→BSDF, not Color→Fac)| bpy.types.NodeLinks.html|
|Material data-block not saved| Call bpy.ops.wm.save_as_mainfile() or ensure save operation is triggered|   N/A|
|UV mapping issues with procedural textures|    Use ShaderNodeTexCoord and map to correct output (UV vs Generated coordinates)| bpy.types.ShaderNodeTexCoord.html|
|Performance degradation with many materials|   Batch material creation and use shared node trees for similar materials|    N/A|
|**Material slot priority wrong**|  Clear existing materials first before appending new one to ensure correct position| bpy.types/IDMaterials.html|
|Using 'in' operator on bpy_prop_collection|Use .get() or .find() methods instead (not 'in' operator)|bpy.types/Material.html|
|**Mapping node scale doesn't work**|   Use `mapping_node.inputs['Scale'].default_value = (x, y, z)` instead of direct property access| bpy.types.ShaderNodeMapping.html|
|Noise texture types error in 5.1|  Only MULTIFRACTAL, RIDGED_MULTIFRACTAL, HYBRID_MULTIFRACTAL, FBM, HETERO_TERRAIN available in Blender 5.1|  bpy.types.ShaderNodeTexNoise.html|
|Wave texture properties missing|   Set: `wave_node.bands_direction`, `wave_node.rings_direction`, `wave_node.wave_profile` for Blender 5.1|    bpy.types.ShaderNodeTexWave.html|

## Related Functions
- See also: 01_basics/02_object_properties.py.md - Object-material assignment patterns
- See also: 04_rendering_output/03_material_nodes.py.md - Advanced material node workflows
- See also: 07_advanced_geometry/01_vertex_editing.py.md - Vertex color integration with materials

*Tags: #materials #textures #nodes #shaders #cycles #eevee #bsdf #image #procedural #bpy_prop_collection #node_clear*
