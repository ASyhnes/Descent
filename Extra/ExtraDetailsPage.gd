extends Control

signal details_closed

@onready var title_label = $VBoxContainer/Header/Title
@onready var context_text = $VBoxContainer/ScrollContainer/ContentList/ContextText
@onready var content_list = $VBoxContainer/ScrollContainer/ContentList
@onready var close_button = $VBoxContainer/Header/CloseButton
@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var image_overlay = $ImageOverlay
@onready var expanded_image = $ImageOverlay/ExpandedImage

var liste_images: Array[Texture2D] = []
var index_image_courante: int = 0

func _ready():
	close_button.pressed.connect(fermer)
	image_overlay.hide()
	hide()

func _input(event):
	if image_overlay.visible:
		if event.is_action_pressed("ui_left"):
			if liste_images.size() > 1:
				index_image_courante -= 1
				if index_image_courante < 0:
					index_image_courante = liste_images.size() - 1
				expanded_image.texture = liste_images[index_image_courante]
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			if liste_images.size() > 1:
				index_image_courante += 1
				if index_image_courante >= liste_images.size():
					index_image_courante = 0
				expanded_image.texture = liste_images[index_image_courante]
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
			image_overlay.hide()
			get_viewport().set_input_as_handled()

func _process(delta):
	# On évite le scroll si l'overlay est ouvert
	if visible and not image_overlay.visible:
		var scroll_speed = 600 * delta
		if Input.is_action_pressed("ui_down"):
			scroll_container.scroll_vertical += int(scroll_speed)
		elif Input.is_action_pressed("ui_up"):
			scroll_container.scroll_vertical -= int(scroll_speed)

func afficher(data: ExtraData):
	liste_images.clear()
	index_image_courante = 0
	title_label.text = data.title
	context_text.text = data.context_text
	
	# Nettoyer les anciens blocs ajoutés dynamiquement
	for child in content_list.get_children():
		if child != context_text and child.name != "IntroText":
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
			var center = CenterContainer.new()
			
			var btn = TextureButton.new()
			btn.texture_normal = block.image_content
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_SCALE
			
			# Calculer la taille exacte pour que le bouton prenne la même forme que l'image
			var texture_size = block.image_content.get_size()
			if texture_size.y > 0:
				var ratio = texture_size.x / texture_size.y
				btn.custom_minimum_size = Vector2(400 * ratio, 400)
			
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			
			liste_images.append(block.image_content)
			
			var contour = ReferenceRect.new()
			contour.border_color = Color(0.2, 0.2, 0.2, 0.8) # Gris très sombre
			contour.border_width = 4
			contour.editor_only = false
			contour.set_anchors_preset(Control.PRESET_FULL_RECT)
			contour.hide()
			btn.add_child(contour)
			
			btn.focus_entered.connect(contour.show)
			btn.focus_exited.connect(contour.hide)
			btn.mouse_entered.connect(contour.show)
			btn.mouse_exited.connect(func(): if not btn.has_focus(): contour.hide())
			
			btn.pressed.connect(func(): _agrandir_image(block.image_content))
			
			center.add_child(btn)
			content_list.add_child(center)
			
	scroll_container.scroll_vertical = 0
	show()
	close_button.grab_focus()

func _agrandir_image(tex: Texture2D):
	if liste_images.has(tex):
		index_image_courante = liste_images.find(tex)
	expanded_image.texture = tex
	image_overlay.show()

func fermer():
	if image_overlay.visible:
		image_overlay.hide()
	else:
		hide()
		details_closed.emit()
