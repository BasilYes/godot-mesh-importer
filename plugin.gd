@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
			"AssetImporter",
			"Node3D",
			preload("res://addons/3d_assets_importer/assets_importer.gd"),
			null)


func _exit_tree():
	remove_custom_type("AssetImporter")
