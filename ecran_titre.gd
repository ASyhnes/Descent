extends Node

var chemin_jeu : String = "res://player.tscn"

# --- ÉLÉMENTS DE FOND ---
@onready var fond_blanc_fixe = $FondBlancFixe
@onready var image_couverture = $ImageCouverture
@onready var voile_blanc = $VoileBlanc

# --- ÉLÉMENTS DU MENU ---
@onready var menu_principal_font = $FondBlancFixe2 # Le fond blanc derrière les boutons
@onready var menu_principal = $MenuPrincipal       # La grille des boutons

# --- BOUTONS ---
@onready var btn_nouvelle_partie = $MenuPrincipal/BtnNouvellePartie
@onready var btn_continuer = $MenuPrincipal/BtnContinuer
@onready var btn_options = $MenuPrincipal/BtnOptions
@onready var btn_extras = $MenuPrincipal/BtnExtras

# --- AUDIO ---
@onready var son_erreur = $SonErreur

# Mém savoir si on est sur l'image ou dans le menu
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

	# 2. cacher menu au lancement
	if menu_principal:
		menu_principal.hide()
	if menu_principal_font:
		menu_principal_font.hide()
	
	# 3. connection bouton
	if btn_nouvelle_partie:
		btn_nouvelle_partie.pressed.connect(_sur_nouvelle_partie_pressee)
	if btn_continuer:
		btn_continuer.pressed.connect(_sur_bouton_invalide_presse)
	if btn_options:
		btn_options.pressed.connect(_sur_bouton_invalide_presse)
	if btn_extras:
		btn_extras.pressed.connect(_sur_bouton_invalide_presse)

func _input(event):
	# Si le joueur appuie sur une touche d'action ET que le menu est fermé
	if not menu_est_ouvert and (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed)):
		
		#  le menu s'ouvre
		menu_est_ouvert = true
		
		# On affiche le conteneur 
		if menu_principal_font:
			menu_principal_font.show()
		if menu_principal:
			menu_principal.show()
		
		
		if btn_nouvelle_partie:
			btn_nouvelle_partie.grab_focus()
		
		get_viewport().set_input_as_handled()



func _sur_nouvelle_partie_pressee():
	get_tree().change_scene_to_file(chemin_jeu)

func _sur_bouton_invalide_presse():
	son_erreur.play()
