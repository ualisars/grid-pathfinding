extends Node2D

class_name BattleUnit

var unit_width: int
var unit_height: int

var side: BattleEnums.Side

var current_cell_pair: CellPair
var target_cell_pair: CellPair

var current_rotation: int = 0
var next_rotation: int = 0
var next_position: Vector2

var cell_width: int
var cell_height: int

var target_position: Vector2 = Vector2.INF
var current_path: Array
var current_path_index: int = 1
var SPEED = 30.0
var ROTATION_SPEED = SPEED * 3
var a_star: AStarTwoCells

@onready var unit_image = $UnitImage
@onready var color_rect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	unit_image.size.x = unit_width
	unit_image.size.y = unit_height
	color_rect.size.x = unit_width
	color_rect.size.y = unit_height
	
	if target_cell_pair:
		current_path = a_star.find_path(current_cell_pair, target_cell_pair)
		calc_next_pair_position(current_path[1])
	
func init(
	cell_size: int,
	start_pair: CellPair,
	a_star_: AStarTwoCells,
	side_: BattleEnums.Side
) -> void:
	cell_width = cell_size
	cell_height = cell_size
	unit_width = cell_size * 2
	unit_height = cell_size
	
	current_cell_pair = start_pair
	var left_cell = current_cell_pair.get_left_cell()
	position = left_cell.position_2d
	a_star = a_star_
	side = side_

func assign_target(target_pair: CellPair) -> void:
	target_cell_pair = target_pair
	

func calc_next_pair_position(next_cell_pair: CellPair) -> void:
	print("calc_next_pair_position")
	var current_pair_xsum = current_cell_pair.pair[0].x + current_cell_pair.pair[1].x
	var current_pair_ysum = current_cell_pair.pair[0].y + current_cell_pair.pair[1].y
	var next_pair_xsum = next_cell_pair.pair[0].x + next_cell_pair.pair[1].x
	var next_pair_ysum = next_cell_pair.pair[0].y + next_cell_pair.pair[1].y
	
	var dx = current_pair_xsum - next_pair_xsum
	var dy = current_pair_ysum - next_pair_ysum
	
	print("dx: ", str(dx))
	print("dy: ", str(dy))
	
	if current_cell_pair.is_cells_horizontal():
		# next cell is top left
		if dx == cell_width and dy == cell_height * 2:
			print("rotation: -90")
			next_rotation = -90
			var left_cell = current_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y + cell_height)
		# next cell is top right
		elif dx == cell_width and dy == 0:
			print("rotation: -90")
			next_rotation = -90
			var bottom_cell = next_cell_pair.get_bottom_cell()
			next_position = Vector2(bottom_cell.x, bottom_cell.y + cell_height)
		# next cell is bottom right
		elif dx == -cell_width and dy == cell_height:
			print("rotation: 90")
			next_rotation = 90
			var top_cell = next_cell_pair.get_top_cell()
			next_position = Vector2(top_cell.x + cell_width, top_cell.y)
		# next cell is bottom left
		elif dx == -cell_width and dy == -cell_height:
			print("rotation: 90")
			next_rotation = 90
			var right_cell = current_cell_pair.get_right_cell()
			next_position = Vector2(right_cell.x + cell_width, right_cell.y)
		else:
			print("rotation: 0")
			next_rotation = 0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
	
	elif current_cell_pair.is_cells_vertical():
		# next cell is top left
		if dx == cell_width and dy == cell_height:
			next_rotation = 0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
		# next cell is top right
		elif dx == -cell_width and dy == cell_height:
			next_rotation = 0
			var top_cell = current_cell_pair.get_top_cell()
			next_position = Vector2(top_cell.x, top_cell.y)
		# next cell is bottom left
		elif dx == cell_width and dy == -cell_height:
			next_rotation = 0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
		# next cell is bottom right
		elif dx == -cell_width and dy == -cell_height:
			next_rotation = 0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
		else:
			next_rotation = 90
			var top_cell = next_cell_pair.get_top_cell()
			next_position = Vector2(top_cell.x, top_cell.y)
			
func move_to_target_position(delta):
	make_rotation()
	
	if next_position != Vector2.INF:
		position += position.direction_to(
			next_position
		) * SPEED * delta
				
		if position.distance_to(next_position) <= SPEED * delta:
			current_cell_pair = current_path[current_path_index]
			position = next_position
			current_path_index += 1
			
			if current_path_index >= current_path.size():
				next_position == Vector2.INF
			else:
				calc_next_pair_position(current_path[current_path_index])

func make_rotation():
	if current_rotation == next_rotation:
		return
		
	var diff = 1
	
	if current_rotation > next_rotation:
		diff = -1

	current_rotation += diff
	rotation_degrees = current_rotation
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_to_target_position(delta)
