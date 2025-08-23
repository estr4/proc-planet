class_name TerrainFace extends Resource

var resolution: int
var localUp: Vector3
var axisA: Vector3
var axisB: Vector3

func _init(r: int, l: Vector3) -> void:
	resolution = r
	localUp = l
	
	axisA = Vector3(localUp.y, localUp.z, localUp.x)
	axisB = axisA.cross(localUp)

func ConstructMesh():
	var vertices: PackedVector3Array
	var triangles: PackedInt32Array
	
	for y in range(resolution):
		for x in range(resolution):
			var i = y * resolution + x
			var percent =  Vector2(x, y) / (resolution - 1)
			var pointOnUnitCube: Vector3 = localUp + (percent.x - 0.5) * 2 * axisA + (percent.y - 0.5) * 2 * axisB
			var pointOnUnitSphere = pointOnUnitCube.normalized()
			vertices.append(pointOnUnitSphere)
			
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
