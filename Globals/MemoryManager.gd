extends Node

signal memory_changed

var capacity : int = 3

# Nos deux mémoires indépendantes
var ui_items : Array = []  # Ne stocke que les objets ON
var map_items : Array = [] # Ne stocke que les objets LIGHT

func set_capacity(new_capacity: int):
	capacity = new_capacity

# --- GESTION DE LA CARTE (LIGHT) ---
func process_light(item):
	# Si l'objet est déjà allumé, on le remet à la fin de la file (pour qu'il soit le plus récent)
	if map_items.has(item):
		map_items.erase(item)
		map_items.push_back(item)
		return

	# Si la mémoire de la carte est pleine, on éteint le plus vieux
	if map_items.size() >= capacity:
		var oldest_map_item = map_items.pop_front()
		if oldest_map_item:
			oldest_map_item.set_light_visual(false)

	# On ajoute le nouveau et on l'allume
	map_items.push_back(item)
	item.set_light_visual(true)

# --- GESTION DE L'UI (ON) ---
func process_on(item):
	# Si l'objet est déjà dans l'UI, on ne fait rien
	if ui_items.has(item):
		return

	# Si la mémoire UI est pleine, on éjecte le plus vieux
	if ui_items.size() >= capacity:
		ui_items.pop_front() # On l'enlève juste de la liste UI (pas d'impact visuel sur la carte)

	# On ajoute le nouvel objet dans l'UI
	ui_items.push_back(item)
	memory_changed.emit() # On prévient l'UI de se mettre à jour

# Fonction pour l'UI et les portes
func get_on_items() -> Array:
	return ui_items
