@tool
class_name Planet extends Node3D

class PlanetState extends Resource:
	@export_range(2,100) var resolution: int = 8:
		set(new):
			resolution = new
			emit_changed()

const NUM_PLANET_SIDES = 6
const DIRECTIONS = [
	Vector3.UP,
	Vector3.DOWN,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.FORWARD,
	Vector3.BACK
]

@export_category("Settings")
@export var state := PlanetState.new()
@export var mesh_instances: Array[MeshInstance3D]
var terrain_faces: Array[TerrainFace]

func _ready() -> void:
	GenerateMesh()

func _on_changed() -> void:
	_ready()

func _init():
	mesh_instances.resize(NUM_PLANET_SIDES)
	terrain_faces.resize(NUM_PLANET_SIDES)
	state.changed.connect(_on_changed)

func GenerateMesh():
	for i in range(NUM_PLANET_SIDES):
		if mesh_instances[i] == null:
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.name = "mesh_%d" % i
			add_child(mesh_instance)

			mesh_instance.mesh = ArrayMesh.new()
			mesh_instances[i] = mesh_instance

		terrain_faces[i] = TerrainFace.new(state.resolution, DIRECTIONS[i])
		mesh_instances[i].mesh.reset_state()
		mesh_instances[i].mesh = terrain_faces[i].ConstructMesh()
