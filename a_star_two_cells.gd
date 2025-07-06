extends Node

class_name AStarTwoCells

var battlefield_grid: BattlefieldGrid
const MAX_VALUE = 1e20
var cell_width: int = 20
var cell_height: int = 20

func _ready():
	battlefield_grid = BattlefieldGrid.new()
	battlefield_grid.init_grid(100, 100, 20, 20)
	
	var start_cells = [
		battlefield_grid.grid[0][0],
		battlefield_grid.grid[0][1]
	]
	var target_cells = [
		battlefield_grid.grid[2][3],
		battlefield_grid.grid[3][3]
	]
	
	var came_from = find_path(start_cells, target_cells)
	
func find_path(
	start_cells: Array[GridCell], 
	target_cells: Array[GridCell]
):
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

func calc_heuristic(
	start_cells: Array[GridCell], 
	target_cells: Array[GridCell]
) -> float:
	var start_middle = calc_middle_point(start_cells)
	var target_middle = calc_middle_point(target_cells)
	
	var distance = abs(start_middle.x - target_middle.x) + abs(start_middle.y - target_middle.y)
	return distance
	
func calc_middle_point(cells: Array[GridCell]) -> Vector2:
	var x: int
	var y: int
	
	if is_cells_horizontal(cells):
		# x correspons to the left side of the cell
		# so second cells x is middle point
		x = cells[1].x
		y = cells[0].y  + (cell_height / 2)
	elif  is_cells_vertical(cells):
		x = cells[0].x + (cell_width / 2)
		y = cells[1].y
		
	return Vector2(x, y)

func is_cells_vertical(cells: Array[GridCell]) -> bool:
	if cells[0].x == cells[1].x:
		return true
	return false
	
func is_cells_horizontal(cells: Array[GridCell]) -> bool:
	if cells[0].y == cells[1].y:
		return true
	return false
