extends Node2D

# --- RÉFÉRENCES AUX CALQUES ---
@onready var map_nb = $nb_test
@onready var map_color = $color_test
@onready var nb_assets = $nb_assets
@onready var color_assets = $color_assets

# --- RÉFÉRENCE AU JOUEUR ---
@onready var player = $Player

# --- RÉGLAGES DES RAYONS ---
var radius_color : int = 12
var radius_fog_inner : int = 14
var radius_fog_mid : int = 22
var radius_fog_outer : int = 30


func _ready():
	print("Nettoyage forcé des couleurs...")
	# 1. Le clear classique
	map_color.clear()
	color_assets.clear()
	
	# 2. On efface TOUTES les cellules utilisées, une par une
	var cellules_sol = map_color.get_used_cells()
	for cellule in cellules_sol:
		map_color.set_cell(cellule, -1)
		
	var cellules_assets = color_assets.get_used_cells()
	for cellule in cellules_assets:
		color_assets.set_cell(cellule, -1)
		
	print("Système complet prêt.")

func _process(_delta):
	# On cherche la lumière dans le joueur
	var light = player.get_node_or_null("LightBase")
	if not light: return
	
	var light_pos = to_local(light.global_position)
	var zone = radius_fog_outer + 5

	for x in range(-zone, zone + 1):
		for y in range(-zone, zone + 1):
			var offset = Vector2(x, y)
			var distance = offset.length()
			
			# Calcul des positions pour chaque grille
			var pos_color = map_color.local_to_map(light_pos) + Vector2i(x, y)

			# pos_nb utilise exactement la même position relative que pos_color !
			var pos_nb = map_nb.local_to_map(light_pos) + Vector2i(x, y)

			# --- B. DESSIN DE LA COULEUR VIVE (Temporaire) ---
			if distance < radius_color:
				# 1. On peint le SOL couleur en copiant le SOL NB
				paint_tile_from_source(map_color, map_nb, pos_color, pos_nb)
				
				# 2. AJOUT : On peint les ASSETS couleur en copiant les ASSETS NB
				paint_tile_from_source(color_assets, nb_assets, pos_color, pos_nb)
			else:
				# On efface la couleur quand on s'éloigne
				map_color.set_cell(pos_color, -1)
				
				# 3. AJOUT : On efface aussi les assets couleur
				color_assets.set_cell(pos_color, -1)
				
				

# Fonction générique pour peindre une tuile en copiant le décor NB
func paint_tile_from_source(dest_layer: TileMapLayer, source_layer: TileMapLayer, pos_dest: Vector2i, pos_source: Vector2i):
	if dest_layer.get_cell_source_id(pos_dest) == -1:
		
		# Au lieu de lire toujours 'map_nb', on lit le calque qu'on a choisi
		var atlas_coords = source_layer.get_cell_atlas_coords(pos_source)
		
		if atlas_coords != Vector2i(-1, -1):
			var ts = dest_layer.tile_set
			if ts:
				var source_id = ts.get_source_id(0)
				if source_id != -1:
					dest_layer.set_cell(pos_dest, source_id, atlas_coords)
