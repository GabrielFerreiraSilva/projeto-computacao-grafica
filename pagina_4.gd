extends Control

@export_category("Configurações de Teste")
@export var usar_toque_simples_para_teste: bool = false

@export_category("Referências")
@export var portao_esquerdo: TextureRect
@export var portao_direito: TextureRect
@export var chao: TextureRect
@export var mar: TextureRect
@export var navio: TextureRect
@export var gesture_area: Control

@export_category("Configurações de Animação")
@export var duracao_abertura: float = 1.5
@export var sensibilidade_pinca: float = 100.0
@export var tolerancia_vertical_pinca: float = 100.0

const POSICAO_FINAL_MAR_Y: float = 623.0
const POSICAO_FIXA_NAVIO_Y: float = 371.0

var animacao_executada: bool = false
var touch_points: Dictionary = {}
var is_pinching_valid: bool = false
var distancia_inicial_pinca: float = 0.0

func _ready():
	mar.position = Vector2(mar.position.x, 920)
	
	navio.hide()
	
	if usar_toque_simples_para_teste:
		portao_esquerdo.gui_input.connect(_on_portao_esquerdo_clicado)
	else:
		set_process_input(true)

func _input(event: InputEvent):
	if animacao_executada: return

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			if touch_points.size() == 2:
				var points = touch_points.values()
				var p1 = points[0]
				var p2 = points[1]
				
				var is_inside = gesture_area.get_rect().has_point(p1) and gesture_area.get_rect().has_point(p2)
				var is_horizontal = abs(p1.y - p2.y) < tolerancia_vertical_pinca
				
				if is_inside and is_horizontal:
					is_pinching_valid = true
					distancia_inicial_pinca = p1.distance_to(p2)
				else:
					is_pinching_valid = false
			else:
				is_pinching_valid = false
		else:
			if touch_points.has(event.index):
				touch_points.erase(event.index)
			if touch_points.size() < 2:
				is_pinching_valid = false

	elif event is InputEventScreenDrag:
		if not is_pinching_valid: return

		if touch_points.has(event.index):
			touch_points[event.index] = event.position
			
		if touch_points.size() == 2:
			var points = touch_points.values()
			var p1 = points[0]
			var p2 = points[1]
			
			if not gesture_area.get_rect().has_point(p1) or not gesture_area.get_rect().has_point(p2):
				is_pinching_valid = false
				return

			var distancia_atual = p1.distance_to(p2)
			
			if distancia_atual > distancia_inicial_pinca + sensibilidade_pinca:
				_iniciar_animacao_principal()

func _on_portao_esquerdo_clicado(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_iniciar_animacao_principal()

func _iniciar_animacao_principal():
	if animacao_executada: return
	animacao_executada = true
	is_pinching_valid = false
	
	var pos_final_esq_x = portao_esquerdo.position.x - portao_esquerdo.size.x
	var pos_final_dir_x = portao_direito.position.x + portao_direito.size.x

	var tween = create_tween()
	tween.set_parallel()

	tween.tween_property(portao_esquerdo, "position:x", pos_final_esq_x, duracao_abertura).set_trans(Tween.TRANS_SINE)
	tween.tween_property(portao_direito, "position:x", pos_final_dir_x, duracao_abertura).set_trans(Tween.TRANS_SINE)
	tween.tween_property(chao, "modulate:a", 0.0, duracao_abertura * 0.8).set_ease(Tween.EASE_IN)
	
	tween.tween_property(mar, "position:y", POSICAO_FINAL_MAR_Y, duracao_abertura * 0.9).set_delay(0.2).set_trans(Tween.TRANS_CUBIC)

	await tween.finished
	
	portao_esquerdo.hide()
	portao_direito.hide()
	
	_iniciar_movimento_navio()

func _iniciar_movimento_navio():
	navio.show()
	
	navio.position.y = POSICAO_FIXA_NAVIO_Y

	var inicio_x = -navio.size.x
	var fim_x = get_viewport_rect().size.x + navio.size.x
	
	navio.position.x = inicio_x
	navio.scale.x = 1

	var tween_navio = create_tween().set_loops()
	tween_navio.tween_property(navio, "position:x", fim_x, 8.0).set_delay(1.0)
	tween_navio.tween_callback(func(): navio.scale.x = -1)
	tween_navio.tween_property(navio, "position:x", inicio_x, 8.0).set_delay(1.0)
	tween_navio.tween_callback(func(): navio.scale.x = 1)
