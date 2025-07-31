extends Control

func _ready():
	# Check buttons exist before changing visibility
	if has_node("ForfeitButton"):
		$ForfeitButton.visible = false
	
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
			
	var count = GameState.players_ready_list.size()

	if count >= 9:
		$StartMatchButton.visible = true
		$ForfeitButton.visible = false
	else:
		$StartMatchButton.visible = false
		$ForfeitButton.visible = true
		

func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


#func _on_button_pressed() -> void:
	#pass # Replace with function body.


func _on_call_players_pressed():
	get_tree().change_scene_to_file("res://call_players.tscn")




func _on_startMatchButtonPressed():
	var players_ready = GameState.players_ready_list.size()
	var result = ""

	if players_ready < 9:
		GameState.forfeits += 1
		result = "Forfeit"
	elif players_ready >= 11:
		result = "Win"
	else:
		var roll = randi() % 100
		if roll < 75:
			result = "Win"
		else:
			result = "Loss"

	# Store the result
	GameState.match_results.append("Week %d: %s" % [GameState.current_week, result])
	GameState.current_week += 1
	if GameState.current_week > 12:
		$MatchResultLabel.text = "Season is over"
		$MatchResultLabel.visible = true
		$StartMatchButton.visible = false
		return

	# Display result on the label instead of popup
	$MatchResultLabel.text = "Result: %s" % result
	$MatchResultLabel.visible = true

	# Update match history list
	show_match_history()
	
	#Reset Player list
	GameState.players_ready_list.clear()
	for child in $TeamListContainer.get_children():
		child.queue_free()
		
		# ✅ Allow players to be called again
	GameState.player_called_this_week = false
	GameState.team_finalised = false
	

	#Buttons
	$StartMatchButton.set_disabled(not GameState.player_called_this_week)
	$Call_Players.disabled = false
	
	
func show_match_history():
	for child in $MatchHistory.get_children():
		child.queue_free()
	for match in GameState.match_results:
		var label = Label.new()
		label.text = match
		$MatchHistory.add_child(label)


func _on_ForfeitButton_pressed():
	var result = "Forfeit"
	GameState.forfeits += 1

	GameState.match_results.append("Week %d: %s" % [GameState.current_week, result])
	GameState.current_week += 1

	if GameState.current_week > 12:
		$MatchResultLabel.text = "Season is over"
		$MatchResultLabel.visible = true
		$StartMatchButton.visible = false
		$ForfeitButton.visible = false
		return

	$MatchResultLabel.text = "Result: %s" % result
	$MatchResultLabel.visible = true

	show_match_history()

	# Clear team and prepare next week
	GameState.players_ready_list.clear()
	for child in $TeamListContainer.get_children():
		child.queue_free()

	GameState.player_called_this_week = false
	GameState.team_finalised = false

	$StartMatchButton.set_disabled(true)
	$Call_Players.disabled = false
