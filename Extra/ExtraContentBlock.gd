class_name ExtraContentBlock
extends Resource

enum ContentType { TEXT, IMAGE }

@export var type : ContentType = ContentType.TEXT
@export_multiline var text_content : String = ""
@export var image_content : Texture2D
