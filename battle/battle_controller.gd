extends Node

var attack_units: Array[BattleUnit] = []
var defense_units: Array[BattleUnit] = []

func add_to_attack_units(unit: BattleUnit) -> void:
	attack_units.append(unit)

func add_to_defense_units(unit: BattleUnit) -> void:
	defense_units.append(unit)
	
func get_enemy_units(side: BattleEnums.Side) -> Array[BattleUnit]:
	if side == BattleEnums.Side.ATTACK:
		return defense_units
	return attack_units
