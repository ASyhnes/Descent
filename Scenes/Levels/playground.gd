extends Node2D

# --- RÉFÉRENCE AU JOUEUR ---
# On garde la référence au joueur au cas où tu en aurais besoin plus tard pour le niveau
@onready var player = $Player

func _ready():
	print("Niveau chargé, nouveau système de couleur actif.")
	if SaveManager:
		SaveManager.apply_load(self)

func _process(_delta):
	# Plus besoin de scanner les tuiles ici !
	pass
