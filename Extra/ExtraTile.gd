extends Button

signal tile_selectionnee(data)

@onready var thumbnail = $VBoxContainer/Thumbnail
@onready var title_label = $VBoxContainer/Title
@onready var lock_overlay = $LockOverlay

var mon_data : ExtraData

func _ready():
	pressed.connect(_on_pressed)

func configurer(data: ExtraData):
	mon_data = data
	title_label.text = data.title
	if data.thumbnail:
		thumbnail.texture = data.thumbnail
	
	var extra_est_debloque = data.is_unlocked
	if ExtraManager and data.extra_id != "":
		extra_est_debloque = extra_est_debloque or ExtraManager.est_debloque(data.extra_id)
	
	if not extra_est_debloque:
		lock_overlay.show()
		# On ne désactive plus le bouton pour pouvoir jouer le son d'erreur au clic
		# disabled = true
	else:
		lock_overlay.hide()
		# disabled = false

var error_sound = preload("res://sound/Ambiance/error.mp3")
var ok_sound = preload("res://sound/Ambiance/OK.mp3")

func _on_pressed():
	var extra_est_debloque = mon_data and mon_data.is_unlocked
	if ExtraManager and mon_data and mon_data.extra_id != "":
		extra_est_debloque = extra_est_debloque or ExtraManager.est_debloque(mon_data.extra_id)
		
	if extra_est_debloque:
		# Jouer le son de succès
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = ok_sound
		add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
		
		tile_selectionnee.emit(mon_data)
	else:
		# Jouer le son d'erreur
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = error_sound
		add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
