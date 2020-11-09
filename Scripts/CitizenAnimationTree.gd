extends AnimationTree

const BLEND_SPEED = 5
const ANIMATIONS = {
	"idle": Vector2(0,0),
	"walk": Vector2(1,0),
	"run": Vector2(1,1),
}
var _current_blend = ANIMATIONS["idle"]
var _blend_target = ANIMATIONS["idle"]


func _process(delta):
	var blend_speed = BLEND_SPEED * delta
	var new_blend = _current_blend.move_toward(_blend_target, blend_speed)
	new_blend = Vector2(
		clamp(new_blend.x, 0, 1),
		clamp(new_blend.y, 0, 1)
	)
	set("parameters/Locomotion/blend_position", new_blend)
	_current_blend = new_blend


func set_animation(anim):
	_blend_target = ANIMATIONS[anim] 
