extends Node
class_name divAttackMode

# Como se trata de um script que vai ser usado somente como algo a ser chamado por outro script, ele só vai conter funções estáticas e que não rodam direto quando o script é chamado (como a _process faz)

static var is_mode_on = false

static func do_attack():
	print("Attacked!")
	is_mode_on = true
