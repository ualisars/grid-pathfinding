extends Node

class_name GridCell

var x: int
var y: int
var id: int
var occupied: bool = false
var position_2d: Vector2
var neighbors: Array

func init_cell(
	x_: int,
	y_: int,
	id_: int,
) -> void:
	x = x_
	y = y_
	id = id_
	position_2d = Vector2(x, y)

func occupy_cell() -> void:
	occupied = true

func unoccupy_cell() -> void:
	occupied = false

func add_neighbor(neighbor: GridCell) -> void:
	neighbors.append(neighbor)
