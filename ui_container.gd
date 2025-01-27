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
@onready var submitted_label_2: Label = $SubmittedLabel2
@onready var state_label_2: Label = $StateLabel2
@onready var selected_unit_label_2: Label = $SelectedUnitLabel2
@onready var orders_label_2: Label = $OrdersLabel2
@onready var money_label_2: Label = $MoneyLabel2
@onready var income_label_2: Label = $IncomeLabel2
@onready var memory_label_2: Label = $MemoryLabel2
@onready var is_upgrading_memory_label_2: Label = $IsUpgradingMemoryLabel2
@onready var currently_spending_label_2: Label = $CurrentlySpendingLabel2


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
	
	var player2 = input_handler.players[1]  # Accessing the first player as an example
	submitted_label_2.text = "Submitted: %s" % player2.submitted
	state_label_2.text = "State: %s" % player2.state
	selected_unit_label_2.text = "Selected Unit: %s " % player2.selectedUnit
	orders_label_2.text = "Orders: %s" % str(player2.orders)
	money_label_2.text = "Money: %d" % player2.money
	income_label_2.text = "Income: %d" % player2.income
	memory_label_2.text = "Memory: %d" % player2.memory
	is_upgrading_memory_label_2.text = "Is Upgrading: %s" % player2.is_upgrading_memory
	currently_spending_label_2.text = "Currently Spending: %s" % player2.currentlySpending
	
