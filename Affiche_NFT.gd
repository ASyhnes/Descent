extends Area2D

# --- LA ZONE FACILE ---
# "@export_multiline" crée un champ de texte modifiable dans l'inspecteur.
@export_multiline var mon_texte_personnalise : String = "C'est une vieille affiche de recrutement... Le visage est effacé."

var joueur_proche : bool = false

# Références vers les nœuds de l'UI (Vérifie bien que tes noms de nœuds correspondent !)
@onready var boite_ui = get_node("/root/Playground/UI/Panel")
@onready var label_texte = get_node("/root/Playground/UI/Panel/TexteDialogue")

func _ready():
	# On s'assure que la boîte UI est cachée au début du jeu.
	if boite_ui:
		boite_ui.hide()
	
	# On connecte les signaux pour savoir quand le joueur entre/sort de la zone.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Assure-toi que "Player" est bien le nom exact de ton nœud joueur.
	if body.name == "Player": 
		joueur_proche = true

func _on_body_exited(body):
	if body.name == "Player":
		joueur_proche = false
		if boite_ui:
			boite_ui.hide() # On cache le texte si le joueur s'en va.

func _input(event):
	# "ui_accept" correspond par défaut aux touches Entrée et Espace.
	if event.is_action_pressed("ui_accept") and joueur_proche:
		if boite_ui and label_texte:
			# Si la boîte est déjà visible, on la cache.
			if boite_ui.visible:
				boite_ui.hide()
			# Sinon, on remplit le Label avec le texte de CETTE affiche et on l'affiche.
			else:
				label_texte.text = mon_texte_personnalise
				boite_ui.show()
