extends Node2D

var MAP_WIDTH = 800
var MAP_HEIGHT = 400
var CELL_WIDTH = 40
var CELL_HEIGHT = 40
var CELL_SIZE = 40

@onready var background = $Background
var BattleUnitCellPairClass = preload("res://battle/battle_unit_cell_pair.tscn")

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
	
	var attack_unit = BattleUnitCellPairClass.instantiate()
	var attack_pairs = battlefield_grid.get_attack_deployment_pairs()
	attack_unit.init(CELL_SIZE, attack_pairs[0], a_star, BattleEnums.Side.ATTACK)
	
	var defense_unit = BattleUnitCellPairClass.instantiate()
	var defense_pairs = battlefield_grid.get_defense_deployment_pairs()
	defense_unit.init(
		CELL_SIZE, 
		defense_pairs[10],
		a_star, 
		BattleEnums.Side.DEFENSE
	)
	
	BattleControllerCellPair.add_to_attack_units(attack_unit)
	BattleControllerCellPair.add_to_defense_units(defense_unit)
	
	add_child(attack_unit)
	add_child(defense_unit)
	
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
