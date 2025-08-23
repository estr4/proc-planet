@tool
class_name Planet extends Node3D

const NUM_PLANET_SIDES = 6

@export_category("Settings")
@export_range(4, 64) var resolution := 8

var mesh_instances: Array[MeshInstance3D]
var terrain_faces: Array[TerrainFace]

func _ready() -> void:
	GenerateMesh()

func _init():
	mesh_instances.resize(NUM_PLANET_SIDES)
	terrain_faces.resize(NUM_PLANET_SIDES)

	var directions = [
		Vector3.UP,
		Vector3.DOWN,
		Vector3.LEFT,
		Vector3.RIGHT,
		Vector3.FORWARD,
		Vector3.BACK
	]

	for i in range(NUM_PLANET_SIDES):
		if mesh_instances[i] == null:
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.name = "mesh_%d" % i
			add_child(mesh_instance)

			mesh_instance.mesh = ArrayMesh.new()
			mesh_instances[i] = mesh_instance

		# Assuming you create a TerrainFace.gd class that handles mesh generation
		terrain_faces[i] = TerrainFace.new(resolution, directions[i])

func GenerateMesh():
	for i in range(NUM_PLANET_SIDES):
		mesh_instances[i].mesh = terrain_faces[i].ConstructMesh()
