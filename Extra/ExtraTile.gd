extends Button

signal tile_selectionnee(data)

@onready var thumbnail = $VBoxContainer/Thumbnail
@onready var title_label = $VBoxContainer/Title
@onready var lock_overlay = $LockOverlay

var mon_data : ExtraData

func _ready():
	pressed.connect(_on_pressed)

func configurer(data: ExtraData):
	mon_data = data
	title_label.text = data.title
	if data.thumbnail:
		thumbnail.texture = data.thumbnail
	
	if not data.is_unlocked:
		lock_overlay.show()
		disabled = true
	else:
		lock_overlay.hide()
		disabled = false

func _on_pressed():
	if mon_data and mon_data.is_unlocked:
		tile_selectionnee.emit(mon_data)
