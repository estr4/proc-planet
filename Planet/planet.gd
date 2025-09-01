@tool
class_name Planet extends Node3D

@export var planet_settings := PlanetSettings.new()
@export var shape_settings := ShapeSettings.new()


@export_tool_button("ElevationMinMax") var action = get_min_max

var mi = shape_settings.elevation_min_max.minimum
var ma = shape_settings.elevation_min_max.maximum

func get_min_max() -> void:
	print("min: ", mi)
	print("max: ", ma)

var terrain_faces: Array[TerrainFace]

func _process(delta: float) -> void:
	rotation.x += delta * PI / 30.0

func _ready() -> void:
	connect_signals()
	initialise_mesh()
	_on_changed()

func connect_signals():
	planet_settings.changed.connect(_on_changed)
	shape_settings.changed.connect(_on_changed)
	for layer in shape_settings.layers:
		layer.changed.connect(_on_changed)
	
func _on_changed() -> void:
	shape_settings.elevation_min_max = MinMax.new()
	generate_mesh()
	mi = shape_settings.elevation_min_max.minimum
	ma = shape_settings.elevation_min_max.maximum
	RenderingServer.global_shader_parameter_set("elevation_min_max", Vector2(mi, ma))
	
func initialise_mesh() -> void:
	var directions := [ Vector3.DOWN, Vector3.UP, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ]
	terrain_faces.resize(6)
	for i in range(6):
		terrain_faces[i] = TerrainFace.new(directions[i], shape_settings)
		planet_settings.material.shader = preload("res://Planet/planet.gdshader")
		terrain_faces[i].material_override = planet_settings.material
		add_child(terrain_faces[i])
		
func generate_mesh() -> void:
	for face in terrain_faces:
		face.construct_mesh()

# Ugly asf but godot doesnt have a better option yet https://github.com/godotengine/godot-proposals/issues/10720
class PlanetSettings extends Resource:
	@export var hot_reloading := true:
		set(new):
			hot_reloading = new
			emit_changed()
	
	@export var material = ShaderMaterial.new()
