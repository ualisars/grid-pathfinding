extends Node

class_name Dijkstra

var battlefield_grid: BattlefieldGrid
var MAX_VALUE = 1000

func _ready():
	battlefield_grid = BattlefieldGrid.new()
	battlefield_grid.init_grid(100, 100, 20, 20)
	
	var start_cell = battlefield_grid.grid[0][0]
	var target_cell = battlefield_grid.grid[2][3]
	
	var came_from = find_path(start_cell)
	
	battlefield_grid.print_path(start_cell, target_cell, came_from)

func find_path(start_cell: GridCell):
	var distance: Dictionary = {}
	var queue: Array = []
	var came_from: Dictionary = {}
	
	for row in battlefield_grid.grid:
		for cell in row:
			distance[cell] = MAX_VALUE
		
	distance[start_cell] = 0
	came_from[start_cell] = null
	
	add_to_queue(start_cell, distance[start_cell], queue)
		
	while queue.size() > 0:
		var current_cell = queue.pop_front()
		
		for neighbor in current_cell["cell"].neighbors:
			var current_distance = current_cell["cell"].position_2d.distance_to(
				neighbor.position_2d
			)
			
			if current_cell["distance"] + current_distance < distance[neighbor]:
				distance[neighbor] = current_cell["distance"] + current_distance
				came_from[neighbor] = current_cell["cell"]
				add_to_queue(neighbor, distance[neighbor], queue)
				
	return came_from

func add_to_queue(cell: GridCell, distance: int, queue: Array) -> void:
	queue.append({"cell": cell, "distance": distance})
	queue.sort_custom(func(a, b): return a["distance"] < b["distance"])
