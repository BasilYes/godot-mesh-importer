@tool
class_name TDImportedAsset
extends Node3D


@export var save: bool = false :
	set(value):
		save = false
		save_scene()
@export var bake_collision: bool = false :
	set(value):
		bake_collision = false
		execute_on_all_children(func(node:Node) -> void:
				if node is TDImportedMesh:
					node.bake_collision = false
					, self)
@export var collision_type: TDImportedMesh.CollisionType = TDImportedMesh.CollisionType.CONVEX_SIMPLE :
	set(value):
		collision_type = value
		var counter: Resource = Resource.new()
		counter.set_meta("counter", 0)
		execute_on_all_children(func(node:Node) -> void:
			if node is TDImportedMesh:
				counter.set_meta("counter", counter.get_meta("counter") + 1)
				counter.set_meta("mesh", node)
				, self)
		if counter.get_meta("counter") == 1:
			counter.get_meta("mesh").collision_type = collision_type


@export var source_file: String = ""
@export var save_scene_dir: String = ""
@export var save_meshes_dir: String = ""
@export var save_materials_dir: String = ""


static func execute_on_all_children(callable: Callable, node: Node) -> void:
	for i in node.get_children():
		execute_on_all_children(callable, i)
	callable.call(node)


func init(file_name: String, parent: TDAssetsImporter) -> void:
	if parent:
		name = file_name.get_basename()
		source_file = parent.sources_dir.path_join(file_name)
		save_scene_dir = parent.save_scenes_dir
		save_meshes_dir = parent.save_meshes_dir
		save_materials_dir = parent.save_materials_dir
		collision_type = parent.collision_type
		execute_on_all_children(func(node:Node) -> void:
			if node is MeshInstance3D:
				node.set_script(TDImportedMesh)
				node.init(self)
				, self)




func save_meshes() -> void:
	if not DirAccess.dir_exists_absolute(save_meshes_dir):
		return
	execute_on_all_children(func(node:Node) -> void:
				if node is MeshInstance3D:
					var save_name: String = node.mesh.resource_name
					var save_path: String = save_meshes_dir + "/" + save_name + ".res"
					ResourceSaver.save(node.mesh, save_path)
					node.mesh.resource_path = save_path
				, self)


func save_scene() -> void:
	if not DirAccess.dir_exists_absolute(save_scene_dir):
		return
	var packed_scene = PackedScene.new()
	var node: = duplicate(0)
	node.transform = Transform3D.IDENTITY
	for i in node.get_children():
		TDAssetsImporter.make_local(i, node)
	packed_scene.pack(node)
	node.queue_free()
	ResourceSaver.save(packed_scene, save_scene_dir + "/" + node.name + ".tscn")


func save_materials() -> void:
	if not DirAccess.dir_exists_absolute(save_materials_dir):
		return
	execute_on_all_children(func(node:Node) -> void:
				if node is MeshInstance3D:
					var counter: int = 0
					while node.mesh.get("surface_" + str(counter) + "/material"):
						var material: Material = node.mesh.get("surface_" + str(counter) + "/material")
						counter += 1
						if not material:
							continue
						var save_name: String = material.resource_name
						var save_path: String = save_materials_dir + "/" + save_name + ".res"
						ResourceSaver.save(material, save_path)
						material.resource_path = save_path
				, self)
