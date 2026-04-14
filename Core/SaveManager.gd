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

var pending_load_data = null

func save_game(slot_id: int, player_node: Node2D):
	var level = get_tree().current_scene
	var save_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"level_path": level.scene_file_path,
		"player_x": player_node.global_position.x if player_node else 0,
		"player_y": player_node.global_position.y if player_node else 0,
		"memory_item_paths": [],
		"doors_data": {}
	}
	
	# Récupère l'état de la mémoire par NodePath relatif
	for item in MemoryManager.get_on_items():
		if is_instance_valid(item):
			save_data["memory_item_paths"].append(str(level.get_path_to(item)))
			
	# Récupère l'état de chaque porte
	for child in level.get_children():
		if child is SequenceDoor:
			save_data["doors_data"][child.name] = child.is_open
			
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open(get_save_path(slot_id), FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("Partie sauvegardée dans le slot ", slot_id)

func load_game(slot_id: int):
	if not has_save(slot_id):
		return
		
	var file = FileAccess.open(get_save_path(slot_id), FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(content)
	
	if err == OK:
		var data = json.get_data()
		pending_load_data = data
		if data.has("level_path"):
			get_tree().change_scene_to_file(data["level_path"])

func apply_load(level_node: Node):
	if pending_load_data == null:
		return
		
	# 1. Joindre le joueur
	var player = level_node.get_node_or_null("Player")
	if player:
		player.global_position = Vector2(pending_load_data.get("player_x", 0), pending_load_data.get("player_y", 0))
		player.target_position = player.global_position
		
	# 2. Reconstruire la mémoire ui et la carte
	MemoryManager.ui_items.clear()
	MemoryManager.map_items.clear()
	if pending_load_data.has("memory_item_paths"):
		for node_path in pending_load_data.memory_item_paths:
			var item = level_node.get_node_or_null(node_path)
			if item:
				MemoryManager.process_on(item)
				MemoryManager.process_light(item)
				
	# 3. Réouvrir les portes déjà craquées
	if pending_load_data.has("doors_data"):
		for door_name in pending_load_data.doors_data.keys():
			var is_door_open = pending_load_data.doors_data[door_name]
			if is_door_open:
				var door = level_node.get_node_or_null(door_name)
				if door and door is SequenceDoor:
					door.is_open = true
					door.collision.set_deferred("disabled", true)
					door.animhaut.play("open")
					door.animbas.play("open2")
					
	# On vide les données pour ne pas qu'un restart les réutilise par erreur
	pending_load_data = null
