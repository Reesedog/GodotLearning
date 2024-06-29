extends CharacterBody2D


var movement_speed = 40
var hp = 80
var last_movement = Vector2.RIGHT

var experience = 0
var experience_level = 1
var collected_experience = 0

# Attack
var iceSpear = preload("res://player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

# Ice Spear
var iceSpearAmmo = 0
var iceSpearBaseAmmo = 1
var iceSpearAttackSpeed = 1.5
var iceSpearLevel = 0

# Tornado
var tornadoAmmo = 0
var tornadoBaseAmmo = 1
var tornadoAttackSpeed = 3
var tornadoLevel = 0

# Javelin
var javelin_ammo = 1
var javelin_level = 1


# Enemy 
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

# GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var ItemOptions = preload("res://Util/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelUp")

func _ready():
	attack()
	set_expbar(experience, calculate_experiencecap())

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
		last_movement = mov
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
			
	if tornadoAmmo > 0:
		tornadoTimer.wait_time = tornadoAttackSpeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
			
	if javelin_level > 0:
		spawn_javelin()

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

func _on_tornado_attack_timer_timeout():
	tornadoAmmo += tornadoBaseAmmo
	tornadoAttackTimer.start()

func _on_tornado_timer_timeout():
	if tornadoAmmo > 0:
		var tornadoAttack = tornado.instantiate()
		tornadoAttack.position = position
		tornadoAttack.last_movement = last_movement
		tornadoAttack.level = tornadoLevel
		add_child(tornadoAttack)
		tornadoAmmo -= 1
		if tornadoAmmo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()
			
func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1



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
		

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
		
func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
		set_expbar(experience, exp_required)
	else:
		experience += collected_experience
		collected_experience = 0
		set_expbar(experience, exp_required)
	
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level <40:
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	print(set_value)
	print(set_max_value)
	expBar.value = set_value
	expBar.max_value = set_max_value
	
func levelup():
	sndLevelUp.play()
	lblLevel.text = str("level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = ItemOptions.instantiate()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	var options_children = upgradeOptions.get_children()
	for i in options_children:
		i.queue_free()
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)
