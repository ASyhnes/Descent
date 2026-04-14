extends Node

const SAVE_DIR = "user://saves/"

func _ready():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func get_save_path(slot_id: int) -> String:
	return SAVE_DIR + "slot_" + str(slot_id) + ".save"

func has_save(slot_id: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot_id))

func get_save_info(slot_id: int) -> String:
	if not has_save(slot_id):
		return "Slot " + str(slot_id) + " - Vide"
	
	var file = FileAccess.open(get_save_path(slot_id), FileAccess.READ)
	if not file:
		return "Slot " + str(slot_id) + " - Erreur"
	
	var content = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK:
		var data = json.get_data()
		if data.has("timestamp"):
			return "Slot " + str(slot_id) + " - Sauvegarde"
	
	return "Slot " + str(slot_id) + " - Données existantes"

func save_game(slot_id: int, player_node: Node2D):
	var save_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"level_path": get_tree().current_scene.scene_file_path,
		"player_x": player_node.global_position.x if player_node else 0,
		"player_y": player_node.global_position.y if player_node else 0,
		"memory_item_ids": []
	}
	
	# Récupère l'état de la mémoire
	for item in MemoryManager.get_on_items():
		if item and "item_id" in item:
			save_data["memory_item_ids"].append(item.item_id)
			
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open(get_save_path(slot_id), FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("Partie sauvegardée dans le slot ", slot_id)

func load_game(slot_id: int):
	if not has_save(slot_id):
		print("Aucune sauvegarde dans le slot ", slot_id)
		return
		
	var file = FileAccess.open(get_save_path(slot_id), FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(content)
	
	if err == OK:
		var data = json.get_data()
		if data.has("level_path"):
			get_tree().change_scene_to_file(data["level_path"])
		print("Partie chargée depuis le slot ", slot_id)
