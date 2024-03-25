@tool
class_name MeshPrepare
extends Node3D


enum CollisionType {
	NO_COLLISION,
	CONVEX,
	CONVEX_SIMPLE,
	CONVEX_MULTIPLE,
	TRIMESH,
	BOUNDARY_BOX
}

const NAVIGATION_GROUP:= "navigation_meshprepare_group"
const NAVIGATION_NAME:= "generated_navigation_mesh"

@export var collision_type: CollisionType = CollisionType.CONVEX_SIMPLE
@export var navigation_mesh: NavigationMesh
@export var boundary_delta_size: Vector3 = Vector3.ZERO
@export var prepare: bool = false :
	get:
		return prepare
	set(value):
		if navigation_mesh:
			navigation_mesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
			navigation_mesh.geometry_source_group_name = NAVIGATION_GROUP
		prepare = false
		#if owner != self:
			#make_local(self, owner)
		for child in get_children(true):
			if child is MeshInstance3D:
				for i in child.get_children():
					if i.name.contains(child.name+"_col"):
						i.queue_free()
		await get_tree().physics_frame
		await get_tree().physics_frame
		for child in get_children(true):
			if child is MeshInstance3D:
				match collision_type:
					CollisionType.CONVEX:
						child.create_convex_collision(true, false)
					CollisionType.CONVEX_SIMPLE:
						child.create_convex_collision(true, true)
					CollisionType.CONVEX_MULTIPLE:
						child.create_multiple_convex_collisions()
					CollisionType.TRIMESH:
						child.create_trimesh_collision()
					CollisionType.BOUNDARY_BOX:
						var body: StaticBody3D = StaticBody3D.new()
						var box: AABB = child.get_aabb()
						var shape: CollisionShape3D = CollisionShape3D.new()
						shape.shape = BoxShape3D.new()
						shape.shape.size = box.size + boundary_delta_size
						shape.position = box.position + box.size / 2
						body.name = child.name+"_col"
						child.add_child(body)
						body.add_child(shape)
						
				for i in child.get_children():
					if i.name.contains(child.name+"_col"):
						i.owner = owner
						for j in i.get_children(true):
							j.owner = owner
				var navigation: NavigationRegion3D = child.get_node_or_null("./"+ NAVIGATION_NAME)
				if not navigation_mesh:
					if navigation:
						navigation.queue_free()
					continue
				child.add_to_group(NAVIGATION_GROUP, true)
				if not navigation:
					navigation = NavigationRegion3D.new()
					navigation.name = NAVIGATION_NAME
					child.add_child(navigation)
					navigation.owner = owner
				navigation.navigation_mesh = navigation_mesh.duplicate()
				navigation.bake_navigation_mesh(true)
				navigation.navigation_mesh.cell_height = ProjectSettings.get_setting("navigation/3d/default_cell_height", 0.01)
				navigation.navigation_mesh.cell_size = ProjectSettings.get_setting("navigation/3d/default_cell_size", 0.01)
				child.remove_from_group(NAVIGATION_GROUP)
