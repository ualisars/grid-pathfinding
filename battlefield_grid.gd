extends Node

class_name BattlefieldGrid

var grid: Array
var cell_id: int = 1

var map_width: int
var map_height: int
var grid_width: int
var grid_height: int

var deployment_rows_number: int = 2

func _ready():
	init_grid(1000, 400, 20, 20)

func init_grid(
	map_width_: int, 
	map_height_: int, 
	grid_width_: int, 
	grid_height_: int
) -> void:
	map_width = map_width_
	map_height = map_height_
	grid_width = grid_width_
	grid_height = grid_height_
	
	for y in range(0, map_height, grid_height):
		var row = []
		
		for x in range(0, map_width, grid_width):
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
	return map_width / grid_width
	
func get_total_row_amount() -> int:
	return map_height / grid_height
	
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
