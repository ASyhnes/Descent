class_name SequenceDoor
extends StaticBody2D

@export_group("Configuration Serrure")
@export var required_sequence: Array[int]

@export_group("Messages")
@export_multiline var message_wrong = "C'est verrouillé... L'ordre semble incorrect."
@export_multiline var message_indices = "Il y a %d objet(s) de la bonne couleur, dont %d bien placé(s)."
@export_multiline var message_success = "Le mécanisme s'enclenche !"
@onready var animhaut = $AnimatedSprite2D
@onready var animbas = $AnimatedSprite2D2
@onready var collision = $CollisionShape2D

var is_open = false

func _ready():
	if animhaut: animhaut.play("default")
	if animbas: animbas.play("default2")

func on_interact():
	if is_open: return
	
	# On récupère les résultats de l'analyse
	var analyse = analyser_memoire()
	
	if analyse.correct_position == required_sequence.size() and required_sequence.size() > 0:
		sequence_ouverture()
	else:
		sequence_echec(analyse.correct_color, analyse.correct_position)

func analyser_memoire() -> Dictionary:
	var current_memory = MemoryManager.get_on_items()
	var x_couleur = 0
	var y_position = 0
	
	# On crée une copie de la séquence requise pour marquer les couleurs trouvées
	var ids_attendus = required_sequence.duplicate()
	
	# 1. Calcul des bonnes positions (Y)
	for i in range(min(current_memory.size(), required_sequence.size())):
		if current_memory[i].item_id == required_sequence[i]:
			y_position += 1
	
	# 2. Calcul des bonnes couleurs totales (X)
	for item in current_memory:
		if ids_attendus.has(item.item_id):
			x_couleur += 1
			# On enlève l'ID pour ne pas compter deux fois si le joueur a des doublons
			ids_attendus.erase(item.item_id)
			
	return {"correct_color": x_couleur, "correct_position": y_position}

func sequence_echec(x: int, y: int):
	if DialogueManager:
		# Premier message
		DialogueManager.afficher_texte(message_wrong)
		
		# PAUSE : On attend au moins 1.5 seconde avant de passer à la suite
		await get_tree().create_timer(1.5).timeout
		
		# Deuxième message (On utilise la variable de l'Inspecteur !)
		var texte_final = message_indices % [x, y]
		DialogueManager.afficher_texte(texte_final)

func sequence_ouverture():
	is_open = true
	if DialogueManager:
		DialogueManager.afficher_texte(message_success)
		await get_tree().create_timer(1.0).timeout
	
	animhaut.play("open")
	animbas.play("open2")
	await animhaut.animation_finished
	await animbas.animation_finished
	collision.set_deferred("disabled", true)
