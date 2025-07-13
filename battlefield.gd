extends Node2D

var MAP_WIDTH = 800
var MAP_HEIGHT = 400
var CELL_WIDTH = 40
var CELL_HEIGHT = 40

@onready var background = $Background
var BattleUnit = preload("res://battle/battle_unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	init_grid_map()
	
	var battlefield_grid = BattlefieldGrid.new()
	battlefield_grid.init_grid(
		MAP_WIDTH, 
		MAP_HEIGHT, 
		CELL_WIDTH, 
		CELL_HEIGHT
	)
	
	battlefield_grid.init_grid_cell_pair()
	battlefield_grid.add_pair_neigbors()
	
	var a_star = AStarTwoCells.new()
	a_star.init_pathfinding(battlefield_grid)
	
	var battle_unit = BattleUnit.instantiate()
	var start_pairs = battlefield_grid.get_defense_deployment_pairs()
	battle_unit.init(CELL_WIDTH, start_pairs[0], a_star)
	
	var target_pairs = battlefield_grid.get_attack_deployment_pairs()
	var target_pair = target_pairs[10]
	#var enemy = BattleUnit.instantiate()
	#enemy.init(CELL_WIDTH, target_pair, a_star)
	
	battle_unit.assign_target(target_pair)
	
	var path = a_star.find_path( start_pairs[0], target_pair)
	draw_path(path)
	add_child(battle_unit)
	#add_child(enemy)
	
func draw_path_rect(pair: CellPair) -> void:
	var color_rect = ColorRect.new()
	color_rect.color = Color.CHARTREUSE
	color_rect.size.x = 5
	color_rect.size.y = 5
	color_rect.position = pair.calc_middle_point()
	
	add_child(color_rect)
	
func draw_path(path: Array[CellPair]):
	for pair in path:
		draw_path_rect(pair)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func init_grid_map():
	background.size.x = MAP_WIDTH
	background.size.y = MAP_WIDTH
	
func draw_cells():
	pass
