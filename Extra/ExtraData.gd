class_name ExtraData
extends Resource

@export var extra_id : String = ""
@export var title : String = "Nouvel Extra"
@export var thumbnail : Texture2D
@export_multiline var context_text : String = ""
@export var content_blocks : Array[ExtraContentBlock] = []
@export var is_unlocked : bool = false
