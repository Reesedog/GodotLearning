extends Area2D

var level = 1
var hp = 10
var speed = 100
var damage = 5
var knock_amount = 1.0
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_nodes_in_group("player")

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp = 10
			speed = 300
			damage = 5
			knock_amount = 100
			attack_size = 1.0
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1)*attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _physics_process(delta):
	position += angle*speed*delta
	
func enemy_hit(charge):
	hp -= charge
	if hp <= 0:
		queue_free()

func _on_timer_timeout():
	queue_free()
