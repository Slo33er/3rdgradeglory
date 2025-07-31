extends Control

var players_ready = 0
var maybe_players = []  # Players who gave an excuse
var current_maybe_player = ""  # The one we're trying to guilt-trip
var player_excuses = {}
var player_buttons = {}
# Random excuses list
var excuses = [
	"Still hungover from last night 🍻",
	"Has a wedding... again.",
	"Babysitting the neighbour's python",
	"Camping with the in-laws",
	"Got man flu",
	"Left his whites at the pub",
	"Fishing trip he 'can’t miss'",
	"Missus booked a winery tour",
	"Too sore from darts night",
	"Got roped into mowing someone's lawn",
	"Volunteered to run a Bunnings BBQ"
]

# List of backup players with a % chance of saying yes
var backup_players = [
	{"name": "Barry", "chance": 70},
	{"name": "Steve", "chance": 50},
	{"name": "Craig", "chance": 30},
	{"name": "Greg", "chance": 80},
	{"name": "Gaz", "chance": 60}
]

# Only 2 backup calls allowed
var calls_remaining = 2

func _ready():
	randomize()
	$MateWeNeedYouButton.visible = false  # Make sure it starts hidden
	$CallsRemainingLabel.text = "Calls Left: %d / 2" % calls_remaining
	$CallBackupButton.disabled = false
	excuses.shuffle()
	
	# List of player names to check
	var player_names = [
		"Beefa", "Dallas", "Tez", "Singh", "Mooney", "Jacko",
		"Burger", "Lizard", "Jedd", "Cricket Head", "AJ"
	]
	
	for name in player_names:
		var btn = Button.new()
		btn.text = name
		btn.name = name
		btn.pressed.connect(func():
			handle_player(name)
			btn.disabled = true
	)
	
	#Disavale imedialty if we've already visited club room
		if GameState.called_players.has(name):
			btn.disabled = true
		
		$VBoxContainer.add_child(btn)
		player_buttons[name] = btn #save referece
		
	#Initialise Label
	$PlayerCounterLabel.text = "Players Ready: %d / 11" % players_ready
	$CallsRemainingLabel.text = "Calls Left: %d / 2" % calls_remaining
# Main player button pressed
func handle_player(player_name: String) -> void:
	if GameState.called_players.has(player_name):
		return # Dont process a player twice
	var excuse_message = ""
	
	#30% chance a player gives an excuse
	var roll = randi() %100
	if roll < 1:
		var excuse = excuses[randi() % excuses.size()]
		excuse_message = "%s can't play: %s" %[player_name, excuse]
		add_excuse(player_name)
	else:
		excuse_message = "%s is available and ready!" % player_name
		add_player_to_team(player_name)
		
	print(excuse_message)
	$WarningLabel.text = excuse_message
	

	# Disable button and mark as called
	#for button in $VBoxContainer.get_children():
		#if button.name == player_name and not button.disabled:
		#	button.text = player_name + " (Called)"
		#	button.disabled = true

# Adds excuse players to the maybe list and shows the guilt-trip button
func add_excuse(player_name: String) -> void:
	if maybe_players.has(player_name):
		return

	maybe_players.append(player_name)

	# Pick a random excuse
	var excuse = excuses[randi() % excuses.size()]
	var excuse_message = "%s can't play: %s" % [player_name, excuse]
	player_excuses[player_name] = excuse_message
	$WarningLabel.text = excuse_message  # Show it immediately
	# Create the button dynamically
	#var btn = Button.new()
	#btn.name = player_name
	#btn.text = player_name 
	#btn.pressed.connect(func():
	current_maybe_player = player_name
	#$WarningLabel.text = "Call %s and guilt them into playing?" % player_name
	$MateWeNeedYouButton.visible = true
	#btn.disabled = true  # disable once clicked
	
	#$VBoxContainer.add_child(btn)

# When "Mate, We Need You" button is pressed
func _on_MateWeNeedYouButton_pressed() -> void:
	$WarningLabel.text = "Calling %s... guilt-tripping in progress..." % current_maybe_player
	await get_tree().create_timer(1).timeout  # optional pause for drama

	$MateWeNeedYouButton.visible = false

	var roll = randi() % 100
	if roll < 50:
		$WarningLabel.text = "%s has been guilt-tripped into playing!" % current_maybe_player
		add_player_to_team(current_maybe_player)
	else:
		$WarningLabel.text = "%s still won't budge. Time to call a backup..." % current_maybe_player

# Adds player to team and updates lineup
func add_player_to_team(player_name: String) -> void:
	if GameState.players_ready_list.has(player_name):
		return #Prevents Duplicates
		
	GameState.players_ready_list.append(player_name)
	# Add label to lineup
	var name_label = Label.new()
	name_label.text = player_name + " (In)"
	$LineupContainer.add_child(name_label)

	# Increase ready count
	players_ready += 1
	$PlayerCounterLabel.text = "Players Ready: %d / 11" % players_ready

	# Show match button if enough players
	if players_ready >= 9:
		$StartMatchButton.visible = true

	if players_ready < 11:
		$WarningLabel.text = "You're short a few players — hope the captain can bowl!"
	else:
		$WarningLabel.text = ""  # Clear warning

# When "Call a Backup" button is pressed
func _on_call_backup_button_pressed():
	call_backup_player()

# Random chance to add a backup player
func call_backup_player() -> void:
	
	if calls_remaining <= 0:
		$WarningLabel.text = "No calls left! You're on your own, mate!"
		$CallBackupButton.disabled = true #Disable the button
		return

	if backup_players.size() == 0:
		$WarningLabel.text = "You've run out of people to call!"
		return
	
	# Pick a random backup
	var chosen_index = randi() % backup_players.size()
	var player = backup_players[chosen_index]

	var roll = randi() % 100
	if roll < player["chance"]:
		var banter = [
			"%s said yes! Legend!",
			"%s's missus gave them the green light!",
			"%s was halfway through a snag but they're in!",
			"%s just woke up but they're keen!",
			"%s's mum said no... then changed her mind!"
		]
		var msg = banter[randi() % banter.size()] % player["name"]
		$WarningLabel.text = msg

		# Add to lineup
		var name_label = Label.new()
		name_label.text = player["name"] + " (Backup)"
		$LineupContainer.add_child(name_label)
		
		#Add backup team tracking
		if not GameState.players_ready_list.has(player["name"]):
			GameState.players_ready_list.append(player["name"])
		players_ready += 1
		$PlayerCounterLabel.text = "Players Ready: %d / 11" % players_ready

		if players_ready >= 9:
			$StartMatchButton.visible = true

		if players_ready < 11:
			$WarningLabel.text += "\nStill a few short..."
	else:
		$WarningLabel.text = "%s ghosted your call..." % player["name"]

	# Remove from list and count the call
	backup_players.remove_at(chosen_index)
	calls_remaining -= 1
	if calls_remaining <= 0:
		$CallBackupButton.disabled = true
	$CallsRemainingLabel.text = "Calls Left: %d / 2" % calls_remaining

# Back to clubroom
func _on_button_clubroom():
	GameState.already_visited_clubroom = true
	#Lock in player selection
	GameState.team_finalised = true
	
	get_tree().change_scene_to_file("res://clubroom.tscn")
