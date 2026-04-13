extends CanvasLayer

@onready var slot_container = $MarginContainer/SlotContainer

# On charge notre modèle de slot
var slot_scene = preload("res://UI/MemorySlot.tscn")

# Cette liste gardera la trace des slots créés
var active_slots = []

func _ready():
	# 1. On se connecte au signal de notre Autoload (le cerveau)
	MemoryManager.memory_changed.connect(update_ui)
	
	# 2. On crée le bon nombre de slots en fonction de la capacité du niveau
	setup_slots()
	
	# 3. Première mise à jour visuelle
	update_ui()

func setup_slots():
	# On vide d'abord le container au cas où
	for child in slot_container.get_children():
		child.queue_free()
	active_slots.clear()
	
	# On boucle pour créer autant de slots que la capacité (ex: 3)
	for i in range(MemoryManager.capacity):
		var new_slot = slot_scene.instantiate()
		slot_container.add_child(new_slot)
		active_slots.append(new_slot)

func update_ui():
	# On récupère SEULEMENT les objets qui sont en statut "ON"
	var items_in_memory = MemoryManager.get_on_items()
	
	# On parcourt tous nos slots visuels (0, 1, 2...)
	for i in range(active_slots.size()):
		var slot = active_slots[i]
		var icon_node = slot.get_node("ItemIcon")
		
		# Si on a un objet "ON" correspondant à cet index
		if i < items_in_memory.size():
			# On récupère l'objet
			var item = items_in_memory[i]
			# On affiche son icône (le PNG défini dans l'inspecteur de l'objet)
			icon_node.texture = item.item_icon
			icon_node.show()
		else:
			# Sinon, le slot est vide, on cache l'icône
			icon_node.hide()
			icon_node.texture = null
