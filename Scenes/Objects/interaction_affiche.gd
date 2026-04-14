extends Area2D

@export var pages_de_texte : Array[String] = ["Texte par défaut"]
@export_enum("Haut", "Bas", "Gauche", "Droite", "Peu importe") var direction_requise : String = "Haut"

var joueur_proche : bool = false
var joueur_ref = null
var dialogue_actif : bool = false
var page_actuelle : int = 0

func _ready():
	# On branche les signaux "à la main" par code
	# Cela remplace les clics dans l'interface
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _input(event):
	if event.is_action_pressed("ui_accept") and joueur_proche:
		if verifier_direction():
			gerer_dialogue()

func verifier_direction() -> bool:
	if direction_requise == "Peu importe": return true
	var directions = {"Haut": Vector2(0, -1), "Bas": Vector2(0, 1), "Gauche": Vector2(-1, 0), "Droite": Vector2(1, 0)}
	return joueur_ref.cardinal_direction == directions.get(direction_requise, Vector2.ZERO)

func gerer_dialogue():
	if not dialogue_actif:
		dialogue_actif = true
		page_actuelle = 0
		# On envoie la première page au gestionnaire global
		DialogueManager.afficher_texte(pages_de_texte[page_actuelle])
	else:
		page_actuelle += 1
		if page_actuelle < pages_de_texte.size():
			# On envoie la page suivante
			DialogueManager.afficher_texte(pages_de_texte[page_actuelle])
		else:
			# On ferme tout
			dialogue_actif = false
			page_actuelle = 0
			DialogueManager.fermer()

# --- Signaux ---

func _on_body_entered(body):
	if body.name == "Player":
		joueur_proche = true
		joueur_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		joueur_proche = false
		joueur_ref = null
		dialogue_actif = false
		DialogueManager.fermer() # Sécurité : si le joueur part, on cache la boîte

# Ajoute ces deux fonctions si tu utilises des Area2D pour la détection
func _on_area_entered(area):
	if area.owner and area.owner.name == "Player":
		joueur_proche = true
		joueur_ref = area.owner

func _on_area_exited(area):
	if area.owner and area.owner.name == "Player":
		joueur_proche = false
		joueur_ref = null
		dialogue_actif = false
		DialogueManager.fermer()
