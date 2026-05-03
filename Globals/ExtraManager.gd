extends Node

signal extra_debloque(extra_id: String, extra_title: String)

# Dictionnaire pour stocker l'état des extras: { "extra_id": true/false }
var extras_debloques: Dictionary = {}

var notification_scene = preload("res://Scenes/UI/ExtraNotification.tscn")
var canvas_layer: CanvasLayer

func _ready():
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # S'assurer qu'il soit au-dessus du reste
	add_child(canvas_layer)

func debloquer(extra_id: String, title: String = ""):
	if extra_id.is_empty():
		return
		
	if not extras_debloques.has(extra_id) or not extras_debloques[extra_id]:
		extras_debloques[extra_id] = true
		
		extra_debloque.emit(extra_id, title)
		_afficher_notification(title if title != "" else extra_id)

func est_debloque(extra_id: String) -> bool:
	return extras_debloques.get(extra_id, false)

func _afficher_notification(title: String):
	if notification_scene:
		var notif = notification_scene.instantiate()
		canvas_layer.add_child(notif)
		notif.afficher("Extra \"" + title + "\" débloqué")

# Méthode pour charger l'état depuis la sauvegarde
func charger_etat(donnees: Dictionary):
	if donnees.has("extras_debloques"):
		extras_debloques = donnees["extras_debloques"]
	else:
		extras_debloques.clear()

# Méthode pour obtenir les données à sauvegarder
func obtenir_donnees_sauvegarde() -> Dictionary:
	return {
		"extras_debloques": extras_debloques
	}
