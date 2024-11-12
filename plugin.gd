@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
			"AssetImporter",
			"Node3D",
			preload("assets_importer.gd"),
			null)


func _exit_tree():
	remove_custom_type("AssetImporter")
