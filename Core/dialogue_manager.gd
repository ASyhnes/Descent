extends CanvasLayer

var label_node : RichTextLabel = null
var _proprietaire = null  # Nœud propriétaire du dialogue (gère la pagination)

# --- Typewriter ---
var _texte_complet : String = ""
var is_typing : bool = false          # true si le texte est encore en cours d'écriture
var vitesse_ecriture : float = 40.0  # caractères par seconde
var _timer : float = 0.0

func _ready():
	hide()
	_trouver_label()

func _trouver_label() -> RichTextLabel:
	if label_node == null:
		print("--- LISTE DES NOEUDS DANS DIALOGUE_MANAGER ---")
		for enfant in get_children():
			print("- ", enfant.name)
			for petit_enfant in enfant.get_children():
				print("  -- ", petit_enfant.name)
		label_node = find_child("Texte", true, false) as RichTextLabel
	return label_node

func _process(delta):
	if not is_typing or not label_node:
		return
	_timer += delta
	var nb = int(_timer * vitesse_ecriture)
	if nb >= label_node.get_total_character_count():
		# Texte entièrement affiché
		label_node.visible_characters = -1  # -1 = tout afficher
		is_typing = false
	else:
		label_node.visible_characters = nb

# Affiche un texte avec effet typewriter.
# proprietaire : nœud qui implémente on_dialogue_advance() (optionnel)
func afficher_texte(contenu: String, proprietaire = null):
	_proprietaire = proprietaire
	_texte_complet = contenu
	_timer = 0.0
	is_typing = true
	show()
	var lb = _trouver_label()
	if lb:
		lb.text = contenu           # On charge tout le texte (BBCode parsé)
		lb.visible_characters = 0  # Mais on n'en affiche aucun au départ
	else:
		print("ERREUR CRITIQUE : Nœud 'Texte' introuvable dans DialogueManager")

# Termine l'écriture instantanément (si typewriter en cours)
func completer_texte():
	if is_typing and label_node:
		label_node.visible_characters = -1
		is_typing = false

func fermer():
	_proprietaire = null
	is_typing = false
	hide()

func get_proprietaire():
	return _proprietaire
