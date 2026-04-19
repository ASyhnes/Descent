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

# Machine à états pour la séquence de dialogue (remplace les await timer)
enum EtatDialogue { AUCUN, ECHEC_MSG1, ECHEC_MSG2, SUCCES }
var _etat : EtatDialogue = EtatDialogue.AUCUN
var _x_couleur : int = 0
var _y_position : int = 0

func _ready():
	if animhaut: animhaut.play("default")
	if animbas: animbas.play("default2")

func on_interact():
	if is_open: return

	var analyse = analyser_memoire()

	if analyse.correct_position == required_sequence.size() and required_sequence.size() > 0:
		sequence_ouverture()
	else:
		sequence_echec(analyse.correct_color, analyse.correct_position)

func analyser_memoire() -> Dictionary:
	var current_memory = MemoryManager.get_on_items()
	var x_couleur = 0
	var y_position = 0
	var ids_attendus = required_sequence.duplicate()

	for i in range(min(current_memory.size(), required_sequence.size())):
		if current_memory[i].item_id == required_sequence[i]:
			y_position += 1

	for item in current_memory:
		if ids_attendus.has(item.item_id):
			x_couleur += 1
			ids_attendus.erase(item.item_id)

	return {"correct_color": x_couleur, "correct_position": y_position}

func sequence_echec(x: int, y: int):
	_x_couleur = x
	_y_position = y
	_etat = EtatDialogue.ECHEC_MSG1
	if DialogueManager:
		DialogueManager.afficher_texte(message_wrong, self)

func sequence_ouverture():
	is_open = true
	_etat = EtatDialogue.SUCCES
	if DialogueManager:
		DialogueManager.afficher_texte(message_success, self)

# Appelé par CheckInteraction() quand le texte est complet et que le joueur appuie sur action
func on_dialogue_advance():
	match _etat:
		EtatDialogue.ECHEC_MSG1:
			# Passe au deuxième message (indices)
			_etat = EtatDialogue.ECHEC_MSG2
			var texte = message_indices % [_x_couleur, _y_position]
			DialogueManager.afficher_texte(texte, self)
		EtatDialogue.ECHEC_MSG2:
			# Ferme le dialogue
			_etat = EtatDialogue.AUCUN
			DialogueManager.fermer()
		EtatDialogue.SUCCES:
			# Ferme le dialogue et lance l'animation d'ouverture
			_etat = EtatDialogue.AUCUN
			DialogueManager.fermer()
			_jouer_animation_ouverture()
		_:
			DialogueManager.fermer()

func _jouer_animation_ouverture():
	animhaut.play("open")
	animbas.play("open2")
	await animhaut.animation_finished
	await animbas.animation_finished
	collision.set_deferred("disabled", true)
