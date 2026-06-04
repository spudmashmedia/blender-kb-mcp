---
search_priority: high
document_type: tutorial
blender_version: 5.1
tags: [objects, constraints, animation, rigging, character]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [objects, transformations, operators, primitives, constraints, character-rigging]
last_updated: 2026-04-30
search_keywords: [copy_location constraint, man character, ball in hand, primitive_cube_add, primitive_ico_sphere_add, character_parts, constrained_object, bpy.ops.mesh.primitive_cube_add, bpy.ops.mesh.primitive_ico_sphere_add, constraints.new, character rigging, material setup, Principled BSDF]
---

# Example - Man with Ball Constraint Demo 

```python
"""
Blender 5.1 - Man with Ball Constraint Demo (FIXED)
Category: #objects #constraints #animation #rigging #character
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
    """Create a cube primitive with material using operators (Blender 5.1 verified)."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

    # Use operator to create cube - size must be float, not Vector!
    bpy.ops.mesh.primitive_cube_add(
        size=size,  # Float for uniform base size (Blender 5.1 verified!)
        location=location,
        align='WORLD'
    )

    obj = bpy.data.objects.get(name) or bpy.context.active_object
    if obj:
        obj.name = name
    
    # Apply non-uniform scaling AFTER creation (if scale is provided)
    if scale and isinstance(scale, Vector):
        obj.scale = scale
        obj.update_from_editmode()  # Update mesh after scale change

    # Create material with Principled BSDF (Blender 5.1 node system)
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


def create_primitive_sphere(name: str = "Sphere", location=(0, 0, 0), radius=1.0, color=(0.8, 0.2, 0.2)):
    """Create a UV sphere primitive with material using operators."""
    if name in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[name], do_unlink=True)

    # Use operator to create sphere (Blender 5.1 verified!)
    bpy.ops.mesh.primitive_ico_sphere_add(
        subdivisions=2,
        radius=radius,
        location=location,
        align='WORLD'
    )

    obj = bpy.data.objects.get(name) or bpy.context.active_object
    if obj:
        obj.name = name

    # Create material with Principled BSDF (Blender 5.1 node system)
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


def create_character():
    """Create a simple man character with body parts."""
    print("\n=== Creating Character ===\n")

    head = create_primitive_sphere(name="Head", location=(0, 2.5, 0), radius=0.4, color=(1.0, 0.8, 0.6))
    
    # Use scale parameter for non-uniform dimensions (Blender 5.1 verified!)
    body = create_primitive_cube(
        name="Body", 
        location=(0, 1.5, 0), 
        size=1.0,
        scale=Vector((0.7, 1.2, 0.3)),  # Non-uniform dimensions via scale!
        color=(0.3, 0.4, 0.8)
    )
    
    left_arm = create_primitive_cube(
        name="LeftArm", 
        location=(-0.7, 1.5, 0), 
        size=1.0,
        scale=Vector((0.25, 0.6, 0.25)),
        color=(0.3, 0.4, 0.8)
    )
    
    right_arm = create_primitive_cube(
        name="RightArm", 
        location=(0.7, 1.5, 0), 
        size=1.0,
        scale=Vector((0.25, 0.6, 0.25)),
        color=(0.3, 0.4, 0.8)
    )
    
    left_leg = create_primitive_cube(
        name="LeftLeg", 
        location=(-0.25, 0.6, 0), 
        size=1.0,
        scale=Vector((0.3, 0.9, 0.3)),
        color=(0.4, 0.4, 0.6)
    )
    
    right_leg = create_primitive_cube(
        name="RightLeg", 
        location=(0.25, 0.6, 0), 
        size=1.0,
        scale=Vector((0.3, 0.9, 0.3)),
        color=(0.4, 0.4, 0.6)
    )

    char_collection = bpy.data.collections.new("Character_Man")
    bpy.context.scene.collection.children.link(char_collection)

    for part in [head, body, left_arm, right_arm, left_leg, right_leg]:
        if part.users_collection:
            for col in list(part.users_collection):
                if "Character_Man" not in col.name:
                    char_collection.objects.link(part)

    head["character_part"] = "head"
    body["character_part"] = "body"
    left_arm["character_part"] = "left_arm"
    right_arm["character_part"] = "right_arm"
    left_leg["character_part"] = "left_leg"
    right_leg["character_part"] = "right_leg"

    print("✓ Character parts created\n")
    return {'head': head, 'body': body, 'left_arm': left_arm, 'right_arm': right_arm, 'left_leg': left_leg, 'right_leg': right_leg}


def create_ball_in_hand(character_parts):
    """Create a ball in the character's hand with COPY_LOCATION constraint."""
    print("\n=== Creating Ball with Constraint ===\n")

    right_arm = character_parts['right_arm']

    ball = create_primitive_sphere(name="Ball", location=(0.7, 1.8, 0), radius=0.25, color=(0.9, 0.1, 0.1))
    ball["constrained_to"] = right_arm.name

    print(f"✓ Ball created at {ball.location}")

    try:
        con = ball.constraints.new('COPY_LOCATION')
        con.target = right_arm
        con.influence = 1.0
        con.mute = False
        print(f"✓ Added COPY_LOCATION constraint: {ball.name} → {right_arm.name}")
    except Exception as e:
        print(f"✗ Failed to add constraint: {e}")

    return ball


def verify_constraints(character_parts, ball):
    """Verify all constraints are properly set up."""
    print("\n=== Verifying Constraints ===\n")

    for obj_name in character_parts.keys():
        obj = character_parts[obj_name]
        if obj.constraints:
            print(f"✓ {obj.name} has {len(obj.constraints)} constraint(s):")
            for i, con in enumerate(obj.constraints, 1):
                status = "ENABLED" if not con.mute else "MUTED"
                print(f"    {i}. [{status}] {con.type}")
        else:
            print(f"- {obj.name}: No constraints")

    if ball.constraints:
        print(f"\n✓ Ball ({ball.name}) has {len(ball.constraints)} constraint(s):")
        for i, con in enumerate(ball.constraints, 1):
            target_name = con.target.name if con.target else "None"
            status = "ENABLED" if not con.mute else "MUTED"
            print(f"    {i}. [{status}] {con.type} → Target: {target_name}")


def setup_camera_and_lighting():
    """Setup basic camera and lighting for viewing."""
    print("\n=== Setting up Scene ===\n")

    bpy.ops.object.camera_add(location=(5, -5, 3), align='WORLD')
    cam = bpy.context.active_object
    if cam:
        cam.rotation_euler = (1.57, 0, -0.78)
        print("✓ Camera positioned")

    bpy.ops.object.light_add(type='SUN', location=(3, 2, 4))
    light = bpy.context.active_object
    if light:
        print("✓ Sun light added\n")


def select_all_parts(character_parts):
    """Select all character parts for easy viewing in viewport."""
    print("\n=== Selecting Character Parts ===\n")

    bpy.context.view_layer.objects.active = character_parts['body']

    for part_name, part_obj in character_parts.items():
        if part_name != 'collection':
            part_obj.select_set(True)

    print(f"✓ Selected {len(character_parts)} objects\n")


def main():
    """Main execution function."""
    print("=" * 60)
    print("Blender 5.1 - Man with Ball Constraint Demo (FIXED)")
    print("=" * 60)

    clear_scene()
    character_parts = create_character()
    ball = create_ball_in_hand(character_parts)
    setup_camera_and_lighting()
    select_all_parts(character_parts)
    verify_constraints(character_parts, ball)

    print("\n" + "=" * 60)
    print("Demo Complete!")
    print("=" * 60)
    print("\n🎮 Test Instructions:")
    print("1. Select the character parts in Outliner")
    print("2. Move 'RightArm' or any body part (G key)")
    print("3. Ball will follow the hand automatically!")
    print("4. Check Object Properties > Constraints to verify setup\n")


if __name__ == "__main__":
    main()

```

*tags: #objects #constraints #animation #rigging #character*
