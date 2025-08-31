@tool
class_name TerrainFace extends MeshInstance3D

var local_up: Vector3
var axis_a: Vector3
var axis_b: Vector3
var shape_settings: ShapeSettings

@warning_ignore("shadowed_variable") # dumbest warning ever award
func _init(local_up: Vector3, shape_settings) -> void:
	self.local_up = local_up
	self.shape_settings = shape_settings
	
	axis_a = Vector3(local_up.y, local_up.z, local_up.x)
	axis_b = axis_a.cross(local_up)

func construct_mesh(resolution: int) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for y in range(resolution):
		for x in range(resolution):
			var i = y * resolution + x
			var percent =  Vector2(x, y) / (resolution - 1)
			var point_on_unit_cube: Vector3 = local_up + (percent.x - 0.5) * 2 * axis_a + (percent.y - 0.5) * 2 * axis_b
			var point_on_unit_sphere := point_on_unit_cube.normalized()
			var point_on_planet := shape_settings.calc_point_on_planet(point_on_unit_sphere)
			st.add_vertex(point_on_planet)
			if x != resolution - 1 and y != resolution - 1:
				st.add_index(i)
				st.add_index(i + resolution + 1)
				st.add_index(i + resolution)
				st.add_index(i)
				st.add_index(i + 1)
				st.add_index(i + resolution + 1)
				
	st.generate_normals()
	set_mesh(st.commit())
