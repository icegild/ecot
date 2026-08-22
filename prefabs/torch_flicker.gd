extends PointLight2D

## Subtle torch light flicker effect.
## Attach to a PointLight2D child of a torch.

@export var base_energy: float = 1.5
@export var flicker_strength: float = 0.3
@export var flicker_speed: float = 8.0
@export var secondary_speed: float = 13.0

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	var flicker: float = sin(_time * flicker_speed) * flicker_strength * 0.5
	flicker += sin(_time * secondary_speed) * flicker_strength * 0.3
	flicker += sin(_time * secondary_speed * 1.7) * flicker_strength * 0.2
	energy = base_energy + flicker
