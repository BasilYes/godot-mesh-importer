@tool
class_name MultimeshPrepare
extends Node3D

@export var prepare: bool = false :
	set(value):
		prepare = false
		global_transform = Transform3D.IDENTITY
		var row_size: int = roundi(sqrt(get_child_count()))
		var counter: int = 0
		for child in get_children():
			if child is Node3D:
				if child.scene_file_path:
					child.name = child.scene_file_path.get_file().get_basename()
					make_local(child, child.owner)
				child.global_transform = Transform3D.IDENTITY
				child.global_position.y = 0
				child.global_position.x = (counter / row_size - row_size / 2) * grid_size
				child.global_position.z = (counter % row_size - row_size / 2) * grid_size
				counter += 1
				set_editable_instance(child, true)
				
				if not child is MeshPrepare:
					child.set_script(MeshPrepare)
					child.collision_type = collision_type
					child.navigation_mesh = navigation_mesh
					child.prepare = false
				elif override_navigation or override_collision:
					if override_navigation:
						child.navigation_mesh = navigation_mesh
						child.boundary_delta_size = boundary_delta_size
					if override_collision:
						child.collision_type = collision_type
					child.prepare = false
@export var save: bool = false :
	set(value):
		save = false
		var save_scenes: bool = save_meshes_dir and DirAccess.dir_exists_absolute(save_meshes_dir)
		var save_meshes: bool = save_scenes_dir and DirAccess.dir_exists_absolute(save_scenes_dir)
		var save_shapes: bool = save_shapes_dir and DirAccess.dir_exists_absolute(save_shapes_dir)
		if not (save_meshes or save_scenes or save_shapes):
			return
		for child in get_children():
			if child is Node3D:
				if save_meshes:
					var mesh_id: int = 0
					execute_on_all_children(func(node:Node) -> void:
						if node is MeshInstance3D:
							var save_name: String = node.name + "_mesh_" + str(mesh_id)
							node.mesh.resource_name = save_name
							var save_path: String = save_meshes_dir + "/" + save_name + ".tres"
							ResourceSaver.save(node.mesh, save_path)
							node.mesh.resource_path = save_path
						, child)
				if true:
					var shape_id: int = 0
					execute_on_all_children(func(node:Node) -> void:
						if node is CollisionShape3D:
							var save_name: String = child.name + "_shape_" + str(shape_id)
							node.shape.resource_name = save_name
							var save_path: String = save_shapes_dir + "/" + save_name + ".tres"
							ResourceSaver.save(node.shape, save_path)
							node.shape.resource_path = save_path
						, child)
				if save_scenes:
					var packed_scene = PackedScene.new()
					var node: = child.duplicate(DUPLICATE_USE_INSTANTIATION)
					var trans: Transform3D = node.transform
					node.transform = Transform3D.IDENTITY
					for i in node.get_children():
						make_local(i, node)
					packed_scene.pack(node)
					node.queue_free()
					ResourceSaver.save(packed_scene, save_scenes_dir + "/" + node.name + ".tscn")
@export var optimize_meshlib: bool = false :
	set(value):
		optimize_meshlib = false
		if not FileAccess.file_exists(mesh_lib_path):
			return
		if not save_meshes_dir or not DirAccess.dir_exists_absolute(save_meshes_dir):
			return
		var mesh_lib: MeshLibrary = load(mesh_lib_path)
		for i in mesh_lib.get_item_list():
			var mesh_path: String = save_meshes_dir + "/" + mesh_lib.get_item_mesh(i).resource_name + ".tres"
			if FileAccess.file_exists(mesh_path):
				var mesh: Mesh = load(mesh_path)
				if mesh:
					mesh_lib.set_item_mesh(i, mesh)
			var shapes: Array = mesh_lib.get_item_shapes(i)
			for shape_id in shapes.size():
				if shapes[shape_id] is Shape3D:
					var shape_path: String = save_shapes_dir + "/" + shapes[shape_id].resource_name + ".tres"
					if FileAccess.file_exists(shape_path):
						var shape: Shape3D = load(shape_path)
						if shape:
							shapes[shape_id] = shape
			mesh_lib.set_item_shapes(i, shapes)
		ResourceSaver.save(mesh_lib, mesh_lib_path)
@export_dir var save_scenes_dir: String = ""
@export_dir var save_meshes_dir: String = ""
@export_dir var save_shapes_dir: String = ""
@export_file("*.meshlib", "*.tres", "*.res") var mesh_lib_path: String = ""
@export var navigation_mesh: NavigationMesh
@export var override_navigation: bool = false
@export var override_collision: bool = false
@export var collision_type: MeshPrepare.CollisionType = MeshPrepare.CollisionType.CONVEX_SIMPLE
@export var boundary_delta_size: Vector3 = Vector3.ZERO
@export var grid_size: float = 1.0
@export_category("WARNING")
@export var clean: bool = false :
	set(value):
		clean = false
		for child in get_children():
			child.queue_free()

static func make_local(node: Node, owner: Node) -> void:
	node.scene_file_path = ""
	node.owner = owner
	for child in node.get_children():
		make_local(child, owner)

static func execute_on_all_children(callable: Callable, node: Node) -> void:
	callable.call(node)
	for i in node.get_children():
		execute_on_all_children(callable, i)
