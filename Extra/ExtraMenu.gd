extends Control

@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
@onready var details_page = $ExtraDetailsPage

var extra_tile_scene = preload("res://Extra/ExtraTile.tscn")
@export var extra_resources : Array[ExtraData] = [] # Rempli via l'inspecteur

@onready var btn_retour = $VBoxContainer/Header/BtnRetour

func _ready():
	charger_extras()
	if btn_retour:
		btn_retour.pressed.connect(_on_btn_retour_presse)
		
	# Initialiser le focus claviable sur le premier élément
	if grid_container.get_child_count() > 0:
		grid_container.get_child(0).grab_focus()
	elif btn_retour:
		btn_retour.grab_focus()
		
	details_page.details_closed.connect(_on_details_closed)

func _on_details_closed():
	if grid_container.get_child_count() > 0:
		grid_container.get_child(0).grab_focus()
	elif btn_retour:
		btn_retour.grab_focus()

func _on_btn_retour_presse():
	get_tree().change_scene_to_file("res://Scenes/UI/ecran_titre.tscn")

func charger_extras():
	# Nettoyer grille
	for child in grid_container.get_children():
		child.queue_free()
		
	# Instancier
	for data in extra_resources:
		if data:
			var tile = extra_tile_scene.instantiate()
			grid_container.add_child(tile)
			tile.configurer(data)
			tile.tile_selectionnee.connect(_on_tile_selectionnee)

func _on_tile_selectionnee(data: ExtraData):
	details_page.afficher(data)
