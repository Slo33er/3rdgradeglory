extends Control

func _ready():
	$StartMatchButton.visible = false #Default hidden
	
	for player_name in GameState.players_ready_list:
		var label = Label.new()
		label.text = player_name
		$TeamListContainer.add_child(label)
	
	#Match Histort
	show_match_history()
	
	#Hide or disable Call players if team is locked in
	if GameState.team_finalised:
		$Call_Players.disabled = true	
	if GameState.players_ready_list.size() >= 9:
		$StartMatchButton.visible = true
		

func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


#func _on_button_pressed() -> void:
	#pass # Replace with function body.


func _on_call_players_pressed():
	get_tree().change_scene_to_file("res://call_players.tscn")




func _on_startMatchButtonPressed():
	var players_ready = GameState.players_ready_list.size()
	var result = ""

	# Simulate the result based on number of players
	if players_ready < 9:
		result = "Forfeit"
	elif players_ready >= 11:
		result = "Win"
	else:
		var roll = randi() % 100
		result = "Win" if roll < 60 else "Loss"

	# Store the result
	GameState.match_results.append("Week %d: %s" % [GameState.current_week, result])
	GameState.current_week += 1

	# Create a simple popup panel manually
	var popup = Panel.new()
	popup.custom_minimum_size = Vector2(200, 120)
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	popup.add_child(vbox)

	# Add result label
	var label = Label.new()
	label.text = "Result: %s" % result
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
	vbox.add_child(label)

	# Add OK button
	var ok_button = Button.new()
	ok_button.text = "OK"
	#ok_button.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ok_button.pressed.connect(func(): popup.queue_free())
	vbox.add_child(ok_button)

	add_child(popup)

	# Update match history
	show_match_history()


	
	
func show_match_history():
	for child in $MatchHistory.get_children():
		child.queue_free()
	for match in GameState.match_results:
		var label = Label.new()
		label.text = match
		$MatchHistory.add_child(label)
