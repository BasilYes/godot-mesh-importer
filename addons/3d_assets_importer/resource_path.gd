class_name TDResourcePath
extends Resource


@export var create_subdir: bool = true :
	set(value):
		if value == create_subdir:
			return
		create_subdir = value
		if parent_path:
			if create_subdir:
				save_dir = parent_path.save_dir.path_join(owner.name)
			else:
				save_dir = parent_path.save_dir
@export var update_create_subdir_recursive: bool = false :
	set(value):
		update_create_subdir_recursive = false
		for child in children_paths:
			child.create_subdir = create_subdir
			child.update_create_subdir_recursive = false
@export_dir var save_dir: String = "" :
	set(value):
		save_dir = value
		for child in children_paths:
			if child.create_subdir:
				child.save_dir = save_dir.path_join(child.name)
			else:
				child.save_dir = save_dir
@export_storage var save_root_dir: String = ""


@export_storage var owner: Node
@export_storage var parent_path: TDResourcePath
@export_storage var children_paths: Array[TDResourcePath]


func _init(owner: Node, parent: TDResourcePath = null):
	self.owner = owner
	if parent:
		parent_path = parent
