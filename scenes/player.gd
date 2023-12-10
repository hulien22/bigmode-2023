class_name Player

var health: int = 10
var max_health:int = 10
var block:int = 0
var coins:int = 0
var abilities: Array[Ability]
var dice: Array
var relics: Array[Relic]

func init_warrior():
	max_health = 10
	health = 10
	coins = 5
	abilities = [Global.get_ability_by_name("Strike"),
				 Global.get_ability_by_name("Strike"), 
				 Global.get_ability_by_name("Block"), 
				 Global.get_ability_by_name("Block"), 
				 Global.get_ability_by_name("Wide Swing"), 
				 Global.get_ability_by_name("Power Up")]
	dice = [[[1,2,6,5,3,4], Color.LIGHT_SEA_GREEN],
			[[1,2,6,5,3,4], Color.CRIMSON],
			[[1,2,6,5,3,4], Color.PURPLE],
			[[1,2,6,5,3,4], Color.GOLD],
			[[1,2,6,5,3,4], Color.LIGHT_GREEN]]
#	dice = [[[5,5,5,5,5,5], Color.LIGHT_SEA_GREEN],
#			[[5,5,5,5,5,5], Color.CRIMSON],
#			[[5,5,5,5,5,5], Color.PURPLE],
#			[[5,5,5,5,5,5], Color.GOLD],
#			[[5,5,5,5,5,5], Color.LIGHT_GREEN]]
	relics = []

func has_upgradeable_ability() -> bool:
	for a in abilities:
		if a.is_upgradeable():
			return true
	return false
