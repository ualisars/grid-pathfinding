extends Node

class_name AStarBattleGrid

var battlefield_grid: BattlefieldGrid
const MAX_VALUE = 1e20

func _ready():
	battlefield_grid = BattlefieldGrid.new()
	battlefield_grid.init_grid(100, 100, 20, 20)
	
	var start_cell = battlefield_grid.grid[0][0]
	var target_cell = battlefield_grid.grid[2][3]
	
	var came_from = find_path(start_cell, target_cell)
	
	battlefield_grid.print_path(start_cell, target_cell, came_from)
	
func find_path(start_cell: GridCell, target_cell: GridCell):
	var open_list: Array = []
	var closed_list: Array = []
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}
	var f_score: Dictionary = {}
	
	add_to_open_list(
		start_cell, 
		calc_heuristic(start_cell, target_cell), 
		open_list
	)
	
	for row in battlefield_grid.grid:
		for cell in row:
			g_score[cell] = MAX_VALUE
			
	for row in battlefield_grid.grid:
		for cell in row:
			f_score[cell] = MAX_VALUE
			
	g_score[start_cell] = 0
	f_score[target_cell] = calc_heuristic(start_cell, target_cell)
	
	came_from[start_cell] = null
	
	while open_list.size() > 0:
		var cell_to_distance = open_list.pop_front()
		var current_cell = cell_to_distance["cell"]
		
		if current_cell == target_cell:
			return came_from
			
		closed_list.append(current_cell)
			
		for neighbor in current_cell.neighbors:
			if neighbor in closed_list:
				continue
			
			var current_distance = current_cell.position_2d.distance_to(
				neighbor.position_2d
			)
			var tentative_gscore = g_score[current_cell] + current_distance
			
			if tentative_gscore < g_score[neighbor]:
				came_from[neighbor] = current_cell
				g_score[neighbor] = tentative_gscore
				f_score[neighbor] = tentative_gscore + calc_heuristic(neighbor, target_cell)
				
				if not is_in_open_list(neighbor, open_list):
					add_to_open_list(neighbor, f_score[neighbor], open_list)
					

func add_to_open_list(cell: GridCell, distance: int, open_list: Array) -> void:
	open_list.append({"cell": cell, "distance": distance})
	open_list.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
func is_in_open_list(cell: GridCell, open_list: Array) -> bool:
	for cell_to_distance in open_list:
		if cell_to_distance["cell"] == cell:
			return true
			
	return false

func calc_heuristic(start_cell: GridCell, target_cell: GridCell) -> float:
	var distance = abs(start_cell.x - target_cell.x) + abs(start_cell.y - target_cell.y)
	return distance
