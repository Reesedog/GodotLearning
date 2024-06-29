extends CharacterBody2D

@export var movement_speed = 20.0
@export var hp = 10
@export var experience = 1

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer

var exp_gem = preload("res://Objects/experience_gem.tscn")

func _ready():
	anim.play("walk")

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false


func _on_hurtbox_hurt(damage):
	hp -= damage
	if hp <= 0:
		var new_gem = exp_gem.instantiate()
		new_gem.global_position = global_position
		new_gem.experience = experience
		loot_base.call_deferred("add_child", new_gem)
		queue_free()

func death():
	pass
