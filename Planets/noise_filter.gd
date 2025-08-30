@tool
class_name NoiseFilter extends FastNoiseLite

@export var roughness := 10.0:
	set(new):
		roughness = new
		emit_changed()

func evaluate(point: Vector3) -> float:
	var value = get_noise_3dv(point * roughness)
	return value * 1.0 + 0.5
