extends Area2D

@export var speed = 1000
var target_position = Vector2.ZERO
var direction = Vector2.ZERO

func _ready():
	get_node("AnimationPlayer").play("fire_line")
	set_position(get_parent().get_node("Player").position)
	target_position = get_global_mouse_position()
	direction = (target_position - position).normalized()
	get_node("Sprite2D").rotation = PI + atan2(direction.y, direction.x)
	connect("body_entered", _on_body_entered)

func _process(delta):	
	position += direction * speed * delta

func _on_body_entered(body):
	if body is TileMap:
		queue_free()
