extends Node2D

class_name BattleUnitCellPair

var unit_width: int
var unit_height: int

var side: BattleEnums.Side

var current_cell_pair: CellPair
var target_cell_pair: CellPair

var current_rotation: int = 0.0
var next_rotation: int = 0.0
var next_position: Vector2

var cell_width: int
var cell_height: int

var target_position: Vector2 = Vector2.INF
var current_path: Array
var current_path_index: int = 1
var SPEED = 20.0
var rotation_speed = 20.0
var a_star: AStarTwoCells
var enemy: BattleUnitCellPair

var last_enemy_pair: CellPair

@onready var unit_image = $UnitImage
@onready var color_rect = $ColorRect


func _ready():
	unit_image.size.x = unit_width
	unit_image.size.y = unit_height
	color_rect.size.x = unit_width
	color_rect.size.y = unit_height
	
	if side == BattleEnums.Side.ATTACK:
		color_rect.color = Color.DARK_VIOLET
	else:
		color_rect.color = Color.DARK_GREEN
	
	calc_path()
	
	if side == BattleEnums.Side.DEFENSE:
		set_process(false)
	
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

func calc_path() -> void:
	enemy = get_closest_enemy()
	
	current_path = a_star.find_path(
		current_cell_pair,
		enemy.current_cell_pair
	)
	current_path_index = 1
	target_position = enemy.current_cell_pair.calc_middle_point()
	calc_next_pair_position(current_path[0])
	set_rotation_speed()
	
	print("next position")
	print(next_position)
	print("next rotation")
	print(next_rotation)

func calc_next_pair_position(next_cell_pair: CellPair) -> void:
	var current_pair_xsum = current_cell_pair.pair[0].x + current_cell_pair.pair[1].x
	var current_pair_ysum = current_cell_pair.pair[0].y + current_cell_pair.pair[1].y
	var next_pair_xsum = next_cell_pair.pair[0].x + next_cell_pair.pair[1].x
	var next_pair_ysum = next_cell_pair.pair[0].y + next_cell_pair.pair[1].y
	
	var dx = current_pair_xsum - next_pair_xsum
	var dy = current_pair_ysum - next_pair_ysum
	
	if current_cell_pair.is_cells_horizontal():
		# next cell is top left
		if dx == cell_width and dy == cell_height * 2:
			next_rotation = -90.0
			var left_cell = current_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y + cell_height)
		# next cell is top right
		elif dx == cell_width and dy == 0:
			next_rotation = -90.0
			var bottom_cell = next_cell_pair.get_bottom_cell()
			next_position = Vector2(bottom_cell.x, bottom_cell.y + cell_height)
		# next cell is bottom right
		elif dx == -cell_width and dy == cell_height:
			next_rotation = 90.0
			var top_cell = next_cell_pair.get_top_cell()
			next_position = Vector2(top_cell.x + cell_width, top_cell.y)
		# next cell is bottom left
		elif dx == -cell_width and dy == -cell_height:
			next_rotation = 90.0
			var right_cell = current_cell_pair.get_right_cell()
			next_position = Vector2(right_cell.x + cell_width, right_cell.y)
		else:
			next_rotation = 0.0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
	
	elif current_cell_pair.is_cells_vertical():
		# next cell is top left
		if dx == cell_width and dy == cell_height:
			next_rotation = 0.0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
		# next cell is top right
		elif dx == -cell_width and dy == cell_height:
			next_rotation = 0.0
			var top_cell = current_cell_pair.get_top_cell()
			next_position = Vector2(top_cell.x, top_cell.y)
		# next cell is bottom left
		elif dx == cell_width and dy == -cell_height:
			next_rotation = 0.0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
		# next cell is bottom right
		elif dx == -cell_width and dy == -cell_height:
			next_rotation = 0.0
			var left_cell = next_cell_pair.get_left_cell()
			next_position = Vector2(left_cell.x, left_cell.y)
		else:
			next_rotation = 90.0
			var top_cell = next_cell_pair.get_top_cell()
			next_position = Vector2(top_cell.x, top_cell.y)
			
func move_to_target_position(delta):
	if is_enemy_close():
		print("enemy close")
	if need_to_recalculate_path():
		print("recalculate path")
		calc_path()
		return
	
	if next_position != Vector2.INF:
		position += position.direction_to(
			next_position
		) * SPEED * delta
		
		make_rotation(delta)
				
		if position.distance_to(next_position) <= SPEED * delta:
			current_cell_pair = current_path[current_path_index]
			print("position")
			print(position)
			
			print("rotation")
			print(rotation_degrees)
			
			position = next_position
			rotation_degrees = next_rotation
			print("rotation after")
			print(rotation_degrees)
			current_rotation = next_rotation
			
			current_path_index += 1
			
			if current_path_index >= current_path.size():
				next_position == Vector2.INF
			else:
				calc_next_pair_position(current_path[current_path_index])
				
				print("next position")
				print(next_position)
				print("next rotation")
				print(next_rotation)
				
				set_rotation_speed()
				
				

func make_rotation(delta):
	if current_rotation == next_rotation:
		return
	
	var diff = 1.0
	
	if current_rotation < next_rotation:
		diff = -1.0

	rotation_degrees += diff * rotation_speed * delta

func _process(delta):
	move_to_target_position(delta)
	
func get_closest_enemy() -> BattleUnitCellPair:
	var closest_enemy: BattleUnitCellPair
	var min_distance: float = INF
	
	var enemy_units = BattleControllerCellPair.get_enemy_units(side)
	
	for enemy in enemy_units:
		if position.distance_to(enemy.position) < min_distance:
			min_distance = position.distance_to(enemy.position)
			closest_enemy = enemy
	
	return closest_enemy
	
func need_to_recalculate_path() -> bool:
	var max_distance = cell_width * 3
	var enemy_pair = enemy.current_cell_pair
	var enemy_middle = enemy_pair.calc_middle_point()
	
	# enemy significally changed their location
	if target_position.distance_to(enemy_middle) > max_distance:
		return true
	return false
	
func is_enemy_close() -> bool:
	for neighbor in current_cell_pair.neighbors:
		for enemy in BattleControllerCellPair.get_enemy_units(side):
			if enemy.current_cell_pair == neighbor:
				return true
	return false
	
func set_rotation_speed() -> void:
	var center = current_cell_pair.calc_middle_point()
	var distance = center.distance_to(next_position)
	
	if distance > cell_width * 1.5:
		rotation_speed = SPEED * 2
	else:
		rotation_speed = SPEED
