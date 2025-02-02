extends Node

class_name Player

# Called when the node enters the scene tree for the first time.
var submitted: bool
var state: String
var selectedUnit: String
var orders: Array
var income: int
var money: int
var memory: int
var is_upgrading_memory: bool
#var researchingUnit: String
var currentlySpending: int
var unitDeck: Dictionary

#enum {
	#INPUT_DISABLED,
	#SELECTING_UNIT,
	#UNLOCKING_UNIT,
	#ISSUING_ORDERS,
	#SUBMITTED_STANDBY, 	
#}

func _init(): #(selectedUnits: Dictionary)
	self.submitted = false
	self.state = "SELECTING_UNIT"
	self.selectedUnit = ""
	self.orders = []
	self.income = 1
	self.money = 10
	self.memory = 5
	self.is_upgrading_memory = false
	#self.researchingUnit = ""
	self.currentlySpending = 0
	self.unitDeck = {
		"1": "Worker",
		"2": "Soldier", 
		"3": "Archer", 
		"4": "Mage", 
		"5": "Spy",
		"6": "Builder", 
		}

func reset_values():
	self.submitted = false
	self.state = "SELECTING_UNIT"
	self.selectedUnit = ""
	self.orders = []
	self.is_upgrading_memory = false
	#self.researchingUnit = ""
	self.currentlySpending = 0
