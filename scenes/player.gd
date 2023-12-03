class_name Player

var health: int = 10
var max_health:int = 10
var block:int = 0
var abilities: Array[Ability]
var dice: Array
var relics: Array[Relic]

func init_warrior():
	max_health = 10
	health = 10
	abilities = [Global.abilities[0],
				 Global.abilities[0], 
				 Global.abilities[2], 
				 Global.abilities[2], 
				 Global.abilities[4], 
				 Global.abilities[6]]
	dice = [[[1,2,6,5,3,4], Color.LIGHT_SEA_GREEN],
			[[1,2,6,5,3,4], Color.CRIMSON],
			[[1,2,6,5,3,4], Color.PURPLE],
			[[1,2,6,5,3,4], Color.GOLD],
			[[1,2,6,5,3,4], Color.LIGHT_GREEN]]
#	dice = [[[6,6,6,6,6,6], Color.LIGHT_SEA_GREEN],
#			[[6,6,6,6,6,6], Color.CRIMSON],
#			[[6,6,6,6,6,6], Color.PURPLE],
#			[[6,6,6,6,6,6], Color.GOLD],
#			[[6,6,6,6,6,6], Color.LIGHT_GREEN]]
	relics = []

