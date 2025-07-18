extends Node

var attack_units: Array[BattleUnitCellPair] = []
var defense_units: Array[BattleUnitCellPair] = []

func add_to_attack_units(unit: BattleUnitCellPair) -> void:
	attack_units.append(unit)

func add_to_defense_units(unit: BattleUnitCellPair) -> void:
	defense_units.append(unit)
	
func get_enemy_units(side: BattleEnums.Side) -> Array[BattleUnitCellPair]:
	if side == BattleEnums.Side.ATTACK:
		return defense_units
	return attack_units
