@tool
class_name Planet extends Node3D

@export var mesh_material := StandardMaterial3D.new()

@export_range(2,64) var resolution: int = 8:
	set(new):
		resolution = new
		_on_changed()

@export_range(1.0, 100.0) var radius: float = 1.0:
	set(new):
		radius = new
		_on_changed()
		
@export var noise := NoiseFilter.new():
	set(new):
		noise = new
		_on_changed()

const NUM_PLANET_SIDES = 6
const DIRECTIONS = [
	Vector3.UP,
	Vector3.DOWN,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.FORWARD,
	Vector3.BACK
]

var mesh_instances: Array[MeshInstance3D]
var terrain_faces: Array[TerrainFace]

func _ready() -> void:
	noise.changed.connect(_on_changed)
	_on_changed()


func _on_changed() -> void:
	generate_mesh()

func _init():
	mesh_instances.resize(NUM_PLANET_SIDES)
	terrain_faces.resize(NUM_PLANET_SIDES)

func generate_mesh():
	for i in range(NUM_PLANET_SIDES):
		if mesh_instances[i] == null:
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.name = "mesh_%d" % i
			add_child(mesh_instance)

			mesh_instance.mesh = ArrayMesh.new()
			mesh_instance.material_override = mesh_material
			mesh_instances[i] = mesh_instance

		terrain_faces[i] = TerrainFace.new(resolution, radius, DIRECTIONS[i], noise)
		mesh_instances[i].mesh.reset_state()
		mesh_instances[i].mesh = terrain_faces[i].construct_mesh()
