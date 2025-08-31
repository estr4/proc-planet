class_name MinMax

# for finding the highest and lowest point on the planet

var minimum: float
var maximum: float

func _init() -> void:
	minimum = Globals.FLOAT32_MAX
	maximum = Globals.FLOAT32_MIN


	
func add_value(v: float) -> void:
	maximum = max(maximum, v)
	minimum = min(minimum, v)

