extends Control

var paginas = [
	preload("res://imagens/Capa.png"),
	preload("res://pagina_2.tscn"),
	preload("res://pagina_3.tscn"),
	preload("res://pagina_4.tscn"),
	preload("res://pagina_5.tscn"),
	preload("res://pagina_6.tscn"),
	preload("res://pagina_7.tscn"),
	preload("res://imagens/Contracapa.png")
]

var sons = {
	0: preload("res://sons/som_capa.mp3"),
	1: preload("res://sons/pg2.mp3"),
	2: preload("res://sons/pg3.mp3"),
	3: preload("res://sons/pg4.mp3"),
	4: preload("res://sons/pg5.mp3"),
	5: preload("res://sons/pg6.mp3"),
	6: preload("res://sons/pg7.mp3"),
	7: preload("res://sons/som_contracapa.mp3")
}

var musica_fundo = preload("res://sons/background.mp3")
var textura_som_ligado = preload("res://assets/estado=ativado.png")
var textura_som_desativado = preload("res://assets/estado=desativado.png")

var indice_atual = 0
var is_transitioning = false
var current_display
var video_esta_rodando = false

@onready var page_display_a: TextureRect = $PageContainer/PageDisplayA
@onready var page_display_b: TextureRect = $PageContainer/PageDisplayB
@onready var botao_previous: Button = $BotaoPrevious
@onready var botao_next: Button = $BotaoNext
@onready var botao_inicio: Button = $BotaoInicio
@onready var botao_som_a: TextureButton = $PageContainer/PageDisplayA/BotaoSomA
@onready var botao_som_b: TextureButton = $PageContainer/PageDisplayB/BotaoSomB
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func _ready():
	current_display = page_display_a
	carregar_pagina(page_display_a, indice_atual)
	page_display_b.hide()
	
	_atualizar_ui()
	_configurar_audio_inicial()
	_conectar_sinais()

func transition_to_page(novo_indice: int):
	if is_transitioning or novo_indice < 0 or novo_indice >= paginas.size():
		return
		
	is_transitioning = true
	video_esta_rodando = false
	
	var direction = 1 if novo_indice > indice_atual else -1
	var outgoing_display = current_display
	var incoming_display = page_display_b if current_display == page_display_a else page_display_a
	
	carregar_pagina(incoming_display, novo_indice)
	incoming_display.position.x = get_viewport_rect().size.x * direction
	incoming_display.show()
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(incoming_display, "position", Vector2.ZERO, 0.4)
	tween.tween_property(outgoing_display, "position", Vector2(-get_viewport_rect().size.x * direction, 0), 0.4)

	await tween.finished

	outgoing_display.hide()
	limpar_pagina(outgoing_display)
	
	indice_atual = novo_indice
	current_display = incoming_display
	is_transitioning = false
	
	_atualizar_ui()
	play_page_sound()

func carregar_pagina(display_node: TextureRect, indice: int):
	limpar_pagina(display_node)
	var pagina_atual = paginas[indice]
	
	if pagina_atual is Texture2D:
		display_node.texture = pagina_atual
	elif pagina_atual is PackedScene:
		display_node.texture = null
		var cena_pagina = pagina_atual.instantiate()
		
		if cena_pagina.has_signal("video_iniciou"):
			if not cena_pagina.video_iniciou.is_connected(_on_video_da_pagina_iniciou):
				cena_pagina.video_iniciou.connect(_on_video_da_pagina_iniciou)
		
		display_node.add_child(cena_pagina)
		
		if display_node == page_display_a:
			botao_som_a.move_to_front()
		elif display_node == page_display_b:
			botao_som_b.move_to_front()

func limpar_pagina(display_node: TextureRect):
	for child in display_node.get_children():
		if child != botao_som_a and child != botao_som_b:
			child.queue_free()

func play_page_sound():
	audio_player.stop()
	
	if video_esta_rodando:
		return
	
	if SoundManager.is_sound_enabled:
		bgm_player.stream_paused = false
	
	if SoundManager.is_sound_enabled and sons.has(indice_atual):
		
		if indice_atual == 0:
			await get_tree().create_timer(1.0).timeout
			if indice_atual != 0 or not SoundManager.is_sound_enabled: return
			
		elif indice_atual == 5:
			await get_tree().create_timer(0.5).timeout
			if indice_atual != 5 or not SoundManager.is_sound_enabled: return

		audio_player.stream = sons[indice_atual]
		audio_player.play()

func _configurar_audio_inicial():
	bgm_player.stream = musica_fundo
	bgm_player.volume_db = -23
	
	bgm_player.play()
	
	_on_sound_state_changed(SoundManager.is_sound_enabled)
	
	play_page_sound()

func _atualizar_ui():
	var is_capa = (indice_atual == 0)
	var is_contracapa = (indice_atual == paginas.size() - 1)

	botao_previous.visible = not is_capa
	botao_next.visible = not is_contracapa
	botao_inicio.visible = is_contracapa
	
	botao_som_a.visible = true
	botao_som_b.visible = true

func _conectar_sinais():
	botao_next.pressed.connect(_on_botao_next_pressed)
	botao_previous.pressed.connect(_on_botao_previous_pressed)
	botao_inicio.pressed.connect(_on_botao_inicio_pressed)
	botao_som_a.pressed.connect(_on_botao_som_pressed)
	botao_som_b.pressed.connect(_on_botao_som_pressed)
	SoundManager.sound_state_changed.connect(_on_sound_state_changed)

func _on_botao_next_pressed():
	transition_to_page(indice_atual + 1)

func _on_botao_previous_pressed():
	transition_to_page(indice_atual - 1)

func _on_botao_inicio_pressed():
	transition_to_page(0)

func _on_botao_som_pressed():
	SoundManager.toggle_sound()

func _on_sound_state_changed(som_esta_ligado: bool):
	var textura = textura_som_ligado if som_esta_ligado else textura_som_desativado
	
	botao_som_a.texture_normal = textura
	botao_som_b.texture_normal = textura
	
	if video_esta_rodando:
		return
		
	play_page_sound()
	bgm_player.stream_paused = not som_esta_ligado

func _on_video_da_pagina_iniciou():
	video_esta_rodando = true
	audio_player.stop()
	bgm_player.stream_paused = true
