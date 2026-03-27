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
	#if boite_ui:
		## placement de la bule
		#var taille_ecran = get_viewport_rect().size
		#boite_ui.size = Vector2(taille_ecran.x - 40, 150)
		#boite_ui.position = Vector2(20, taille_ecran.y - 170)
		#boite_ui.scale = Vector2(1, 1)
		#
		#if label_texte:
			#label_texte.size = boite_ui.size
			#label_texte.position = Vector2(0, 0)
			#
		#boite_ui.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		joueur_proche = true
		joueur_ref = body 

func _on_body_exited(body):
	if body.name == "Player":
		joueur_proche = false
		joueur_ref = null 
		# Sécurité : Si le joueur s'éloigne réinitialise le dialogue
		dialogue_actif = false
		page_actuelle = 0
		if boite_ui:
			boite_ui.hide()

func _input(event):
	if event.is_action_pressed("ui_accept") and joueur_proche and joueur_ref:
		
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
			
		if bonne_direction:
			# MOTEUR DIALOGUE
			
			if not dialogue_actif:
				# CAS 1 : La bulle est fermée, on COMMENCE à lire
				dialogue_actif = true
				page_actuelle = 0
				label_texte.text = pages_de_texte[page_actuelle]
				boite_ui.show()
				
			else:
				# CAS 2 : La bulle est déjà ouverte, on PASSE À LA SUITE
				page_actuelle += 1 # On ajoute +1 page actuelle
				
				# Est-ce qu'il reste des pages à lire ?
				if page_actuelle < pages_de_texte.size():
					# sioui:  On affiche le texte de la nouvelle page
					label_texte.text = pages_de_texte[page_actuelle]
				else:
					# Sinon! On ferme et on remet à zéro
					dialogue_actif = false
					page_actuelle = 0
					boite_ui.hide()
