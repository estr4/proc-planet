@tool
class_name TerrainFace

var resolution: int
var radius: float
var local_up: Vector3
var axis_a: Vector3
var axis_b: Vector3
var noise: NoiseFilter

func _init(resolution_: int, radius_: float, local_up_: Vector3, noise_: NoiseFilter) -> void:
	resolution = resolution_
	radius = radius_
	local_up = local_up_
	noise = noise_
	
	axis_a = Vector3(local_up.y, local_up.z, local_up.x)
	axis_b = axis_a.cross(local_up)

func calculate_point_on_planet(point_on_unit_sphere: Vector3) -> Vector3:
	var elavation: float = noise.evaluate(point_on_unit_sphere)
	return point_on_unit_sphere * (elavation + 1) * radius

func construct_mesh():
	var vertices: PackedVector3Array
	var triangles: PackedInt32Array
	
	for y in range(resolution):
		for x in range(resolution):
			var i = y * resolution + x
			var percent =  Vector2(x, y) / (resolution - 1)
			var point_on_unit_cube: Vector3 = local_up + (percent.x - 0.5) * 2 * axis_a + (percent.y - 0.5) * 2 * axis_b
			var point_on_unit_planet = point_on_unit_cube.normalized()
			point_on_unit_planet = calculate_point_on_planet(point_on_unit_planet)
			vertices.append(point_on_unit_planet)
			if x != resolution - 1 and y != resolution - 1:
				triangles.append_array([
					i,
					i + resolution + 1,
					i + resolution,
					i,
					i + 1,
					i + resolution + 1,
				])
			
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = triangles
	
	var st = SurfaceTool.new()
	st.clear()
	st.create_from_arrays(arrays,Mesh.PRIMITIVE_TRIANGLES)
	st.generate_normals()
	return st.commit()
