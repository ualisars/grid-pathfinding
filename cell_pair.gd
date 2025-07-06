extends Node

class_name CellPair

var pair: Array[GridCell]
var neighbors: Array[CellPair]
var pair_name: String

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
