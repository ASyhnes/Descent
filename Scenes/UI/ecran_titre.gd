extends Node

# --- CONFIGURATION ---
var chemin_jeu : String = "res://Scenes/Levels/LevelZero.tscn"

# --- ÉLÉMENTS DE FOND ---
@onready var fond_blanc_fixe = $FondBlancFixe
@onready var image_couverture = $ImageCouverture
@onready var voile_blanc = $VoileBlanc

# --- ÉLÉMENTS DU MENU ---
@onready var menu_principal_font = $FondBlancFixe2 # fond blanc du menu
@onready var menu_principal = $MenuPrincipal       # Le GridContainer

# --- BOUTONS ---
@onready var btn_nouvelle_partie = $MenuPrincipal/BtnNouvellePartie
@onready var btn_continuer = $MenuPrincipal/BtnContinuer
@onready var btn_options = $MenuPrincipal/BtnOptions
@onready var btn_extras = $MenuPrincipal/BtnExtras

# --- AUDIO ---
@onready var son_erreur = $SonErreur

# Variable d'état
var menu_est_ouvert : bool = false

func _ready():
	var taille_ecran = get_viewport().get_visible_rect().size
	
	if fond_blanc_fixe:
		fond_blanc_fixe.size = taille_ecran
		fond_blanc_fixe.position = Vector2(0, 0)
	if image_couverture:
		image_couverture.size = taille_ecran
		image_couverture.position = Vector2(0, 0)
	if voile_blanc:
		voile_blanc.size = taille_ecran
		voile_blanc.position = Vector2(0, 0)

	# 2. Cacher le menu au lancement
	if menu_principal:
		menu_principal.hide()
	if menu_principal_font:
		menu_principal_font.hide()
	
	# Menu de chargement
	var load_menu_scene = load("res://Scenes/UI/LoadMenu.tscn")
	var load_menu_instance = load_menu_scene.instantiate()
	add_child(load_menu_instance)
	
	# 3. Connexion des signaux des boutons
	btn_nouvelle_partie.pressed.connect(_sur_nouvelle_partie_pressee)
	btn_continuer.pressed.connect(load_menu_instance.ouvrir)
	btn_options.pressed.connect(_sur_bouton_invalide_presse)
	btn_extras.pressed.connect(_sur_extras_presse)
	
	load_menu_instance.menu_closed.connect(func(): if btn_continuer: btn_continuer.grab_focus())

func _input(event):
	# Si le joueur appuie sur une touche et que le menu n'est pas encore là
	if not menu_est_ouvert and (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed)):
		
		# On ouvre le menu
		menu_est_ouvert = true
		
		if menu_principal_font:
			menu_principal_font.show()
		if menu_principal:
			menu_principal.show()
		
		# Donner le focus pour la navigation aux flèches
		if btn_nouvelle_partie:
			btn_nouvelle_partie.grab_focus()
		
		# EMPÊCHE LE REBOND : On dit à Godot que cet appui sur Entrée s'arrête ici
		get_viewport().set_input_as_handled()

# --- LOGIQUE DES BOUTONS ---

func _sur_nouvelle_partie_pressee():
	# On lance le niveau de jeu
	get_tree().change_scene_to_file(chemin_jeu)

func _sur_bouton_invalide_presse():
	# Bruitage style FF7 pour les options non disponibles
	if son_erreur:
		son_erreur.play()

func _sur_extras_presse():
	get_tree().change_scene_to_file("res://Extra/ExtraMenu.tscn")
