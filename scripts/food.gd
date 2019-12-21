extends Area2D

signal hit

func setPos(vec2):
	self.position = vec2

func get_new_position():
	randomize()
	var x
	var y
	
	var i = randf()
	if i < 0.5:
		x = rand_range(2.0*32+16, 14.0*32+16)
	else:
		x = rand_range(17.0*32+16, 29.0*32+16)
	y = rand_range(2.0*32+16, 17.0*32+16)
	
	return Vector2(x,y)

func reset():
	self.position = get_new_position()

func _on_food_body_entered(body):
	emit_signal("hit")
	reset()

func _ready():
	pass