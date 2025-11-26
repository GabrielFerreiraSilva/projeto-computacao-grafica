extends Control

@export var feudos: Array[TextureRect]

@export var posicoes_finais: Array[Vector2]

@onready var botao_coroa = $BotaoCoroaCentral
@onready var coroa_final = $CoroaFinal

var animacao_em_andamento = false

func _ready():
	botao_coroa.pressed.connect(_iniciar_animacao)

func _iniciar_animacao():
	if animacao_em_andamento:
		return
	animacao_em_andamento = true
	
	botao_coroa.disabled = true

	var tween = create_tween()
	tween.set_parallel(true)

	for i in range(feudos.size()):
		var feudo_atual = feudos[i]
		var posicao_final = posicoes_finais[i]
		
		tween.tween_property(feudo_atual, "position", posicao_final, 1.2).set_trans(Tween.TRANS_SINE)

	tween.tween_property(botao_coroa, "modulate:a", 0.0, 0.5)
	
	coroa_final.show()
	coroa_final.modulate.a = 0.0
	
	tween.tween_property(coroa_final, "modulate:a", 1.0, 0.8).set_delay(0.4)

	await tween.finished
