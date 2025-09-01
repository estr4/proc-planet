class_name NoiseLayer extends FastNoiseLite

@export var roughness := 25.0:
	set(new):
		roughness = new
		emit_changed()

@export var amplitude := 1.0:
	set(new):
		amplitude = new
		emit_changed()

@export var use_first_layer_mask := false
		
@export var enabled := true:
	set(new):
		enabled = new
		emit_changed()
		
func _init() -> void:
	noise_type = FastNoiseLite.TYPE_SIMPLEX
	frequency = 0.025
	seed = randi()

func evaluate(point: Vector3) -> float:
	if not enabled:
		return 0.0
	
	var v := (get_noise_3dv(point * roughness + offset) + 5.0) * 0.15
	return v * amplitude
