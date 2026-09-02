extends State

var target_enemy: Node2D = null
var target_facing: Vector2 = Vector2.ZERO
var transition_duration: float = 0.5
var timer: float = 0.0

func enter(msg := {}) -> void:
	clayling.stop_moving()
	target_enemy = msg.get("target_enemy", null)
	target_facing = msg.get("target_facing", clayling.formation_facing if "formation_facing" in clayling else Vector2.ZERO)
	timer = 0.0

	if clayling.is_under_attack and clayling.last_attacker and is_instance_valid(clayling.last_attacker):
		_face_target(clayling.last_attacker.global_position)
	elif target_facing != Vector2.ZERO:
		_face_direction(target_facing)
	elif "formation_facing" in clayling and clayling.formation_facing != Vector2.ZERO:
		_face_direction(clayling.formation_facing)
	elif target_enemy and is_instance_valid(target_enemy):
		_face_target(target_enemy.global_position)

	var dir = clayling.last_direction if clayling.last_direction != "" else "down"
	var anim_name = "spearman_to_combat_stance_" + dir
	clayling.play_forced_animation(anim_name)

func update(delta: float) -> void:
	timer += delta

	# Check if ANY living enemy is in immediate strike range
	var melee_target = clayling.find_nearest_enemy(28.0)
	if melee_target:
		_face_target(melee_target.global_position)
		clayling.force_animation = ""
		clayling.change_state("SoldierAttack", { "target_enemy": melee_target, "target_facing": target_facing })
		return

	# Finish transition and enter steady combat stance
	if timer >= transition_duration or clayling.force_animation == "":
		clayling.force_animation = ""
		var clean_target = target_enemy if (target_enemy and is_instance_valid(target_enemy) and not target_enemy.get("is_dead")) else null
		clayling.change_state("SoldierStance", { "target_enemy": clean_target, "target_facing": target_facing })

func exit() -> void:
	clayling.force_animation = ""

func _face_target(pos: Vector2) -> void:
	var diff = pos - clayling.global_position
	if abs(diff.x) * 1.5 >= abs(diff.y):
		clayling.last_direction = "side"
		clayling.set_flip_h(diff.x < 0)
	else:
		clayling.last_direction = "up" if diff.y < 0 else "down"

func _face_direction(dir_vec: Vector2) -> void:
	if abs(dir_vec.x) * 1.5 >= abs(dir_vec.y):
		clayling.last_direction = "side"
		clayling.set_flip_h(dir_vec.x < 0)
	else:
		clayling.last_direction = "up" if dir_vec.y < 0 else "down"
