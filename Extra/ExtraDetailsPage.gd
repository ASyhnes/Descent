extends Control

signal details_closed

@onready var title_label = $VBoxContainer/Header/Title
@onready var context_text = $VBoxContainer/ScrollContainer/ContentList/ContextText
@onready var content_list = $VBoxContainer/ScrollContainer/ContentList
@onready var close_button = $VBoxContainer/Header/CloseButton
@onready var scroll_container = $VBoxContainer/ScrollContainer

func _ready():
	close_button.pressed.connect(fermer)
	hide()

func _process(delta):
	if visible:
		var scroll_speed = 600 * delta
		if Input.is_action_pressed("ui_down"):
			scroll_container.scroll_vertical += int(scroll_speed)
		elif Input.is_action_pressed("ui_up"):
			scroll_container.scroll_vertical -= int(scroll_speed)

func afficher(data: ExtraData):
	title_label.text = data.title
	context_text.text = data.context_text
	
	# Nettoyer les anciens blocs ajoutés dynamiquement
	for child in content_list.get_children():
		if child != context_text:
			child.queue_free()
	
	# Instancier dynamiquement les content_blocks
	for block in data.content_blocks:
		if not block: continue
		
		if block.type == ExtraContentBlock.ContentType.TEXT:
			var txt = Label.new()
			txt.text = block.text_content
			txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			txt.add_theme_color_override("font_color", Color(0,0,0,1))
			txt.add_theme_font_size_override("font_size", 24)
			content_list.add_child(txt)
		elif block.type == ExtraContentBlock.ContentType.IMAGE:
			var tex = TextureRect.new()
			tex.texture = block.image_content
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.custom_minimum_size = Vector2(0, 400)
			content_list.add_child(tex)
			
	scroll_container.scroll_vertical = 0
	show()
	close_button.grab_focus()

func fermer():
	hide()
	details_closed.emit()
