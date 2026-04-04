extends Area2D

# 1. ON CHANGE LA VARIABLE : Au lieu d'un texte, on crée une liste de textes (Array)
@export var pages_de_texte : Array[String] = [
	"C'est une vieille affiche de recrutement...",
	"Le visage est complètement effacé par le temps.",
	"Il y a un numéro de téléphone gribouillé en bas."
]
@export_enum("Haut", "Bas", "Gauche", "Droite", "Peu importe") var direction_requise : String = "Haut"
	 
var joueur_proche : bool = false
var joueur_ref = null

# 2. NOUVELLES VARIABLES DE MÉMOIRE
var dialogue_actif : bool = false # memoris on est en train de lire
var page_actuelle : int = 0       # RMemrorise à quelle page on en est

@onready var boite_ui = %Panel
@onready var label_texte = %TexteDialogue

func _ready():
	boite_ui.hide()
	if boite_ui:
		## placement de la bule
		var taille_ecran = get_viewport_rect().size
		boite_ui.size = Vector2(taille_ecran.x - 40, 150)
		boite_ui.position = Vector2(20, taille_ecran.y - 170)
		boite_ui.scale = Vector2(1, 1)
		##
		if label_texte:
			label_texte.size = boite_ui.size
			label_texte.position = Vector2(0, 0)
			##
		boite_ui.hide()
		
	collision_mask = 0xFFFFFFFF
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_body_entered(body):
	print("--- DEBUG : Quelque chose est entré dans l'affiche : ", body.name)
	if body.name == "Player":
		print("--- DEBUG : Le joueur a été reconnu !")
		joueur_proche = true
		joueur_ref = body

func _on_body_exited(body):
	print("--- DEBUG : Quelque chose est sorti de l'affiche : ", body.name)
	if body.name == "Player":
		print("--- DEBUG : Le joueur s'est éloigné.")
		joueur_proche = false
		joueur_ref = null 
		dialogue_actif = false
		page_actuelle = 0
		if boite_ui:
			boite_ui.hide()

func _input(event):
	# On vérifie juste si la touche est pressée, peu importe où est le joueur
	if event.is_action_pressed("ui_accept"):
		print("--- DEBUG : Touche 'ui_accept' (Entrée/Espace) pressée !")
		print("--- DEBUG : joueur_proche = ", joueur_proche)
		
		if joueur_proche and joueur_ref:
			print("--- DEBUG : Direction actuelle du joueur = ", joueur_ref.cardinal_direction)
			print("--- DEBUG : Direction requise = ", direction_requise)
			
			var bonne_direction = false
			if direction_requise == "Haut" and joueur_ref.cardinal_direction == Vector2(0, -1):
				bonne_direction = true
			elif direction_requise == "Bas" and joueur_ref.cardinal_direction == Vector2(0, 1):
				bonne_direction = true
			elif direction_requise == "Gauche" and joueur_ref.cardinal_direction == Vector2(-1, 0):
				bonne_direction = true
			elif direction_requise == "Droite" and joueur_ref.cardinal_direction == Vector2(1, 0):
				bonne_direction = true
			elif direction_requise == "Peu importe":
				bonne_direction = true
				
			print("--- DEBUG : Est-ce la bonne direction ? = ", bonne_direction)
			
			if bonne_direction:
				if not dialogue_actif:
					print("--- DEBUG : OUVERTURE de la boîte de dialogue (Page 0)")
					dialogue_actif = true
					page_actuelle = 0
					label_texte.text = pages_de_texte[page_actuelle]
					boite_ui.show()
				else:
					page_actuelle += 1 
					print("--- DEBUG : PASSAGE à la page ", page_actuelle)
					if page_actuelle < pages_de_texte.size():
						label_texte.text = pages_de_texte[page_actuelle]
					else:
						print("--- DEBUG : FIN du dialogue, fermeture.")
						dialogue_actif = false
						page_actuelle = 0
						boite_ui.hide()
func _on_area_entered(area):
	print("--- DEBUG : Une AREA est entrée : ", area.name)
	# Si la zone appartient au joueur, on valide !
	if area.owner and area.owner.name == "Player":
		print("--- DEBUG : L'Area appartient bien au Joueur !")
		joueur_proche = true
		joueur_ref = area.owner

func _on_area_exited(area):
	if area.owner and area.owner.name == "Player":
		joueur_proche = false
		joueur_ref = null 
		dialogue_actif = false
		page_actuelle = 0
		if boite_ui:
			boite_ui.hide()
