extends CharacterBody2D


var movement_speed = 40
var hp = 80

# Attack
var iceSpear = preload("res://player/Attack/ice_spear.tscn")

@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

# Ice Spear
var iceSpearAmmo = 0
var iceSpearBaseAmmo = 1
var iceSpearAttackSpeed = 1.5
var iceSpearLevel = 1

# Enemy 
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

func _ready():
	attack()

func _physics_process(_delta):
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
		
	if mov != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
		
	velocity = mov.normalized()*movement_speed
	move_and_slide()


func _on_hurtbox_hurt(damage):
	hp -= damage
	print(hp)

func attack():
	if iceSpearAmmo > 0:
		iceSpearTimer.wait_time = iceSpearAttackSpeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()

func _on_ice_spear_timer_timeout():
	iceSpearAmmo += iceSpearBaseAmmo
	iceSpearAttackTimer.start()

func _on_ice_spear_attack_timer_timeout():
	if iceSpearAmmo > 0:
		var iceSpearAttack = iceSpear.instantiate()
		iceSpearAttack.position = position
		iceSpearAttack.target = get_random_target()
		iceSpearAttack.level = iceSpearLevel
		add_child(iceSpearAttack)
		iceSpearAmmo -= 1
		if iceSpearAmmo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
