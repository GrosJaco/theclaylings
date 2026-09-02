extends State

var alert_range: float = 150.0
var attack_range: float = 26.0

var _scan_timer: float = 0.0

func enter(msg := {}) -> void:
	clayling.stop_moving()
	clayling.force_animation = ""
	_scan_timer = randf_range(0.0, 0.15)
	var target_facing = msg.get("target_facing", clayling.formation_facing if "formation_facing" in clayling else Vector2.ZERO)
	if target_facing != Vector2.ZERO:
		_face_direction(target_facing)
	var dir = clayling.last_direction if clayling.last_direction != "" else "down"
	var anim = "spearman_idle_" + dir
	clayling._update_sprite_offset_for_animation(anim)
	clayling.sprite.play(anim)

func update(delta: float) -> void:
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = randf_range(0.18, 0.25)

		# Priority 1: Check for any enemy in immediate spear strike range
		var melee_enemy = clayling.find_nearest_enemy(attack_range + 4.0)
		if melee_enemy:
			clayling.change_state("SoldierAttack", { "target_enemy": melee_enemy, "target_facing": clayling.formation_facing })
			return

		# Priority 2: Scan for enemies in alert range (150px) -> enter combat stance holding formation
		var alert_enemy = clayling.find_nearest_enemy(alert_range)
		if alert_enemy:
			clayling.change_state("SoldierToStance", { "target_enemy": alert_enemy, "target_facing": clayling.formation_facing })
			return

	var dir = clayling.last_direction if clayling.last_direction != "" else "down"
	var anim = "spearman_idle_" + dir
	clayling._update_sprite_offset_for_animation(anim)
	if clayling.sprite.animation != anim:
		clayling.sprite.play(anim)

func _face_direction(dir_vec: Vector2) -> void:
	if abs(dir_vec.x) * 1.5 >= abs(dir_vec.y):
		clayling.last_direction = "side"
		clayling.set_flip_h(dir_vec.x < 0)
	else:
		clayling.last_direction = "up" if dir_vec.y < 0 else "down"

