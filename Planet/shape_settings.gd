class_name ShapeSettings extends Resource

@export var layers: Array[NoiseLayer]

@export var planet_radius := 2.0:
	set(new):
		planet_radius = new
		emit_changed()
		
@export var sea_level := 2.0:
	set(new):
		sea_level = new
		emit_changed()

@export var resolution := 32:
	set(new):
		resolution = new
		emit_changed()

		
var elevation_min_max: MinMax
	
func calc_point_on_planet(point_on_unit_sphere: Vector3) -> Vector3:
	
	var first_layer_val: float = layers[0].evaluate(point_on_unit_sphere)
	var elevation := 0.0

	for i in range(layers.size()):
		var mask: float = first_layer_val if layers[i].use_first_layer_mask else 1.0
		elevation += layers[i].evaluate(point_on_unit_sphere) * mask

	elevation = max(elevation, sea_level)
	elevation = planet_radius * (1.0 + elevation)
	elevation_min_max.add_value(elevation)
	
	return point_on_unit_sphere * elevation

func _init() -> void:
	elevation_min_max = MinMax.new()
	layers.resize(3)
	for i in range(layers.size()):
		layers[i] = NoiseLayer.new()
		
