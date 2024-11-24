@tool
class_name TDAssetsImporter
extends Node3D


@export var reload: bool = false :
	set(value):
		reload = false
		global_transform = Transform3D.IDENTITY
		if not DirAccess.dir_exists_absolute(sources_dir):
			return
		_update_owned_dirs()
		_update_owned_models()
		_update_children_transform()
@export var bake_collision: bool = false :
	set(value):
		bake_collision = false
		for child in get_children():
			if child is TDAssetsImporter:
				child.bake_collision = false
			elif child is TDImportedAsset:
				child.bake_collision = false
@export var save: bool = false :
	set(value):
		save = false
		var save_scenes: = false
		var save_meshes: = false
		var save_materials: = false
		var save_shapes: = false
		if save_scenes_dir.begins_with("res://"):
			if not DirAccess.dir_exists_absolute(save_scenes_dir):
				DirAccess.make_dir_recursive_absolute(save_scenes_dir)
			save_scenes = true
		if save_meshes_dir.begins_with("res://"):
			if not DirAccess.dir_exists_absolute(save_meshes_dir):
				DirAccess.make_dir_recursive_absolute(save_meshes_dir)
			save_meshes = true
		if save_materials_dir.begins_with("res://"):
			if not DirAccess.dir_exists_absolute(save_materials_dir):
				DirAccess.make_dir_recursive_absolute(save_materials_dir)
			save_materials = true
		if save_shapes_dir.begins_with("res://"):
			if not DirAccess.dir_exists_absolute(save_shapes_dir):
				DirAccess.make_dir_recursive_absolute(save_shapes_dir)
			save_shapes = true
		
		for child in get_children():
			if child is TDAssetsImporter:
				child.save = false
			elif child is TDImportedAsset:
				if save_scenes:
					child.save_scene()
				if save_meshes:
					child.save_meshes()
				if save_materials:
					child.save_materials()
				if save_shapes:
					child.save_shapes()

@export_dir var sources_dir: String = ""

@export var create_scenes_subdir: bool = true :
	set(value):
		if value == create_scenes_subdir:
			return
		create_scenes_subdir = value
		var parent: Node = get_parent()
		if parent is TDAssetsImporter:
			if create_scenes_subdir:
				save_scenes_dir = parent.save_scenes_dir.path_join(name)
			else:
				save_scenes_dir = save_scenes_dir
@export var update_create_scenes_subdir_recursive: bool = false :
	set(value):
		update_create_scenes_subdir_recursive = false
		for child in get_children():
			if child is TDAssetsImporter:
				child.create_scenes_subdir = create_scenes_subdir
				child.update_create_scenes_subdir_recursive = false
@export_dir var save_scenes_dir: String = "" :
	set(value):
		save_scenes_dir = value
		for child in get_children():
			if child is TDAssetsImporter:
				if child.create_scenes_subdir:
					child.save_scenes_dir = save_scenes_dir.path_join(child.name)
				else:
					child.save_scenes_dir = save_scenes_dir
			elif child is TDImportedAsset:
				child.save_scene_dir = save_scenes_dir

@export var create_meshes_subdir: bool = true :
	set(value):
		if value == create_meshes_subdir:
			return
		create_meshes_subdir = value
		var parent: Node = get_parent()
		if parent is TDAssetsImporter:
			if create_meshes_subdir:
				save_meshes_dir = parent.save_meshes_dir.path_join(name)
			else:
				save_meshes_dir = save_meshes_dir
@export var update_create_meshes_subdir_recursive: bool = false :
	set(value):
		update_create_meshes_subdir_recursive = false
		for child in get_children():
			if child is TDAssetsImporter:
				child.create_meshes_subdir = create_meshes_subdir
				child.update_create_meshes_subdir_recursive = false
@export_dir var save_meshes_dir: String = "" :
	set(value):
		save_meshes_dir = value
		for child in get_children():
			if child is TDAssetsImporter:
				if child.create_meshes_subdir:
					child.save_meshes_dir = save_meshes_dir.path_join(child.name)
				else:
					child.save_meshes_dir = save_meshes_dir
			elif child is TDImportedAsset:
				child.save_meshes_dir = save_meshes_dir

@export var create_materials_subdir: bool = true :
	set(value):
		if value == create_materials_subdir:
			return
		create_materials_subdir = value
		var parent: Node = get_parent()
		if parent is TDAssetsImporter:
			if create_materials_subdir:
				save_materials_dir = parent.save_materials_dir.path_join(name)
			else:
				save_materials_dir = save_materials_dir
@export var update_create_materials_subdir_recursive: bool = false :
	set(value):
		update_create_materials_subdir_recursive = false
		for child in get_children():
			if child is TDAssetsImporter:
				child.create_materials_subdir = create_materials_subdir
				child.update_create_materials_subdir_recursive = false
@export_dir var save_materials_dir: String = "" :
	set(value):
		save_materials_dir = value
		for child in get_children():
			if child is TDAssetsImporter:
				if child.create_materials_subdir:
					child.save_materials_dir = save_materials_dir.path_join(child.name)
				else:
					child.save_materials_dir = save_materials_dir
			elif child is TDImportedAsset:
				child.save_materials_dir = save_materials_dir


@export var create_shapes_subdir: bool = true :
	set(value):
		if value == create_shapes_subdir:
			return
		create_shapes_subdir = value
		var parent: Node = get_parent()
		if parent is TDAssetsImporter:
			if create_shapes_subdir:
				save_shapes_dir = parent.save_shapes_dir.path_join(name)
			else:
				save_shapes_dir = save_shapes_dir
@export var update_create_shapes_subdir_recursive: bool = false :
	set(value):
		update_create_shapes_subdir_recursive = false
		for child in get_children():
			if child is TDAssetsImporter:
				child.create_shapes_subdir = create_shapes_subdir
				child.update_create_shapes_subdir_recursive = false
@export_dir var save_shapes_dir: String = "" :
	set(value):
		save_shapes_dir = value
		for child in get_children():
			if child is TDAssetsImporter:
				if child.create_shapes_subdir:
					child.save_shapes_dir = save_shapes_dir.path_join(child.name)
				else:
					child.save_shapes_dir = save_shapes_dir
			elif child is TDImportedAsset:
				child.save_shapes_dir = save_shapes_dir

@export var collision_type: TDImportedMesh.CollisionType = TDImportedMesh.CollisionType.CONVEX_SIMPLE 

@export var min_grid_size: float = 2.0

@export var scenes_type: Array[String] = ["glb", "gltf", "fbx"]

@export_storage var grid_size: float = 2.0
@export_storage var size: float = 2.0


static func make_local(node: Node, owner: Node) -> void:
	node.scene_file_path = ""
	node.owner = owner
	for child in node.get_children():
		make_local(child, owner)


func _init(directory: String = "", parent: TDAssetsImporter = null) -> void:
	if parent:
		name = directory
		
		sources_dir = parent.sources_dir.path_join(directory)
		
		create_scenes_subdir = parent.create_scenes_subdir
		if create_scenes_subdir:
			save_scenes_dir = parent.save_scenes_dir.path_join(directory)
		else:
			save_scenes_dir = parent.save_scenes_dir
		
		create_meshes_subdir = parent.create_meshes_subdir
		if create_meshes_subdir:
			save_meshes_dir = parent.save_meshes_dir.path_join(directory)
		else:
			save_meshes_dir = parent.save_meshes_dir
		
		create_materials_subdir = parent.create_materials_subdir
		if create_materials_subdir:
			save_materials_dir = parent.save_materials_dir.path_join(directory)
		else:
			save_materials_dir = parent.save_materials_dir
		
		create_shapes_subdir = parent.create_shapes_subdir
		if create_shapes_subdir:
			save_shapes_dir = parent.save_shapes_dir.path_join(directory)
		else:
			save_shapes_dir = parent.save_shapes_dir
			
		min_grid_size = parent.min_grid_size
		collision_type = parent.collision_type


func _update_owned_dirs() -> void:
	for i in DirAccess.get_directories_at(sources_dir):
		var sub_importer: Node = get_node_or_null(i)
		if sub_importer:
			if not sub_importer is TDAssetsImporter:
				var new_sub_importer: = TDAssetsImporter.new(i, self)
				sub_importer.replace_by(new_sub_importer)
				_update_child_owner(new_sub_importer)
				sub_importer = new_sub_importer
		else:
			sub_importer = TDAssetsImporter.new(i, self)
			add_child(sub_importer, true, Node.INTERNAL_MODE_DISABLED)
			_update_child_owner(sub_importer)
		sub_importer.reload = true


func _update_owned_models() -> void:
	for i in DirAccess.get_files_at(sources_dir):
		if i.get_extension() in scenes_type:
			if not get_node_or_null(i.get_basename()):
				var model: Node3D = load(sources_dir.path_join(i)).instantiate()
				add_child(model)
				_update_child_owner(model)
				make_local(model, model.owner)
				model.set_script(TDImportedAsset)
				model.init(i, self)
				model.set_meta("_edit_group_", true)


func _update_child_owner(node: Node) -> void:
	if owner:
		node.owner = owner
	else:
		node.owner = self


func _update_children_transform() -> void:
	grid_size = min_grid_size
	for i in get_children():
		if i is TDAssetsImporter and i.size > grid_size:
			grid_size = i.size
	
	var row_size: int = ceil(sqrt(get_child_count()))
	var counter: int = 0
	size = row_size * grid_size
	for child in get_children():
		if child is Node3D:
			child.global_transform = Transform3D.IDENTITY
			child.global_position.y = 0
			child.global_position.x = (counter / row_size - row_size / 2) * grid_size
			child.global_position.z = (counter % row_size - row_size / 2) * grid_size
			counter += 1
