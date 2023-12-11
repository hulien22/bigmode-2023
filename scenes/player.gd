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
	add_new_relic(Relic.TYPE.TRUSTY_SHIELD)

func has_upgradeable_ability() -> bool:
	for a in abilities:
		if a.is_upgradeable():
			return true
	return false

func add_new_relic(t:Relic.TYPE):
	var r = Relic.new()
	r.init_relic(t)
	relics.append(r)
	# on pickup relics
	match t:
		Relic.TYPE.SNAKE_FRIEND:
			dice.append([[1,1,1,1,1], Color.SEA_GREEN])
		Relic.TYPE.EVEN_STEVEN:
			dice.append([[2,2,2,2,2,2], Color.SADDLE_BROWN])
		Relic.TYPE.SACRED_POWER:
			dice.append([[3,3,3,3,3,3], Color.GOLD])
		Relic.TYPE.BRINGER_OF_DEATH:
			dice.append([[4,4,4,4,4,4], Color.GRAY])
		Relic.TYPE.DRAGON_QUEEN:
			dice.append([[5,5,5,5,5,5], Color.ROSY_BROWN])
		Relic.TYPE.HIGH_ROLLER:
			dice.append([[6,6,6,6,6,6], Color.MEDIUM_ORCHID])
		Relic.TYPE.MOMS_STEW:
			max_health += 5
			health += 5
			Events.emit_signal("health_updated")
		Relic.TYPE.BAG_OF_HOLDING:
			coins += 10
			Events.emit_signal("coins_updated")

func has_relic(t:Relic.TYPE) -> bool:
	for r in relics:
		if r.type == t:
			return true
	return false

func get_relic(t:Relic.TYPE) -> Relic:
	for r in relics:
		if r.type == t:
			return r
	return null
