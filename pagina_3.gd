extends Control

@export var mulher: TextureRect 
@export var dinheiro: Area2D
@export var estado: Area2D
@export var caminhao_lixo: AnimatedSprite2D
@export var policia: AnimatedSprite2D 

var is_dragging = false
var animacao_executada = false
var drag_offset = Vector2.ZERO 
const RAIO_CLIQUE = 100.0 

var pos_inicial_caminhao: float
var pos_inicial_policia: float
var loop_ativo = true

func _ready():
	if dinheiro and not dinheiro.area_entered.is_connected(_on_dinheiro_entregue):
		dinheiro.area_entered.connect(_on_dinheiro_entregue)
	
	if caminhao_lixo: pos_inicial_caminhao = caminhao_lixo.position.x
	if policia: pos_inicial_policia = policia.position.x

func _exit_tree():
	loop_ativo = false

func _input(event):
	if animacao_executada or not dinheiro: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var distancia = dinheiro.global_position.distance_to(event.position)
				if distancia < RAIO_CLIQUE:
					is_dragging = true
					drag_offset = dinheiro.global_position - event.position
					dinheiro.z_index = 10
			else:
				if is_dragging:
					is_dragging = false
					dinheiro.z_index = 0
					_verificar_entrega_manual()

	elif event is InputEventMouseMotion:
		if is_dragging:
			dinheiro.global_position = event.position + drag_offset

func _on_dinheiro_entregue(area: Area2D):
	if (area == estado or area.name == "Estado") and not animacao_executada:
		_iniciar_animacao_final()

func _verificar_entrega_manual():
	if animacao_executada: return
	var areas = dinheiro.get_overlapping_areas()
	for area in areas:
		if area == estado or area.name == "Estado":
			_iniciar_animacao_final()
			return

func _iniciar_animacao_final():
	if animacao_executada: return
	
	animacao_executada = true
	is_dragging = false
	
	var tween_fade = create_tween().set_parallel()
	if mulher: tween_fade.tween_property(mulher, "modulate:a", 0.0, 0.5)
	tween_fade.tween_property(dinheiro, "modulate:a", 0.0, 0.5)
	
	await tween_fade.finished
	
	if caminhao_lixo:
		caminhao_lixo.show()
		caminhao_lixo.play()
	if policia:
		policia.show()
		policia.play()
	
	_animar_ciclo_veiculos()

func _animar_ciclo_veiculos():
	if not loop_ativo: return

	if caminhao_lixo: caminhao_lixo.flip_h = false
	if policia: policia.flip_h = false

	var tween_ida = create_tween().set_parallel()
	var destino_x = -300.0

	if policia:
		tween_ida.tween_property(policia, "position:x", destino_x, 5.4).set_trans(Tween.TRANS_LINEAR)
	
	if caminhao_lixo:
		tween_ida.tween_property(caminhao_lixo, "position:x", destino_x, 7.7).set_delay(1.2).set_trans(Tween.TRANS_LINEAR)

	await tween_ida.finished
	
	await get_tree().create_timer(0.5).timeout
	if not loop_ativo: return

	if caminhao_lixo: caminhao_lixo.flip_h = true
	if policia: policia.flip_h = true

	var tween_volta = create_tween().set_parallel()

	if policia:
		tween_volta.tween_property(policia, "position:x", pos_inicial_policia, 5.4).set_trans(Tween.TRANS_LINEAR)
	
	if caminhao_lixo:
		tween_volta.tween_property(caminhao_lixo, "position:x", pos_inicial_caminhao, 7.7).set_delay(1.2).set_trans(Tween.TRANS_LINEAR)

	await tween_volta.finished
	
	await get_tree().create_timer(1.0).timeout
	
	_animar_ciclo_veiculos()
