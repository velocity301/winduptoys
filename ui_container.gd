#UI Container
extends Control
@onready var ui_container: Control = $"."

@onready var input_handler: Node2D = $"../InputHandler"
@onready var submitted_label: Label = $SubmittedLabel
@onready var state_label: Label = $StateLabel
@onready var selected_unit_label: Label = $SelectedUnitLabel
@onready var orders_label: Label = $OrdersLabel
@onready var money_label: Label = $MoneyLabel
@onready var income_label: Label = $IncomeLabel
@onready var memory_label: Label = $MemoryLabel
@onready var is_upgrading_memory_label: Label = $IsUpgradingMemoryLabel
@onready var currently_spending_label: Label = $CurrentlySpendingLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()# Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_ui()

func update_ui():
	# Access the players array from the InputHandler node
	var player = input_handler.players[0]  # Accessing the first player as an example
	submitted_label.text = "Submitted: %s" % player.submitted
	state_label.text = "State: %s" % player.state
	selected_unit_label.text = "Selected Unit: %s " % player.selectedUnit
	orders_label.text = "Orders: %s" % str(player.orders)
	money_label.text = "Money: %d" % player.money
	income_label.text = "Income: %d" % player.income
	memory_label.text = "Memory: %d" % player.memory
	is_upgrading_memory_label.text = "Is Upgrading: %s" % player.is_upgrading_memory
	currently_spending_label.text = "Currently Spending: %s" % player.currentlySpending
	
