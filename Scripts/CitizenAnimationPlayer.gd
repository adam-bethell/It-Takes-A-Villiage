extends AnimationPlayer

onready var walk_speed = get_parent().WALK_SPEED + 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	# Get current linear velocity
	
	var velocity = get_parent().linear_velocity
	if velocity == Vector3.ZERO:
		# Idle
		$AnimationTree.set_animation("idle")
	elif velocity.length() <= walk_speed:
		# Walking
		$AnimationTree.set_animation("walk")
	else:
		# Running
		$AnimationTree.set_animation("run")
