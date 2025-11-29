# ------------------------------- REVIEWED VERSION 2 --------------------------------------------------

extends CharacterBody3D

# -------------------- ENUMS --------------------
enum State { PATROL, CHASE, ATTACK_RANGED, ATTACK_MELEE, DEAD }

# -------------------- CONFIGURAÇÕES (EXPORT) --------------------
@export_group("Movement")
@export var speed: float = 4.0
@export var gravity: float = 9.8
@export var jump_velocity: float = 8.0 # Aumentei um pouco para o pulo ser bom

@export_group("Combat")
@export var combat_range: float = 8.0 # Distância para decidir brigar
@export var attack_range: float = 2.0 # Distância do soco (se precisar)
@export var damage_melee: int = 15
@export var damage_ranged: int = 10
@export var attack_cooldown_time: float = 2.0
@export var max_health: int = 50

@export_group("AI Settings")
@export var patrol_point_a: Vector3
@export var patrol_point_b: Vector3
@export var player_path: NodePath

# -------------------- VARIÁVEIS INTERNAS --------------------
var player: CharacterBody3D
var last_player_position: Vector3
var can_attack: bool = true 
var current_state: State = State.PATROL
var health: int

# Variável nova para controlar o dano único do laser
var has_hit_player_this_attack: bool = false

# -------------------- REFERÊNCIAS DE NÓS --------------------
@onready var animated_sprite: AnimatedSprite3D = $animations 
@onready var animation_player: AnimationPlayer = $attack_animation
@onready var area_laser: Area3D = $Projectile # Requer "Access as Unique Name" no Editor
@onready var sprite_laser: Node3D = $RangedAttack # Requer "Access as Unique Name" no Editor

# -------------------- INICIALIZAÇÃO --------------------
func _ready():
	health = max_health
	if player_path:
		player = get_node(player_path)
	
	# Garante estado inicial seguro do laser
	if area_laser: area_laser.monitoring = false
	if sprite_laser: sprite_laser.visible = false

# -------------------- LOOP DE FÍSICA (CÉREBRO) --------------------
func _physics_process(delta):
	if current_state == State.DEAD:
		return

	if player:
		last_player_position = player.global_position

	# Aqui é onde o jogo decide qual lógica rodar baseado no estado atual
	match current_state:
		State.PATROL:
			_patrol_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.ATTACK_RANGED:
			_handle_attack_physics(delta)
		State.ATTACK_MELEE:
			_handle_attack_physics(delta)

	# Gravidade Geral (exceto durante o pulo de ataque que tem gravidade própria)
	if current_state != State.ATTACK_MELEE:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0

	move_and_slide()
	atualizar_animacao()

# -------------------- LÓGICA DOS ESTADOS --------------------

func _patrol_state(delta):
	# Lógica de ir e vir entre ponto A e B
	var target = patrol_point_b if velocity.x > 0 else patrol_point_a 
	
	if global_position.distance_to(target) < 1.0:
		velocity.x *= -1 # Inverte direção
		
	var direction = (target - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Se ver o player dentro de uma distância segura, começa a perseguir
	if player and global_position.distance_to(player.global_position) <= combat_range * 1.5:
		current_state = State.CHASE

func _chase_state(delta):
	if not player:
		current_state = State.PATROL
		return

	var direction_vector = (player.global_position - global_position)
	direction_vector.y = 0 
	var distance = direction_vector.length()
	var direction = direction_vector.normalized()

	# --- ZONA DE COMBATE ---
	if distance <= combat_range:
		# Para de correr para lutar
		velocity.x = 0
		velocity.z = 0
		
		if can_attack:
			# Sorteio 50/50
			if randi() % 2 == 0:
				start_ranged_attack()
			else:
				start_melee_attack()
			return 

	# --- PERSEGUIÇÃO ---
	elif distance > combat_range:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

func _handle_attack_physics(delta):
	if current_state == State.ATTACK_MELEE:
		# Aplica gravidade no pulo
		velocity.y -= gravity * delta
		# Sem atrito horizontal para o pulo ir longe
	else:
		# No ataque ranged (laser) ele fica parado
		velocity.x = 0
		velocity.z = 0

# -------------------- SISTEMA DE COMBATE --------------------

func start_ranged_attack():
	current_state = State.ATTACK_RANGED
	can_attack = false
	has_hit_player_this_attack = false # Reseta a trava de dano
	
	# Olha para o player
	velocity = Vector3.ZERO
	if player:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	print("Inimigo: LASER!")
	sprite_laser.visible = true
	
	# Toca a animação (que aumenta o sprite e a colisão do laser)
	animation_player.play("corrupted_frequency")
	
	await animation_player.animation_finished
	
	sprite_laser.visible = false
	area_laser.monitoring = false
	end_attack()

func start_melee_attack():
	current_state = State.ATTACK_MELEE
	can_attack = false
	
	print("Inimigo: PULO ESMAGADOR!")
	blink_red() # Feedback visual rápido
	
	var jump_dir = (last_player_position - global_position).normalized()
	
	# Pulo forte e rápido em direção ao player
	velocity.y = jump_velocity * 1.5 
	velocity.x = jump_dir.x * speed * 2.0
	velocity.z = jump_dir.z * speed * 2.0
	
	# Espera sair do chão e depois espera cair
	await get_tree().create_timer(0.1).timeout 
	while not is_on_floor():
		await get_tree().process_frame
		if velocity.y < -30: break # Segurança anti-loop infinito
	
	# Aterrisagem com dano em área
	if player and global_position.distance_to(player.global_position) <= 3.0:
		if player.has_method("take_damage"):
			player.take_damage(damage_melee)

	end_attack()

func end_attack():
	current_state = State.CHASE
	# Cooldown antes de poder atacar de novo
	await get_tree().create_timer(attack_cooldown_time).timeout
	can_attack = true

# -------------------- SINAIS (Eventos) --------------------

# Esta função é chamada AUTOMATICAMENTE pelo Godot quando algo encosta na AreaLaser
func _on_area_laser_body_entered(body):
	# AQUI ESTÁ A VERIFICAÇÃO:
	# 1. "body == player" -> O objeto que encostou é o jogador?
	# 2. "current_state == State.ATTACK_RANGED" -> O inimigo está realmente atacando?
	# 3. "not has_hit_player_this_attack" -> O inimigo já deu dano nesse ataque específico?
	if body == player and current_state == State.ATTACK_RANGED and not has_hit_player_this_attack:
		print("Laser acertou o player!")
		if player.has_method("take_damage"):
			player.take_damage(damage_ranged)
		
		has_hit_player_this_attack = true # Fecha a "trava" para não dar dano de novo

# -------------------- VISUAIS E VIDA --------------------

func blink_red():
	var tween = create_tween()
	for i in range(2):
		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

func atualizar_animacao():
	if current_state == State.DEAD: return

	# Se estiver se movendo horizontalmente
	var vel_h = Vector2(velocity.x, velocity.z).length()
	if vel_h > 0.1:
		animated_sprite.play("walking")
	else:
		animated_sprite.play("idle")

	if velocity.x > 0: animated_sprite.flip_h = false
	elif velocity.x < 0: animated_sprite.flip_h = true

func take_damage(amount: int):
	health -= amount
	blink_red()
	if health <= 0 and current_state != State.DEAD:
		current_state = State.DEAD
		velocity = Vector3.ZERO
		# animação de morte, fade out, queue_free...
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate:a", 0.0, 1.0)
		tween.tween_callback(queue_free)


# ----------------------------- REVIEWED VERSION 1 --------------------------------------

# extends CharacterBody3D

# # -------------------- ENUMS (Organização) --------------------
# enum State { PATROL, CHASE, ATTACK_RANGED, ATTACK_MELEE, DEAD }

# # -------------------- EXPORT VARIABLES --------------------
# @export_group("Movement")
# @export var speed: float = 4.0
# @export var gravity: float = 9.8
# @export var jump_velocity: float = 6.0

# @export_group("Combat")
# @export var ranged_attack_distance: float = 10.0 # Distância para começar a atirar laser
# @export var attack_range: float = 2.0
# @export var damage_melee: int = 15
# @export var damage_ranged: int = 10
# @export var attack_cooldown_time: float = 2.0 # Tempo entre ataques
# @export var max_health: int = 50

# @export_group("AI Settings")
# @export var patrol_point_a: Vector3
# @export var patrol_point_b: Vector3
# @export var player_path: NodePath
# @export var projectile_scene: PackedScene

# # -------------------- INTERNAL VARIABLES --------------------
# var player: CharacterBody3D
# var last_player_position: Vector3
# var can_attack: bool = true # Substitui has_attacked para melhor controle logic
# var current_state: State = State.PATROL
# var health: int

# # -------------------- NODES --------------------
# # Usamos % para pegar o nó independente de onde ele esteja na cena (Unique Name)
# @onready var animated_sprite: AnimatedSprite3D = $animations 

# # -------------------- READY --------------------
# func _ready():
# 	health = max_health
# 	if player_path:
# 		player = get_node(player_path)

# # -------------------- PHYSICS PROCESS --------------------
# func _physics_process(delta):
# 	if current_state == State.DEAD:
# 		return

# 	# Atualiza posição do player se ele existir
# 	if player:
# 		last_player_position = player.global_position

# 	# Máquina de Estados
# 	match current_state:
# 		State.PATROL:
# 			_patrol_state(delta)
# 		State.CHASE:
# 			_chase_state(delta)
# 		State.ATTACK_RANGED, State.ATTACK_MELEE:
# 			_handle_attack_physics(delta) # Lida com gravidade durante ataque

# 	# Aplica gravidade padrão (se não estiver no meio de um pulo de ataque)
# 	if current_state != State.ATTACK_MELEE:
# 		if not is_on_floor():
# 			velocity.y -= gravity * delta
# 		else:
# 			velocity.y = 0

# 	move_and_slide()
	
# 	# --- CORREÇÃO: Chamando a animação ---
# 	atualizar_animacao()

# # -------------------- STATES --------------------
# func _patrol_state(delta):
# 	var target = patrol_point_b if velocity.x > 0 else patrol_point_a 
# 	# Lógica simples de vai e vem baseada na direção atual (poderia ser melhorada, mas funciona)
# 	if global_position.distance_to(target) < 1.0:
# 		# Troca o alvo invertendo a velocidade (truque simples)
# 		velocity.x *= -1 
		
# 	# Calcula direção para o ponto
# 	var direction = (target - global_position).normalized()
# 	velocity.x = direction.x * speed
# 	velocity.z = direction.z * speed

# 	# Se ver o player, muda para CHASE
# 	if player and global_position.distance_to(player.global_position) <= attack_range * 4:
# 		current_state = State.CHASE

# # No topo, nas variáveis exportadas:
# # Defina uma distância onde o inimigo se sente confortável para iniciar QUALQUER briga.
# # Sugestão: 8.0 ou 10.0 (já que o pulo cobre distância e o laser é longo)
# @export var combat_range: float = 8.0 

# func _chase_state(delta):
# 	if not player:
# 		current_state = State.PATROL
# 		return

# 	var direction_vector = (player.global_position - global_position)
# 	direction_vector.y = 0 
# 	var distance = direction_vector.length()
# 	var direction = direction_vector.normalized()

# 	# --- ZONA DE COMBATE ---
# 	# Se o jogador estiver dentro da zona de combate E o inimigo puder atacar:
# 	if distance <= combat_range:
		
# 		# Para o movimento padrão de perseguição para se preparar para o ataque
# 		velocity.x = 0
# 		velocity.z = 0
		
# 		if can_attack:
# 			# AQUI ESTÁ A LÓGICA DO SORTEIO (50% / 50%)
# 			# randi() % 2 retorna 0 ou 1.
# 			if randi() % 2 == 0:
# 				start_ranged_attack() # Laser
# 			else:
# 				start_melee_attack() # Pulo Imersivo
			
# 			return # Sai da função

# 	# --- MOVIMENTAÇÃO DE PERSEGUIÇÃO ---
# 	# Se estiver longe demais, corre atrás
# 	elif distance > combat_range:
# 		velocity.x = direction.x * speed
# 		velocity.z = direction.z * speed

# func _handle_attack_physics(delta):
# 	if current_state == State.ATTACK_MELEE:
# 		velocity.y -= gravity * delta
# 		# REMOVI O ATRITO HORIZONTAL AQUI.
# 		# Agora ele mantém o embalo do pulo até bater no chão.
# 	else:
# 		velocity.x = 0
# 		velocity.z = 0

# # -------------------- ATTACKS --------------------

# func start_ranged_attack():
# 	current_state = State.ATTACK_RANGED
# 	can_attack = false # Bloqueia novos ataques
	
# 	print("Inimigo: Carregando laser...")
# 	await blink_red() # Pisca antes de atirar
	
# 	# Instancia o projétil
# 	if projectile_scene:
# 		var projectile = projectile_scene.instantiate()
# 		get_parent().add_child(projectile)
# 		projectile.global_position = global_position + Vector3(0, 1.0, 0)
# 		if projectile.has_method("launch"):
# 			projectile.launch(last_player_position)
	
# 	# Volta a perseguir
# 	end_attack()


# # Ajuste esses valores no Inspector depois!
# # Sugestão: Aumente jump_velocity para 8.0 ou 10.0 se o mapa for grande
# func start_melee_attack():
# 	current_state = State.ATTACK_MELEE
# 	can_attack = false
	
# 	print("Inimigo: Salto esmagador!")
# 	await blink_red()
	
# 	# Pulo na direção do player
# 	var jump_dir = (last_player_position - global_position).normalized()
	
# 	# AUMENTAR A FORÇA DO PULO AQUI PARA COMPENSAR A GRAVIDADE
# 	velocity.y = jump_velocity * 1.5 
	
# 	# Mantém a velocidade horizontal constante durante o pulo
# 	velocity.x = jump_dir.x * speed * 1.5
# 	velocity.z = jump_dir.z * speed * 1.5
	
# 	# Espera um tempo fixo OU até tocar no chão
# 	# Vamos esperar ele sair do chão primeiro (0.1s) e depois esperar ele cair
# 	await get_tree().create_timer(0.1).timeout 
# 	while not is_on_floor():
# 		await get_tree().process_frame # Espera frame a frame até tocar o chão
		
# 		# (Segurança) Se ele ficar caindo por muito tempo (caiu do mapa), para o loop
# 		if velocity.y < -30: 
# 			break
	
# 	# Quando tocar no chão (impacto):
# 	# Lógica de Dano em Área
# 	if player and global_position.distance_to(player.global_position) <= attack_range + 2.0:
# 		if player.has_method("take_damage"):
# 			player.take_damage(damage_melee)

# 	end_attack()

# func end_attack():
# 	current_state = State.CHASE
# 	# Inicia o Cooldown para poder atacar de novo no futuro
# 	await get_tree().create_timer(attack_cooldown_time).timeout
# 	can_attack = true

# # -------------------- VISUALS & ANIMATION --------------------
# func blink_red():
# 	# Modifica a cor do SPRITE, não do Material 3D (já que é um personagem 2D)
# 	var tween = create_tween()
# 	for i in range(3):
# 		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
# 		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)
# 	await tween.finished

# func atualizar_animacao():
# 	# Se estiver morto, não anima
# 	if current_state == State.DEAD:
# 		return

# 	# Prioridade para animação de ataque (opcional, se você tiver essas animações)
# 	# if current_state == State.ATTACK_RANGED: ...
	
# 	# Lógica de movimento vs parado
# 	var vel_horizontal = Vector2(velocity.x, velocity.z).length()
	
# 	if vel_horizontal > 0.1:
# 		animated_sprite.play("walking")
# 	else:
# 		animated_sprite.play("idle")

# 	# Flip (Espelhamento)
# 	if velocity.x < 0:
# 		animated_sprite.flip_h = false # Direita
# 	elif velocity.x > 0:
# 		animated_sprite.flip_h = true  # Esquerda

# # -------------------- HEALTH & DEATH --------------------
# func take_damage(amount: int):
# 	health -= amount
# 	blink_red() # Feedback visual de dano
# 	if health <= 0 and current_state != State.DEAD:
# 		die()

# func die():
# 	current_state = State.DEAD
# 	velocity = Vector3.ZERO
	
# 	# Se tiver animação de morte:
# 	if animated_sprite.sprite_frames.has_animation("defeat"):
# 		animated_sprite.play("defeat")
	
# 	print("Inimigo derrotado")
	
# 	# Fade Out correto para Godot 4
# 	var tween = create_tween()
# 	tween.tween_property(animated_sprite, "modulate:a", 0.0, 1.5) # :a acessa só o Alpha
# 	tween.tween_callback(queue_free)














# ------------------------------- KERI'S VERSION --------------------------------------------


# extends CharacterBody3D

# # -------------------- EXPORT VARIABLES --------------------
# @export var speed: float = 4.0
# @export var gravity: float = 9.8
# @export var jump_velocity: float = 6.0
# @export var attack_range: float = 2.0
# @export var damage_melee: int = 15
# @export var damage_ranged: int = 10
# @export var blink_count: int = 3
# @export var blink_duration: float = 0.15
# @export var patrol_point_a: Vector3
# @export var patrol_point_b: Vector3
# @export var player_path: NodePath
# @export var projectile_scene: PackedScene
# @export var max_health: int = 50

# # -------------------- INTERNAL VARIABLES --------------------
# var player: CharacterBody3D
# var last_player_position: Vector3
# var has_attacked: bool = false
# var is_attacking: bool = false
# var move_direction: int = 1
# var state: int = 0  # 0=PATROL,1=CHASE,2=RANGED_ATTACK,3=MELEE_ATTACK,4=DEAD
# var health: int

# # -------------------- MESH & MATERIAL --------------------
# @onready var mesh: MeshInstance3D = $MeshInstance3D
# var mat: StandardMaterial3D
# var original_color: Color

# # -------------------- ANIMATION SPRITE NODE --------------
# @onready var animated_sprite_3d : AnimatedSprite3D = $animations


# # -------------------- READY --------------------
# func _ready():
# 	health = max_health

# 	if player_path != null:
# 		player = get_node(player_path)

# 	# Ensure material exists
# 	var existing = mesh.get_active_material(0)
# 	if existing:
# 		mat = existing.duplicate()
# 	else:
# 		mat = StandardMaterial3D.new()
# 	mesh.set_surface_override_material(0, mat)
# 	original_color = mat.albedo_color


# # -------------------- PHYSICS PROCESS --------------------
# func _physics_process(delta):
# 	if state == 4:  # DEAD
# 		return

# 	# Update last player position
# 	if player != null:
# 		last_player_position = player.global_position

# 	match state:
# 		0: _patrol(delta)
# 		1: _chase(delta)
# 		2: pass
# 		3: pass

# 	# Apply gravity
# 	if not is_on_floor():
# 		velocity.y -= gravity * delta
# 	else:
# 		if not is_attacking:
# 			velocity.y = 0

# 	# Move using CharacterBody3D built-in velocity
# 	move_and_slide()


# # -------------------- PATROL --------------------
# func _patrol(delta):
# 	var target = patrol_point_b if move_direction == 1 else patrol_point_a
# 	var direction = (target - global_position)
# 	direction.y = 0

# 	if direction.length() < 0.1:
# 		move_direction *= -1
# 	else:
# 		velocity.x = direction.normalized().x * speed
# 		velocity.z = direction.normalized().z * speed

# 	# Switch to chase if player is close
# 	if player != null and global_position.distance_to(player.global_position) <= attack_range * 3:
# 		state = 1


# # -------------------- CHASE --------------------
# func _chase(delta):
# 	if player == null:
# 		state = 0
# 		return

# 	var direction = (player.global_position - global_position)
# 	direction.y = 0
# 	var distance = direction.length()
# 	if distance > 0:
# 		direction = direction.normalized()
# 	else:
# 		direction = Vector3.ZERO

# 	# Move toward player
# 	if not is_attacking and distance > attack_range:
# 		velocity.x = direction.x * speed
# 		velocity.z = direction.z * speed
# 	else:
# 		velocity.x = 0
# 		velocity.z = 0

# 	# Attack when in range
# 	if distance <= attack_range and not has_attacked:
# 		if randi() % 2 == 0:
# 			state = 2
# 			start_ranged_attack()
# 		else:
# 			state = 3
# 			start_melee_attack()


# # -------------------- RANGED ATTACK --------------------
# func start_ranged_attack():
# 	is_attacking = true
# 	has_attacked = true
# 	print("Enemy performs RANGED attack!")

# 	await blink_red()

# 	if projectile_scene != null:
# 		var projectile = projectile_scene.instantiate()
# 		get_parent().add_child(projectile)
# 		projectile.global_position = global_position + Vector3(0, 1.5, 0)
# 		if projectile.has_method("launch"):
# 			projectile.launch(last_player_position)

# 	is_attacking = false
# 	state = 0


# # -------------------- MELEE ATTACK --------------------
# func start_melee_attack():
# 	is_attacking = true
# 	has_attacked = true
# 	print("Enemy performs MELEE attack!")

# 	await blink_red()

# 	var jump_direction = (last_player_position - global_position)
# 	jump_direction.y = 0
# 	if jump_direction.length() > 0:
# 		jump_direction = jump_direction.normalized()
# 	else:
# 		jump_direction = Vector3.ZERO

# 	velocity.y = jump_velocity
# 	velocity.x = jump_direction.x * speed
# 	velocity.z = jump_direction.z * speed

# 	await get_tree().create_timer(0.5).timeout
# 	if player != null and global_position.distance_to(player.global_position) <= attack_range + 1:
# 		if player.has_method("take_damage"):
# 			player.take_damage(damage_melee)

# 	is_attacking = false
# 	state = 0


# # -------------------- BLINKING --------------------
# func blink_red() -> void:
# 	for i in range(blink_count):
# 		mat.albedo_color = Color(1, 0, 0)
# 		await get_tree().create_timer(blink_duration).timeout
# 		mat.albedo_color = original_color
# 		await get_tree().create_timer(blink_duration).timeout


# # -------------------- DAMAGE & DEATH --------------------
# func take_damage(amount: int):
# 	health -= amount
# 	if health <= 0 and state != 4:
# 		state = 4
# 		start_death()


# func start_death():
# 	print("Enemy defeated! Fading out...")
# 	var fade_time = 1.0
# 	var tween = Tween.new()
# 	add_child(tween)
# 	tween.tween_property(mat, "albedo_color", Color(0,0,0,0), fade_time)
# 	tween.tween_callback(Callable(self, "queue_free"))
# 	tween.play()

# func atualizar_animacao():
# 	# Verifica a velocidade horizontal (ignorando Y/pulo)
# 	var velocidade_horizontal = Vector3(velocity.x, 0, velocity.z).length()
	
# 	if velocidade_horizontal > 0.1: # Se estiver se movendo
# 		animated_sprite_3d.play("walking")
# 	else:
# 		animated_sprite_3d.play("idle")

# 	if velocity.x > 0:
# 		animated_sprite_3d.flip_h = true 
# 	elif velocity.x < 0:
# 		animated_sprite_3d.flip_h = false 
