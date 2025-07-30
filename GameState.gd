extends Node

func _ready():
	#Mark that we have been to the clubroom at least once
	GameState.already_visited_clubroom = true

var called_players: Array = []#Trackplayers
var players_ready_list: Array = [] #Store Players name marked in
var already_visited_clubroom: bool = false

# Has player calling already been done?
var team_finalised: bool = false 

#Stores Rsults like ["Win", "Loss", "Forfeit"]
var match_results: Array = []
var current_week: int = 1
