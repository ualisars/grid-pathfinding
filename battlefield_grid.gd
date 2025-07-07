extends Node

class_name BattlefieldGrid

var grid: Array
var grid_pair: Array[CellPair]
var cell_id: int = 1

var map_width: int
var map_height: int
var cell_width: int
var cell_height: int

var deployment_rows_number: int = 2

func _ready():
	init_grid(60, 60, 20, 20)
	
	init_grid_cell_pair()
	add_pair_neigbors()

func init_grid(
	map_width_: int, 
	map_height_: int, 
	cell_width_: int, 
	cell_height_: int
) -> void:
	map_width = map_width_
	map_height = map_height_
	cell_width = cell_width_
	cell_height = cell_height_
	
	for y in range(0, map_height, cell_height):
		var row = []
		
		for x in range(0, map_width, cell_width):
			var cell = GridCell.new()
			cell.init_cell(x, y, cell_id)
			row.append(cell)
			
			cell_id += 1
			
		grid.append(row)
		
	add_neighbors_to_cells()
			
func _exit_tree():
	if grid:
		for cell in grid:
			cell.queue_free()

func get_cells_amount_in_row() -> int:
	return map_width / cell_width
	
func get_total_row_amount() -> int:
	return map_height / cell_height
	
func get_attack_deployment_rows() -> Array:
	var cells = grid.slice(
		grid.size() - 1, 
		grid.size() - 1 - deployment_rows_number,
		-1
	)
	
	return cells
	
func get_defense_deployment_rows() -> Array:
	var cells = grid.slice(0, deployment_rows_number)
	
	return cells

func get_free_deployment_cells(
	side: BattleEnums.Side
) -> Array:
	var rows: Array
	
	if side == BattleEnums.Side.ATTACK:
		rows = get_attack_deployment_rows()
	else:
		rows = get_defense_deployment_rows()
		
	var free_cells = []
	
	var i = 0
	for row in rows:
		if i < row.size() - 1:
			if not row[i].occupied and not row[i + 1].occupied:
				free_cells.append(row[i])
				free_cells.append(row[i + 1])
				return free_cells
		else:
			i = 0
			continue
				
	return free_cells

func add_neighbors_to_cells() -> void:
	var rows = grid.size()
	var cols = grid[0].size()

	for y in range(rows):
		for x in range(cols):
			var cell = grid[y][x]
			var neighbors = []

			if y > 0:
				neighbors.append(grid[y - 1][x]) # Top
			if y < rows - 1:
				neighbors.append(grid[y + 1][x]) # Bottom
			if x > 0:
				neighbors.append(grid[y][x - 1]) # Left
			if x < cols - 1:
				neighbors.append(grid[y][x + 1]) # Right

			if y > 0 and x > 0:
				neighbors.append(grid[y - 1][x - 1]) # Top-left (NW)
			if y > 0 and x < cols - 1:
				neighbors.append(grid[y - 1][x + 1]) # Top-right (NE)
			if y < rows - 1 and x > 0:
				neighbors.append(grid[y + 1][x - 1]) # Bottom-left (SW)
			if y < rows - 1 and x < cols - 1:
				neighbors.append(grid[y + 1][x + 1]) # Bottom-right (SE)

			cell.neighbors = neighbors

func reconstruct_path(
	start_cell: GridCell, 
	target_cell: GridCell, 
	came_from: Dictionary
) -> Array:
	var current_cell = target_cell
	var path: Array = []
	var attempt = 0
	
	while true:
		path.append(current_cell)
		
		if current_cell == start_cell:
			path.reverse()
			return path
		
		if attempt > 50:
			return []
			
		var linked_cell = came_from[current_cell]
	
		current_cell = linked_cell
		attempt += 1
	
	return path
	

func reconstruct_pair_path(
	start_cell: CellPair, 
	target_cell: CellPair, 
	came_from: Dictionary
) -> Array:
	var current_cell = target_cell
	var path: Array = []
	var attempt = 0
	
	while true:
		path.append(current_cell)
		
		if current_cell == start_cell:
			path.reverse()
			return path
		
		if attempt > 50:
			return []
			
		var linked_cell = came_from[current_cell]
	
		current_cell = linked_cell
		attempt += 1
	
	return path
	
func print_path(
	start_cell: GridCell, 
	target_cell: GridCell, 
	came_from: Dictionary
) -> void:
	print("start finding path from cell: " + str(start_cell.x) + ", " + str(start_cell.y))
	print(" to cell: " + str(target_cell.x) + " " + str(target_cell.y))
	
	var path = reconstruct_path(start_cell, target_cell, came_from)
	
	print("path found")
	for cell in path:
		print("move to cell: " + "x: " + str(cell.x) + ", y: " + str(cell.y))
		
func print_pair_path(
	start_pair: CellPair, 
	target_pair: CellPair, 
	came_from: Dictionary
) -> void:
	print("start finding path from cell: " + start_pair.pair_name + ", ")
	print(" to cell: " + target_pair.pair_name)
	
	var path = reconstruct_pair_path(start_pair, target_pair, came_from)
	
	for pair in path:
		print("move to cell: " + pair.pair_name)
		
func init_grid_cell_pair():
	for row in grid:
		for cell in row:
			for neighbor in cell.neighbors:
				# cells ortagonal
				if cell.x == neighbor.x or cell.y == neighbor.y:
					if not is_grid_contain_pair([cell, neighbor]):
						var cell_pair = CellPair.new()
						cell_pair.init_cell_pair([cell, neighbor])
						
						grid_pair.append(cell_pair)
					
func is_grid_contain_pair(pair_to_add: Array[GridCell]) -> bool:
	for cell_pair in grid_pair:
		if pair_to_add[0] == cell_pair.pair[0] and pair_to_add[1] == cell_pair.pair[1]:
			return true
		elif pair_to_add[0] == cell_pair.pair[1] and pair_to_add[1] == cell_pair.pair[0]:
			return true
	return false
	
func is_cells_vertical(cells: Array[GridCell]) -> bool:
	if cells[0].x == cells[1].x:
		return true
	return false
	
func is_cells_horizontal(cells: Array[GridCell]) -> bool:
	if cells[0].y == cells[1].y:
		return true
	return false
	
func add_pair_neigbors():
	for pair in grid_pair:
		for other_pair in grid_pair:
			if pair == other_pair:
				continue
			if is_pairs_neigbors(pair, other_pair):
				pair.add_neighbor(other_pair)
			
func is_pairs_neigbors(pair1: CellPair, pair2: CellPair) -> bool:
	var pair1_x_sum = pair1.pair[0].x + pair1.pair[1].x
	var pair1_y_sum = pair1.pair[0].y + pair1.pair[1].y
	var pair2_x_sum = pair2.pair[0].x + pair2.pair[1].x
	var pair2_y_sum = pair2.pair[0].y + pair2.pair[1].y
	
	var dx = abs(pair1_x_sum - pair2_x_sum)
	var dy = abs(pair1_y_sum - pair2_y_sum)
	
	if is_cells_horizontal(pair1.pair):
		if dy == cell_height * 2 and dx == 0:
			return true
	elif is_cells_vertical(pair1.pair):
		if dx == cell_width * 2 and dy == 0:
			return true
	
	if pair1_x_sum == pair2_y_sum or pair1_y_sum == pair2_x_sum:
		return true
	if dx == cell_width and dy == cell_height:
		return true
	
	return false
