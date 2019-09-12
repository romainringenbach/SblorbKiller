extends Node2D

const SPEED : = 50.0
var path : = PoolVector2Array() setget set_path



signal finish_move(sblorb)
signal hitten()
signal hit_player()

var type = "sblorb"

var default_animation = "default"
var dead_animation = "dead"

const CHECK_TIME = 0.5
var elapsed_time_since_last_check = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == "red_sblorb":
		default_animation = "red_default"
		dead_animation = "red_dead"
	$AnimatedSprite.animation = default_animation
	
	set_process(false)
	emit_signal("finish_move",self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	elapsed_time_since_last_check += delta
	if elapsed_time_since_last_check >= CHECK_TIME:
		elapsed_time_since_last_check = 0
		if type == "sblorb" and path.size() > 0:
			if !(get_parent().check_path(global_position,path[path.size()-1])):
				path = []
		elif type == "red_sblorb":
			path = []
	
		
	if path.size() > 0:
		var distance : = SPEED * delta
		var start_point : = global_position
		
		for i in range(path.size()):
			var distance_to_next := start_point.distance_to(path[0])
			if distance <= distance_to_next and distance >= 0.0:
				global_position = start_point.linear_interpolate(path[0], distance / distance_to_next)
				break
			elif distance < 0.0:
				global_position = path[0]
				set_process(false)
				emit_signal("finish_move",self)
				break
				
			distance -= distance_to_next
			start_point = path[0]
			path.remove(0)
	
	else:
		set_process(false)
		emit_signal("finish_move",self)
	
	

func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() != 0:
		set_process(true)

func _on_Area2D_body_entered(body : PhysicsBody2D):
	if body != null and not body.get("I") == null:
		if body.I == "bullet":
			emit_signal("hitten")
			set_process(false)
			$AnimatedSprite.animation = dead_animation
			
		elif body.I == "player" and $AnimatedSprite.animation != dead_animation:
			set_process(false)
			emit_signal("hit_player")
			get_parent().remove_child(self)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == dead_animation:
		get_parent().remove_child(self)
