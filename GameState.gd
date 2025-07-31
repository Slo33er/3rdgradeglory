extends Node
var wins: int = 0
var losses: int = 0
var forfeits: int = 0
var money: int = 500
var morale: int = 75
var backup_calls: int = 3
#Stores Rsults like ["Win", "Loss", "Forfeit"]
var match_results: Array = []
var current_week: int = 1
var called_players: Array = []#Trackplayers
var players_ready_list: Array = [] #Store Players name marked in
var already_visited_clubroom: bool = false
var player_called_this_week: bool = false
# Has player calling already been done?
var team_finalised: bool = false 




func _ready():
	#Mark that we have been to the clubroom at least once
	GameState.already_visited_clubroom = true
	GameState.current_week += 1
	GameState.players_ready_list.clear()
	GameState.player_called_this_week = false
	

func reset():
	current_week = 1
	wins = 0
	losses = 0
	forfeits = 0
	money = 500
	morale = 75
	backup_calls = 3
	match_results.clear()
	players_ready_list.clear()
	team_finalised = false
	
