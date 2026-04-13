class_name SequenceDoor
extends StaticBody2D

@export_group("Configuration Serrure")
# C'est ici que la magie de l'interface opère ! 
# Tu pourras définir la taille de la combinaison et l'ordre des IDs.
@export var required_sequence: Array[int]

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	# Dès le lancement, la porte "écoute" les changements de mémoire
	MemoryManager.memory_changed.connect(verifier_combinaison)

func verifier_combinaison():
	# On récupère la liste des objets actuellement dans l'UI (statut ON)
	var current_memory = MemoryManager.get_on_items()
	
	# 1. Vérification rapide : A-t-on le bon nombre d'objets en mémoire ?
	if current_memory.size() != required_sequence.size():
		return # Non, la porte reste fermée
		
	# 2. Vérification détaillée : Sont-ils dans le bon ordre ?
	var is_correct = true
	
	# On parcourt chaque position (0, 1, 2...)
	for i in range(required_sequence.size()):
		# Si l'ID de l'objet en mémoire ne correspond pas à l'ID requis à cette place...
		if current_memory[i].item_id != required_sequence[i]:
			is_correct = false
			break # ... on arrête de chercher, c'est faux !
			
	# 3. Le Résultat
	if is_correct:
		ouvrir_porte()

func ouvrir_porte():
	print("Séquence correcte ! Ouverture de la porte.")
	
	# Désactive la collision pour laisser passer le joueur
	# (On utilise set_deferred par sécurité avec le moteur physique)
	collision.set_deferred("disabled", true)
	
	# Cache le sprite (tu pourras remplacer ça par une animation plus tard)
	sprite.hide()
	
	# Optionnel : tu pourrais émettre un son ici, ou vider la mémoire !
	
