extends Node

class_name Player
# Called when the node enters the scene tree for the first time.
@export var submitted: bool
@export var unitType: String
@export var orders: Array
@export var income: int
@export var money: int
@export var memory: int
@export var upgradeTier: int
@export var is_upgrading: bool
@export var unitDeck: Dictionary

func _init(unitDeck):
	self.submitted = false
	self.unitType = ""
	self.orders = []
	self.income = 1
	self.money = 1
	self.memory = 1
	self.upgradeTier = 0
	self.is_upgrading = false
	self.selectedUnits = {
		"N": "Unit 1",
		"E": "Unit 2", 
		"S": "Unit 3", 
		"W": "Unit 4", 
		"N2": "Unit 5",
		"E2": "Unit 6", 
		"S2": "Unit 7", 
		"W2": "Unit 8"}
