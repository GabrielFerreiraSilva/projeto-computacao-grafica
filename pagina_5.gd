extends Control

@export var pivot_node: Node2D
@export var prato_executivo: Control
@export var prato_legislativo: Control
@export var alerta_executivo: Control
@export var alerta_legislativo: Control

@export var mensagem_verde: Control
@export var mensagem_vermelha_executivo: Control
@export var mensagem_vermelha_legislativo: Control

@export_range(1, 45) var max_inclinacao_graus: float = 25.0
@export_range(1, 45) var limiar_alerta_graus: float = 12.5
@export_range(1, 100) var sensibilidade: float = 10.0 
@export_range(1, 10) var suavizacao: float = 5.0

enum Estado { EQUILIBRADO, EXECUTIVO_PESADO, LEGISLATIVO_PESADO }
var estado_atual_balanca = Estado.EQUILIBRADO

func _ready():
	_atualizar_visibilidade(estado_atual_balanca)
	
	if not pivot_node:
		print("ERRO: Você esqueceu de arrastar o Pivot para a variável 'Pivot Node' no Inspector!")

func _process(delta):
	var acelerometro = Input.get_accelerometer()
	
	var inclinacao_sensor = acelerometro.x 
	
	var angulo_alvo = inclinacao_sensor * sensibilidade
	angulo_alvo = clamp(angulo_alvo, -max_inclinacao_graus, max_inclinacao_graus)
	
	if pivot_node:
		pivot_node.rotation_degrees = lerp(pivot_node.rotation_degrees, angulo_alvo, delta * suavizacao)
		
		var angulo_do_pivot = pivot_node.rotation_degrees
		
		if prato_executivo: prato_executivo.rotation_degrees = -angulo_do_pivot
		if prato_legislativo: prato_legislativo.rotation_degrees = -angulo_do_pivot
		
		var novo_estado = _determinar_estado_atual(angulo_do_pivot)
		if novo_estado != estado_atual_balanca:
			estado_atual_balanca = novo_estado
			_atualizar_visibilidade(estado_atual_balanca)

func _determinar_estado_atual(angulo: float) -> Estado:
	if angulo > limiar_alerta_graus:
		return Estado.LEGISLATIVO_PESADO
	elif angulo < -limiar_alerta_graus:
		return Estado.EXECUTIVO_PESADO
	else:
		return Estado.EQUILIBRADO

func _atualizar_visibilidade(novo_estado: Estado):
	if not mensagem_verde: return
	
	match novo_estado:
		Estado.EQUILIBRADO:
			mensagem_verde.show()
			mensagem_vermelha_executivo.hide()
			mensagem_vermelha_legislativo.hide()
			alerta_executivo.hide()
			alerta_legislativo.hide()
		Estado.EXECUTIVO_PESADO:
			mensagem_verde.hide()
			mensagem_vermelha_executivo.show()
			mensagem_vermelha_legislativo.hide()
			alerta_executivo.show()
			alerta_legislativo.hide()
		Estado.LEGISLATIVO_PESADO:
			mensagem_verde.hide()
			mensagem_vermelha_executivo.hide()
			mensagem_vermelha_legislativo.show()
			alerta_executivo.hide()
			alerta_legislativo.show()
