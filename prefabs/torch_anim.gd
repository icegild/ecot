extends Sprite2D

## Cycles hframes for a sprite sheet animation.
## Attach to a Sprite2D that has hframes > 1.

@export var speed: float = 6.0  # frames per second

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	frame = int(_time * speed) % hframes
