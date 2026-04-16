extends CanvasLayer

# On ne met pas de chemin fixe ici
var label_node = null

func _ready():
	hide()
	# On cherche le nœud une première fois au démarrage
	_trouver_label()

func _trouver_label():
	if label_node == null:
		# DEBUG : On affiche tous les enfants pour voir ce qui se passe
		print("--- LISTE DES NOEUDS DANS DIALOGUE_MANAGER ---")
		for enfant in get_children():
			print("- ", enfant.name)
			for petit_enfant in enfant.get_children():
				print("  -- ", petit_enfant.name)
		
		# La recherche réelle
		label_node = find_child("Texte", true, false)
	return label_node

func afficher_texte(contenu: String):
	show()
	var lb = _trouver_label()
	if lb:
		lb.text = contenu
	else:
		print("ERREUR CRITIQUE : Nœud 'Texte' introuvable dans DialogueManager")

func fermer():
	hide()

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		call_deferred("fermer")
