extends Resource
class_name Relic

enum TYPE {
	TRUSTY_SHIELD,
	TITAN_BELT,
	CAT_SLIPPERS,
	DWARVEN_MEAD,
	CULTIST_HEAD,
	BACKUP_PLANS,
	SNAKE_FRIEND,
	EVEN_STEVEN,
	SACRED_POWER,
	BRINGER_OF_DEATH,
	DRAGON_QUEEN,
	HIGH_ROLLER,
	MORE_OPTIONS,
	SENTINEL_SHIELD,
	MOMS_STEW,
	TROLL_HEART,
	BAG_OF_HOLDING,
	COOL_GUY_GLASSES,
	DEAL_WITH_THE_DEVIL,
	RATIONS,
	FRONTLOADED,
	INFERNAL_ENGINE,
	FROZEN_SUPERSUIT,
	DRUNKEN_BRAWLER,
	GREED,
	MASOCHIST,
}

const regular_relics: Array[TYPE] = [
	TYPE.TITAN_BELT, 
	TYPE.CAT_SLIPPERS, 
	TYPE.DWARVEN_MEAD, 
	TYPE.CULTIST_HEAD, 
	TYPE.BACKUP_PLANS, 
	TYPE.SNAKE_FRIEND, 
	TYPE.EVEN_STEVEN, 
	TYPE.SACRED_POWER, 
	TYPE.BRINGER_OF_DEATH, 
	TYPE.DRAGON_QUEEN, 
	TYPE.HIGH_ROLLER, 
	TYPE.MORE_OPTIONS, 
	TYPE.SENTINEL_SHIELD, 
	TYPE.MOMS_STEW, 
	TYPE.TROLL_HEART, 
	TYPE.BAG_OF_HOLDING
]

const boss_relics: Array[TYPE] = [
	TYPE.COOL_GUY_GLASSES,
	TYPE.DEAL_WITH_THE_DEVIL,
	TYPE.RATIONS,
	TYPE.FRONTLOADED,
	TYPE.INFERNAL_ENGINE,
	TYPE.FROZEN_SUPERSUIT,
	TYPE.DRUNKEN_BRAWLER,
	TYPE.GREED,
	TYPE.MASOCHIST,
]

var name_: String = ""
var description: String = ""
var animated_sprite_frame: int = 0
var type: TYPE
# used to keep track of certain permanent counters
var value: int = 0

func init_relic(t: TYPE):
	type = t
	value = 0
	match t:
		TYPE.TRUSTY_SHIELD:
			name_ = "Trusty Shield"
			description = "Gain 2 shield and 1 extra reroll on your first turn"
		TYPE.TITAN_BELT:
			name_ = "Titan Belt"
			description = "Start each combat with 1 Strength\n---\nStrength: Deal extra damage"
		TYPE.CAT_SLIPPERS:
			name_ = "Cat Slippers"
			description = "Start each combat with 1 Dexterity\n---\nDexterity: gain extra shield"
		TYPE.DWARVEN_MEAD:
			name_ = "Dwarven Mead"
			description = "Gain 2 extra healing dice when you rest"
		TYPE.CULTIST_HEAD:
			name_ = "Cultist Head"
			description = "Can sacrifice 2 dice at ritual circles"
		TYPE.BACKUP_PLANS:
			name_ = "Backup Plans"
			description = "Gain 2 shield at the end of your turn if you have none"
		TYPE.SNAKE_FRIEND:
			name_ = "Snake Friend"
			description = "Gain a die with only 1s"
		TYPE.EVEN_STEVEN:
			name_ = "Even Steven"
			description = "Gain a die with only 2s"
		TYPE.SACRED_POWER:
			name_ = "Sacred Power"
			description = "Gain a die with only 3s"
		TYPE.BRINGER_OF_DEATH:
			name_ = "Bringer of Death"
			description = "Gain a die with only 4s"
		TYPE.DRAGON_QUEEN:
			name_ = "Dragon Queen"
			description = "Gain a die with only 5s"
		TYPE.HIGH_ROLLER:
			name_ = "High Roller"
			description = "Gain a die with only 6s"
		TYPE.MORE_OPTIONS:
			name_ = "More Options"
			description = "Gain an extra reroll every 3 turns"
			value = 0
		TYPE.SENTINEL_SHIELD:
			name_ = "Sentinel Shield"
			description = "Start combat with 1 Evade\n---\nEvading: Dodge all damage"
		TYPE.MOMS_STEW:
			name_ = "Mom's Stew"
			description = "Gain +5 max health"
		TYPE.TROLL_HEART:
			name_ = "Troll's Heart"
			description = "Heal 1 after each fight"
		TYPE.BAG_OF_HOLDING:
			name_ = "Bag of Holding"
			description = "Gain 10 coins"
		TYPE.COOL_GUY_GLASSES:
			name_ = "Cool Guy Glasses"
			description = "Gain 3 more dice, but start each turn dazzled\n---\nDazzled: Randomize all dice faces"
		TYPE.DEAL_WITH_THE_DEVIL:
			name_ = "Deal with the Devil"
			description = "Can reroll extra times at the cost of 2 health"
		TYPE.RATIONS:
			name_ = "Rations"
			description = "Relics with limited uses get one more use"
		TYPE.FRONTLOADED:
			name_ = "Frontloaded"
			description = "Start with 10 rerolls for the entire combat. No longer gain 2 at the start of each turn"
		TYPE.INFERNAL_ENGINE:
			name_ = "Infernal Engine"
			description = "Gain 2 random dice, start each fight with 3 Burn\n---\nBurned: Increase all dice values by 1 (max value is still 6)"
		TYPE.FROZEN_SUPERSUIT:
			name_ = "Frozen Super Suit"
			description = "Gain 2 random dice, start each fight with 3 Frozen\n---\nFrozen: Decrease all dice values by 1 (min value is still 1)"
		TYPE.DRUNKEN_BRAWLER:
			name_ = "Drunken Brawler"
			description = "Start each combat with 3 Dexterity and 2 Blinded\n---\nBlinded: Can't see dice faces"
		TYPE.GREED:
			name_ = "Greed"
			description = "Gain 1 extra reroll per turn, but can no longer gain gold"
		TYPE.MASOCHIST:
			name_ = "Masochist"
			description = "Gain 1 permanent strength each time you hurt yourself"
			value = 0

