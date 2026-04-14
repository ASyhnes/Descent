extends CanvasLayer

@onready var slot1_btn = $Panel/VBoxContainer/Slot1
@onready var slot2_btn = $Panel/VBoxContainer/Slot2
@onready var slot3_btn = $Panel/VBoxContainer/Slot3
@onready var cancel_btn = $Panel/VBoxContainer/CancelButton

var player_node_ref = null

func _ready():
	hide()
	slot1_btn.pressed.connect(func(): _on_slot_pressed(1))
	slot2_btn.pressed.connect(func(): _on_slot_pressed(2))
	slot3_btn.pressed.connect(func(): _on_slot_pressed(3))
	cancel_btn.pressed.connect(fermer)

func ouvrir(player_ref):
	player_node_ref = player_ref
	# Mise à jour de l'affichage des slots
	slot1_btn.text = SaveManager.get_save_info(1)
	slot2_btn.text = SaveManager.get_save_info(2)
	slot3_btn.text = SaveManager.get_save_info(3)
	show()
	get_tree().paused = true
	slot1_btn.grab_focus()

func _on_slot_pressed(slot_id: int):
	if SaveManager:
		SaveManager.save_game(slot_id, player_node_ref)
	fermer()

func fermer():
	hide()
	get_tree().paused = false
