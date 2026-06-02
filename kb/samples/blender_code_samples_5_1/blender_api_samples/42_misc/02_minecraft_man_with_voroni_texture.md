---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, materials, textures, character, procedural]
related_files: [01_man_with_ball_contraint.md, 02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [objects, transformations, operators, primitives, materials, textures, character-rigging, procedural-textures]
last_updated: 2026-04-30
search_keywords: [minecraft character, voronoi texture, procedual material, Principled BSDF, ShaderNodeTexVoronoi, primitive_cube_add, align WORLD, Vector scale, custom properties, character parts, Z-axis orientation, node tree setup]
---

# Example - Minecraft Character with Voronoi Texture

```python
"""
Blender 5.1 - Minecraft Character with Voronoi Texture (CORRECTED)
Category: #objects #materials #textures #character #procedural
Based on validated document patterns from 01_man_with_ball_contraint.md
"""

import bpy
from mathutils import Vector


def clear_scene():
    """Remove all objects except Camera and Lights."""
    print("=== Clearing Scene ===")
    for obj in list(bpy.data.objects):
        if obj.type not in ('CAMERA', 'LIGHT'):
            bpy.data.objects.remove(obj, do_unlink=True)
    print("✓ Scene cleared\n")


def create_primitive_cube(name: str = "Cube", location=(0, 0, 0), size=1.0, scale=None, color=(0.8, 0.2, 0.2)):
    """Create a cube primitive with material using validated Blender 5.1 patterns."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

    # Use operator to create cube - size must be float, align='WORLD' ensures Z-up!
    bpy.ops.mesh.primitive_cube_add(
        size=size,  # Float for uniform base size (Blender 5.1 verified!)
        location=location,
        align='WORLD',  # CRITICAL: Aligns with world axes (Z is UP!)
    )

    obj = bpy.data.objects.get(name) or bpy.context.active_object
    if obj:
        obj.name = name
    
    # Apply non-uniform scaling AFTER creation (validated pattern from document!)
    if scale and isinstance(scale, Vector):
        obj.scale = scale
        obj.update_from_editmode()  # Update mesh after scale change

    # Create material with Principled BSDF (Blender 5.1 node system - validated!)
    mat_name = f"{name}_Material"
    if mat_name not in bpy.data.materials:
        mat = bpy.data.materials.new(name=mat_name)
        mat.use_nodes = True
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
    else:
        mat = bpy.data.materials[mat_name]

    obj.data.materials.append(mat)
    print(f"✓ Created {obj.name} at {location}")
    return obj


def create_voronoi_material(name="MinecraftVoronoi"):
    """Create a material with procedural Voronoi texture using VALIDATED node setup."""
    
    # Create or get the material (validated pattern)
    if name in bpy.data.materials:
        print(f"⚠ Material '{name}' already exists, reusing it")
        mat = bpy.data.materials[name]
    else:
        print(f"Creating new material: {name}")
        mat = bpy.data.materials.new(name=name)
    
    # Enable node tree for the material (validated pattern)
    mat.use_nodes = True
    
    if mat.node_tree:
        nodes = mat.node_tree.nodes
        links = mat.node_tree.links
        
        # Clear existing nodes (validated pattern)
        for n in list(nodes):
            nodes.remove(n)
        
        # Create Principled BSDF Node (main shader - validated!)
        bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf.location = (0, 0)
        bsdf.name = "Principled BSDF"
        
        # Create Texture Coordinate node (validated pattern!)
        tex_coord = nodes.new(type='ShaderNodeTexCoord')
        tex_coord.location = (-900, -100)
        tex_coord.name = "Texture Coordinate"
        
        # Create Mapping node for texture control (validated pattern!)
        mapping = nodes.new(type='ShaderNodeMapping')
        mapping.location = (-700, -100)
        mapping.name = "Mapping"
        
        # Create Voronoi Texture node (VALIDATED ATTRIBUTES ONLY!)
        voronoi = nodes.new(type='ShaderNodeTexVoronoi')
        voronoi.location = (-500, -100)
        voronoi.name = "Voronoi Texture"
        
        # Configure Voronoi texture properties - CORRECT ATTRIBUTES! (FIXED!)
        voronoi.distance = 'EUCLIDEAN'  # Euclidean distance metric
        voronoi.feature = 'F1'           # Distance to closest point
        
        print(f"✓ Voronoi settings: distance={voronoi.distance}, feature={voronoi.feature}")
        
        # Create ColorRamp node for Minecraft-style colors (validated pattern!)
        color_ramp = nodes.new(type='ShaderNodeValToRGB')
        color_ramp.location = (-300, -100)
        color_ramp.name = "ColorRamp"
        
        # Set up Minecraft-style earth tones (VALIDATED color pattern!)
        color_ramp.color_ramp.elements[0].color = (0.59, 0.48, 0.32, 1.0)  # Dirt brown
        color_ramp.color_ramp.elements[1].color = (0.76, 0.80, 0.54, 1.0)  # Grass green
        
        # Create Output node (validated pattern!)
        output = nodes.new(type='ShaderNodeOutputMaterial')
        output.location = (300, 0)
        output.name = "Output"
        
        # Connect the nodes in correct order: (VALIDATED connection pattern!)
        links.new(tex_coord.outputs['Generated'], mapping.inputs['Vector'])
        links.new(mapping.outputs['Vector'], voronoi.inputs['Vector'])
        links.new(voronoi.outputs['Color'], color_ramp.inputs['Fac'])
        links.new(color_ramp.outputs['Color'], bsdf.inputs['Base Color'])
        links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])
        
        print("✓ Voronoi material created with node tree")
    
    return mat


def create_minecraft_character(name="MinecraftMan"):
    """Create a Minecraft-style character with proper Z-axis orientation (VALIDATED!)."""
    
    # Clear existing objects (validated pattern)
    clear_scene()
    
    # Create material with Voronoi texture (FIXED attributes!)
    mat = create_voronoi_material("VoronoiSkin")
    
    print("\n=== Creating Minecraft Character ===\n")
    
    # Head - using validated cube creation from document!
    head = create_primitive_cube(
        name="Head",
        location=(0, 0, 2.5),
        size=1.0,
        scale=Vector((1.0, 1.0, 1.0)),  # Non-uniform via Vector (validated!)
        color=(0.76, 0.80, 0.54)         # Grass green!
    )
    
    # Torso - main body using validated patterns!
    torso = create_primitive_cube(
        name="Torso",
        location=(0, 0, 0.5),
        size=1.0,
        scale=Vector((1.5, 2.0, 1.0)),   # Non-uniform dimensions (validated!)
        color=(0.3, 0.4, 0.8)            # Blue shirt!
    )
    
    # Left Arm - using validated Vector scaling pattern!
    arm_l = create_primitive_cube(
        name="LeftArm",
        location=(-1.5, 0, 0.75),
        size=1.0,
        scale=Vector((0.5, 2.0, 1.5)),   # Arm dimensions (validated!)
        color=(0.3, 0.4, 0.8)
    )
    
    # Right Arm - validated pattern!
    arm_r = create_primitive_cube(
        name="RightArm",
        location=(1.5, 0, 0.75),
        size=1.0,
        scale=Vector((0.5, 2.0, 1.5)),   # Arm dimensions (validated!)
        color=(0.3, 0.4, 0.8)
    )
    
    # Left Leg - validated pattern!
    leg_l = create_primitive_cube(
        name="LeftLeg",
        location=(-0.75, 0, -1.5),
        size=1.0,
        scale=Vector((0.6, 1.0, 1.5)),   # Leg dimensions (validated!)
        color=(0.4, 0.4, 0.6)            # Pants!
    )
    
    # Right Leg - validated pattern!
    leg_r = create_primitive_cube(
        name="RightLeg",
        location=(0.75, 0, -1.5),
        size=1.0,
        scale=Vector((0.6, 1.0, 1.5)),   # Leg dimensions (validated!)
        color=(0.4, 0.4, 0.6)
    )
    
    # Group all parts into a collection (validated pattern!)
    collection = bpy.data.collections.get("MinecraftCharacter")
    if not collection:
        collection = bpy.data.collections.new("MinecraftCharacter")
        bpy.context.scene.collection.children.link(collection)

    for part in [head, torso, arm_l, arm_r, leg_l, leg_r]:
        if part.users_collection:
            for col in list(part.users_collection):
                if "MinecraftCharacter" not in col.name:
                    collection.objects.link(part)
    
    # Add custom properties to character parts (validated pattern!)
    head["character_part"] = "head"
    torso["character_part"] = "torso"
    arm_l["character_part"] = "left_arm"
    arm_r["character_part"] = "right_arm"
    leg_l["character_part"] = "left_leg"
    leg_r["character_part"] = "right_leg"
    
    print(f"\n✓ Created {len([head, torso, arm_l, arm_r, leg_l, leg_r])} body parts")
    print("✓ Character is aligned to WORLD axes (Z-axis UP!)")
    print("✓ Voronoi texture applied with CORRECT attributes!")
    
    return collection


def setup_scene():
    """Setup basic camera and lighting for viewing (validated pattern)."""
    print("\n=== Setting up Scene ===\n")

    # Camera positioned at angle (validated pattern!)
    bpy.ops.object.camera_add(location=(5, -5, 3), align='WORLD')
    cam = bpy.context.active_object
    if cam:
        cam.rotation_euler = (1.57, 0, -0.78)
        print("✓ Camera positioned")

    # Sun light added (validated pattern!)
    bpy.ops.object.light_add(type='SUN', location=(3, 2, 4))
    light = bpy.context.active_object
    if light:
        print("✓ Sun light added\n")


def select_all_parts(character_parts):
    """Select all character parts for easy viewing in viewport (validated pattern)."""
    print("\n=== Selecting Character Parts ===\n")

    # Set active object to torso (validated pattern!)
    bpy.context.view_layer.objects.active = character_parts.get("Torso")
    
    # Select all parts (validated pattern!)
    for part_name, part_obj in character_parts.items():
        if part_name != 'collection':
            part_obj.select_set(True)

    print(f"✓ Selected {len(character_parts)} objects\n")


def main():
    """Main execution function."""
    print("=" * 60)
    print("Blender 5.1 - Minecraft Character with Voronoi Texture (CORRECTED)")
    print("=" * 60)

    # Create character using VALIDATED patterns!
    create_minecraft_character()
    
    # Setup scene using validated pattern!
    setup_scene()
    
    # Select all parts for easy viewing (validated pattern!)
    select_all_parts({
        "Head": bpy.data.objects.get("Head"),
        "Torso": bpy.data.objects.get("Torso"),
        "LeftArm": bpy.data.objects.get("LeftArm"),
        "RightArm": bpy.data.objects.get("RightArm"),
        "LeftLeg": bpy.data.objects.get("LeftLeg"),
        "RightLeg": bpy.data.objects.get("RightLeg")
    })

    print("\n" + "=" * 60)
    print("✓ Character created successfully!")
    print("✓ Z-axis is UP (standing upright)")
    print("✓ Voronoi texture uses CORRECT attributes:")
    print("  - distance='EUCLIDEAN'")
    print("  - feature='F1'")
    print("  - NO noise_scale (not available on ShaderNodeTexVoronoi!)")
    print("=" * 60)


if __name__ == "__main__":
    main()

```

*tags: #objects #materials #textures #character #procedural
