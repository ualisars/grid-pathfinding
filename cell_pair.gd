extends Node

class_name CellPair

var pair: Array[GridCell]
var neighbors: Array[CellPair]
var pair_name: String
var cell_size = 40

func init_cell_pair(pair_: Array[GridCell]) -> void:
	pair = pair_
	pair_name = "[x: " + str(pair[0].x) + " y: " + str(pair[0].y)
	pair_name += ", x: " + str(pair[1].x) + " y: " + str(pair[1].y)  + " ]"
	
func add_neighbor(neighbor: CellPair) -> void:
	if not is_neighbors_contain_pair(neighbor):
		neighbors.append(neighbor)
	
func is_neighbors_contain_pair(pair_to_add: CellPair) -> bool:
	for cell_pair in neighbors:
		if pair_to_add.pair[0] == cell_pair.pair[0] and pair_to_add.pair[1] == cell_pair.pair[1]:
			return true
		elif pair_to_add.pair[0] == cell_pair.pair[1] and pair_to_add.pair[1] == cell_pair.pair[0]:
			return true
	return false
	
func is_cells_vertical() -> bool:
	if pair[0].x == pair[1].x:
		return true
	return false
	
func is_cells_horizontal() -> bool:
	if pair[0].y == pair[1].y:
		return true
	return false

func get_left_cell() -> GridCell:
	if pair[0].x < pair[1].x:
		return pair[0]
	return pair[1]
	
func get_right_cell() -> GridCell:
	if pair[0].x > pair[1].x:
		return pair[0]
	return pair[1]
	
func get_bottom_cell() -> GridCell:
	if pair[0].y > pair[1].y:
		return pair[0]
	return pair[1]
	
func get_top_cell() -> GridCell:
	if pair[0].y < pair[1].y:
		return pair[0]
	return pair[1]
	
func calc_middle_point() -> Vector2:
	var x: int
	var y: int
	
	if is_cells_horizontal():
		# x correspons to the left side of the cell
		# so second cells x is middle point
		x = pair[1].x
		y = pair[0].y + (cell_size / 2)
	elif  is_cells_vertical():
		x = pair[0].x + (cell_size / 2)
		y = pair[1].y
		
	return Vector2(x, y)
