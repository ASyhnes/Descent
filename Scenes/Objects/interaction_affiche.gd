class_name AfficheInteractible
extends Area2D

@export var pages_de_texte : Array[String] = ["Texte par défaut"]
@export_enum("Haut", "Bas", "Gauche", "Droite", "Peu importe") var direction_requise : String = "Haut"

var joueur_proche : bool = false
var joueur_ref = null
var dialogue_actif : bool = false
var page_actuelle : int = 0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# --- API PUBLIQUE (appelée par player.gd) ---

# Ouverture initiale : appelée par CheckInteraction() quand DM n'est pas visible
func on_interact():
	if joueur_proche and verifier_direction() and not dialogue_actif:
		_demarrer_dialogue()

# Avancement de page : appelée par CheckInteraction() quand DM est visible et texte complet
# (le cas "texte en cours" est géré en amont par le joueur → completer_texte())
func on_dialogue_advance():
	_page_suivante()

# --- LOGIQUE INTERNE ---

func verifier_direction() -> bool:
	if direction_requise == "Peu importe":
		return true
	if not joueur_ref:
		return false
	var directions = {
		"Haut": Vector2(0, -1),
		"Bas": Vector2(0, 1),
		"Gauche": Vector2(-1, 0),
		"Droite": Vector2(1, 0)
	}
	return joueur_ref.cardinal_direction == directions.get(direction_requise, Vector2.ZERO)

func _demarrer_dialogue():
	dialogue_actif = true
	page_actuelle = 0
	DialogueManager.afficher_texte(pages_de_texte[page_actuelle], self)

func _page_suivante():
	page_actuelle += 1
	if page_actuelle < pages_de_texte.size():
		DialogueManager.afficher_texte(pages_de_texte[page_actuelle], self)
	else:
		dialogue_actif = false
		page_actuelle = 0
		DialogueManager.fermer()

# --- SIGNAUX DE PROXIMITÉ ---

func _on_body_entered(body):
	if body.name == "Player":
		joueur_proche = true
		joueur_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		joueur_proche = false
		joueur_ref = null
		if dialogue_actif:
			dialogue_actif = false
			DialogueManager.fermer()

func _on_area_entered(area):
	if area.owner and area.owner.name == "Player":
		joueur_proche = true
		joueur_ref = area.owner

func _on_area_exited(area):
	if area.owner and area.owner.name == "Player":
		joueur_proche = false
		joueur_ref = null
		if dialogue_actif:
			dialogue_actif = false
			DialogueManager.fermer()
