extends Control

signal video_iniciou

@export var urna_container: Control
@export var botao_confirma: Button
@export var video_container: Control
@export var video_player: VideoStreamPlayer
@export var botao_play_pause: TextureButton
@export var instrucao_video: TextureRect

var textura_play = preload("res://imagens/pagina6/bt_play.png")
var textura_pause = preload("res://imagens/pagina6/bt_pause.png")

var is_transitioning = false

func _ready():
	urna_container.show()
	video_container.hide()
	
	botao_confirma.pressed.connect(_on_botao_confirma_pressed)
	botao_play_pause.pressed.connect(_on_botao_play_pause_pressed)
	video_player.finished.connect(_on_video_finished)

func _exit_tree():
	video_player.stop()

func _on_botao_confirma_pressed():
	if is_transitioning:
		return
	is_transitioning = true
	botao_confirma.disabled = true

	video_container.modulate.a = 0.0
	video_container.show()

	var tween = create_tween()
	tween.set_parallel()

	tween.tween_property(urna_container, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(video_container, "modulate:a", 1.0, 0.5).set_delay(0.2).set_trans(Tween.TRANS_SINE)

	await tween.finished
	
	urna_container.hide()
	
	botao_play_pause.texture_normal = textura_pause
	
	video_iniciou.emit()
	video_player.play()

func _on_botao_play_pause_pressed():
	video_player.paused = not video_player.paused
	
	if video_player.paused:
		botao_play_pause.texture_normal = textura_play
	else:
		botao_play_pause.texture_normal = textura_pause

func _on_video_finished():
	botao_play_pause.texture_normal = textura_play
