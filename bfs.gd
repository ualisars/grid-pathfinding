extends Node

class_name BFS

var grid: BattlefieldGrid
var grid_width: int
var grid_height: int

func _ready():
	var battlefield_grid = BattlefieldGrid.new()
	battlefield_grid.init_grid(100, 100, 20, 20)
	
	var start_cell = battlefield_grid.grid[0][0]
	var target_cell = battlefield_grid.grid[2][3]
	
	var came_from = find_path(start_cell)
	battlefield_grid.print_path(start_cell, target_cell, came_from)

func find_path(start_cell: GridCell):
	var visited: Dictionary = {}
	var queue: Array = []
	var came_from: Dictionary = {}
	
	visited[start_cell] = true
	came_from[start_cell] = null
	queue.append(start_cell)
	
	while queue.size() > 0:
		var current_cell: GridCell = queue.pop_front()
		
		for neighbor in current_cell.neighbors:
			if not visited.has(neighbor):
				visited[neighbor] = true
				came_from[neighbor] = current_cell
				queue.append(neighbor)
				
	return came_from
