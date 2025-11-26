extends Control

@export_category("Referências de Cena")
@export var caneta: TextureRect
@export var decreto: TextureRect
@export var povo: AnimatedSprite2D
@export var texto_instrucao: Control 

@export_category("Recursos")
@export var textura_assinado: Texture2D 

@export_category("Configurações")
@export var limite_movimento_horizontal: float = 250.0 

var is_dragging: bool = false
var drag_offset_x: float = 0.0
var pos_inicial_caneta: Vector2
var assinado: bool = false

func _ready():
	if caneta:
		pos_inicial_caneta = caneta.position
	
	if povo:
		povo.hide()

func _input(event):
	if assinado or not caneta: return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if caneta.get_global_rect().has_point(event.position):
					is_dragging = true
					drag_offset_x = caneta.position.x - get_local_mouse_position().x
			else:
				if is_dragging:
					is_dragging = false
					var tween = create_tween()
					tween.tween_property(caneta, "position", pos_inicial_caneta, 0.4).set_trans(Tween.TRANS_QUART)

	elif event is InputEventMouseMotion:
		if is_dragging:
			var mouse_x = get_local_mouse_position().x
			var nova_pos_x = mouse_x + drag_offset_x
			
			var min_x = pos_inicial_caneta.x
			var max_x = pos_inicial_caneta.x + limite_movimento_horizontal
			
			nova_pos_x = clamp(nova_pos_x, min_x, max_x)
			
			caneta.position = Vector2(nova_pos_x, pos_inicial_caneta.y)
			
			if nova_pos_x >= (max_x - 1.0):
				_realizar_assinatura()

func _realizar_assinatura():
	if assinado: return
	assinado = true
	is_dragging = false
	
	if decreto and textura_assinado:
		decreto.texture = textura_assinado
	else:
		print("ERRO: Textura assinada não configurada no Inspector!")
	
	caneta.hide()
	
	if texto_instrucao:
		var tween_txt = create_tween()
		tween_txt.tween_property(texto_instrucao, "modulate:a", 0.0, 0.5)

	await get_tree().create_timer(0.5).timeout
	
	var tween = create_tween().set_parallel()
	var altura_tela = get_viewport_rect().size.y
	
	tween.tween_property(decreto, "position:y", altura_tela + 200, 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(decreto, "rotation_degrees", 20.0, 1.5)
	tween.tween_property(decreto, "modulate:a", 0.0, 1.0).set_delay(0.5)
	
	await tween.finished
	
	_mostrar_protesto()

func _mostrar_protesto():
	if not povo: return
	
	povo.show()
	povo.modulate.a = 0.0
	
	var tween_povo = create_tween()
	tween_povo.tween_property(povo, "modulate:a", 1.0, 1.0)
	
	povo.play("protesto")
