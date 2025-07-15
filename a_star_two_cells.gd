extends Node

class_name AStarTwoCells

var battlefield_grid: BattlefieldGrid
const MAX_VALUE = 1e20

func _ready():
	battlefield_grid = BattlefieldGrid.new()
	battlefield_grid.init_grid(100, 100, 20, 20)
	
	battlefield_grid.init_grid_cell_pair()
	battlefield_grid.add_pair_neigbors()
	
	var start_pair = battlefield_grid.grid_pair[10]
	var target_pair = battlefield_grid.grid_pair[30]
	
	var came_from = find_path(start_pair, target_pair)
	
	battlefield_grid.print_pair_path(
		start_pair,
		target_pair,
		came_from
	)

func init_pathfinding(battlefield_grid_: BattlefieldGrid) -> void:
	battlefield_grid = battlefield_grid_
	
func find_path(start_pair: CellPair, target_pair: CellPair) -> Array[CellPair]:
	var open_list: Array = []
	var closed_list: Array = []
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}
	var f_score: Dictionary = {}
	
	add_to_open_list(
		start_pair, 
		calc_heuristic(start_pair, target_pair), 
		open_list
	)
	
	for cell_pair in battlefield_grid.grid_pair:
		g_score[cell_pair] = MAX_VALUE
	
	for cell_pair in battlefield_grid.grid_pair:
		f_score[cell_pair] = MAX_VALUE
	
	g_score[start_pair] = 0
	f_score[target_pair] = calc_heuristic(start_pair, target_pair)
	
	came_from[start_pair] = null
	
	while open_list.size() > 0:
		var cell_to_distance = open_list.pop_front()
		var current_pair = cell_to_distance["pair"]
		
		if current_pair == target_pair:
			return battlefield_grid.reconstruct_pair_path(
				start_pair,
				target_pair,
				came_from
			)
			
		closed_list.append(current_pair)
			
		for neighbor in current_pair.neighbors:
			if neighbor in closed_list:
				continue
			
			var current_distance = calc_pairs_distance(current_pair, neighbor)
			
			var tentative_gscore = g_score[current_pair] + current_distance
			
			if tentative_gscore < g_score[neighbor]:
				came_from[neighbor] = current_pair
				g_score[neighbor] = tentative_gscore
				f_score[neighbor] = tentative_gscore + calc_heuristic(neighbor, target_pair)
				
				if not is_in_open_list(neighbor, open_list):
					add_to_open_list(neighbor, f_score[neighbor], open_list)
					
	return []

func add_to_open_list(cell_pair: CellPair, distance: int, open_list: Array) -> void:
	open_list.append({"pair": cell_pair, "distance": distance})
	open_list.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
func is_in_open_list(cell_pair: CellPair, open_list: Array) -> bool:
	for cell_to_distance in open_list:
		if cell_to_distance["pair"] == cell_pair:
			return true
			
	return false

func calc_pairs_distance(current_pair: CellPair, target_pair: CellPair) -> float:
	var current_middle_point = calc_middle_point(current_pair)
	var target_middle_point = calc_middle_point(target_pair)
	
	var distance = current_middle_point.distance_to(
		target_middle_point
	)
	
	var is_rotation_needed = check_rotation_needed(current_pair, target_pair)

	# manually increase distance if rotation needed
	if is_rotation_needed:
		distance *= 1.1
		
	return distance
	
func check_rotation_needed(current_pair: CellPair, target_pair: CellPair) -> bool:
	var is_rotation_needed: bool = false
	var is_current_pair_horizontal = is_cells_horizontal(current_pair.pair)
	var is_current_pair_vertical = is_cells_vertical(current_pair.pair)
	var is_target_pair_horizontal = is_cells_horizontal(target_pair.pair)
	var is_target_pair_vertical = is_cells_vertical(target_pair.pair)
	
	if is_current_pair_horizontal and is_target_pair_vertical:
		is_rotation_needed = true
	elif is_current_pair_vertical and is_target_pair_horizontal:
		is_rotation_needed = true
	
	return is_rotation_needed

func calc_heuristic(
	start_cells: CellPair, 
	target_cells: CellPair
) -> float:
	var start_middle = calc_middle_point(start_cells)
	var target_middle = calc_middle_point(target_cells)
	
	var distance = abs(start_middle.x - target_middle.x) + abs(start_middle.y - target_middle.y)
	return distance
	
func calc_middle_point(cell_pair: CellPair) -> Vector2:
	var x: int
	var y: int
	
	if is_cells_horizontal(cell_pair.pair):
		# x correspons to the left side of the cell
		# so second cells x is middle point
		x = cell_pair.pair[1].x
		y = cell_pair.pair[0].y + (battlefield_grid.cell_height / 2)
	elif  is_cells_vertical(cell_pair.pair):
		x = cell_pair.pair[0].x + (battlefield_grid.cell_width / 2)
		y = cell_pair.pair[1].y
		
	return Vector2(x, y)

func is_cells_vertical(cells: Array[GridCell]) -> bool:
	if cells[0].x == cells[1].x:
		return true
	return false
	
func is_cells_horizontal(cells: Array[GridCell]) -> bool:
	if cells[0].y == cells[1].y:
		return true
	return false
