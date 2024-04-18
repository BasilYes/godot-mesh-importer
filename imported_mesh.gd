@tool
class_name TDImportedMesh
extends MeshInstance3D


enum CollisionType {
	NO_COLLISION,
	CONVEX,
	CONVEX_SIMPLE,
	CONVEX_MULTIPLE,
	TRIMESH,
	BOUNDARY_BOX
}

@export var bake_collision: bool = false :
	set(value):
		bake_collision = false
		for i in get_children():
			if i.name.contains(name+"_col"):
				i.queue_free()
		await get_tree().physics_frame
		await get_tree().physics_frame
		match collision_type:
			CollisionType.CONVEX:
				create_convex_collision(true, false)
			CollisionType.CONVEX_SIMPLE:
				create_convex_collision(true, true)
			CollisionType.CONVEX_MULTIPLE:
				create_multiple_convex_collisions()
			CollisionType.TRIMESH:
				create_trimesh_collision()
			CollisionType.BOUNDARY_BOX:
				var body: StaticBody3D = StaticBody3D.new()
				var box: AABB = get_aabb()
				var shape: CollisionShape3D = CollisionShape3D.new()
				shape.shape = BoxShape3D.new()
				shape.shape.size = box.size
				shape.position = box.position + box.size / 2
				add_child(body)
				body.owner = owner
				body.name = name+"_col"
				body.add_child(shape)
				shape.owner = owner
				shape.name = name+"_shape"

@export var collision_type: CollisionType = CollisionType.CONVEX_SIMPLE


func init(parent: TDImportedAsset) -> void:
	if parent:
		collision_type = parent.collision_type

