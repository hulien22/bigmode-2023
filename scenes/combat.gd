extends Node2D
class_name Combat

enum CombatState {START_COMBAT, NEW_TURN, ROLLING, ABILITY_SELECTED, PLAYER_ABILITY, MONSTER_ABILITY, END_TURN, END_COMBAT}

var state: CombatState = CombatState.START_COMBAT

var ability_boxes:Array[AbilityBox]

@export
var dice_mgr:DiceManager

var monster: Monster
var turn_counter:int
var rerolls:int
var monster_intent:Ability


# player statuses followed by monster statuses
var statuses:Array[Array] = [[], []]
var statuses_to_inflict: Array[AbilityEffect]

var occurences:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	monster = Monster.new()
	monster.init_slime()
	ability_boxes = [$Combatscreen/Abilities/ability_box1, $Combatscreen/Abilities/ability_box2, \
					$Combatscreen/Abilities/ability_box3, $Combatscreen/Abilities/ability_box4, \
					$Combatscreen/Abilities/ability_box5, $Combatscreen/Abilities/ability_box6]
	for ab in ability_boxes:
		ab.connect("ability_clicked", _on_ability_clicked)
	$Combatscreen/RerollButton.connect("pressed", _on_reroll_button_pressed)
	dice_mgr.connect("complete_roll", _on_complete_roll)
	render_health()
	process_start_combat()

func process_start_combat():
	$Combatscreen/Abilities/ability_box1.init(1, GameState.player.abilities[0])
	$Combatscreen/Abilities/ability_box2.init(2, GameState.player.abilities[1])
	$Combatscreen/Abilities/ability_box3.init(3, GameState.player.abilities[2])
	$Combatscreen/Abilities/ability_box4.init(4, GameState.player.abilities[3])
	$Combatscreen/Abilities/ability_box5.init(5, GameState.player.abilities[4])
	$Combatscreen/Abilities/ability_box6.init(6, GameState.player.abilities[5])
	disable_abilities_and_rerollbtn()
	for d in GameState.player.dice:
		dice_mgr.add_die(d[0], d[1])
	turn_counter = -1
	rerolls = 3
	statuses = [[], []]
	
	process_new_turn()
	#todo timer between states? to play anims or smth

# Combat Turns
# New turn
#  - process new turn relics
#  - 


func process_new_turn():
	state = CombatState.NEW_TURN
	turn_counter += 1
	print("starting turn ", turn_counter)
	
	# process relics
	process_relics()
	
	# process statuses on player and monster
	if turn_counter > 0:
		# get copy of statuses before hand
		reduce_statuses(AbilityEffect.TARGET.PLAYER)
		for s in statuses_to_inflict:
			process_effect(s)
		reduce_statuses(AbilityEffect.TARGET.MONSTER)
		# animate status changes
	statuses_to_inflict.clear()
	
	print("player statuses:")
	for s in statuses[0]:
		print(s.as_string())
	print("monster statuses:")
	for s in statuses[1]:
		print(s.as_string())
	
	# select monster intent
	monster_intent = monster.get_next_move(turn_counter)
	print("monster intent: ", monster_intent.name_)
	
	$Combatscreen/RerollButton.disabled = false
	$Combatscreen/RerollButton.text = "ROLL"
	$Combatscreen/ModeVal.text = "?"
	

func _on_complete_roll(results):
	print(results)
	occurences = results.max()
	var modes:Array = []
	for i in results.size():
		if results[i] == occurences:
			modes.append(i+1)
			ability_boxes[i].set_enabled(true)
		else:
			ability_boxes[i].set_enabled(false)
	$Combatscreen/ModeVal.text = ",".join(modes)
	
	if rerolls > 0:
		$Combatscreen/RerollButton.disabled = false
		$Combatscreen/RerollButton.text = "REROLL (" + str(rerolls) + ")"

func _on_reroll_button_pressed():
	if state == CombatState.NEW_TURN:
		dice_mgr.reset_dice()
		state = CombatState.ROLLING
	else:
		rerolls -= 1
		$Combatscreen/RerollButton.text = "REROLL (" + str(rerolls) + ")"
	dice_mgr.drop_all_dice()
	disable_abilities_and_rerollbtn()

func _on_ability_clicked(val):
	disable_abilities_and_rerollbtn()
	dice_mgr.fade_away_dice()
	if state != CombatState.ROLLING:
		return
	state = CombatState.ABILITY_SELECTED
	print("selected ability ", ability_boxes[val-1].ability.name_)

	state = CombatState.PLAYER_ABILITY
	process_ability(ability_boxes[val-1].ability, false)
	# check if anyone died
	
	var tmr = get_tree().create_timer(0.5)
	await tmr.timeout
	process_monster_turn()

func process_monster_turn():
	state = CombatState.MONSTER_ABILITY
	process_ability(monster_intent, true)
	# check if anyone died
	
	process_end_turn()

func process_ability(ability: Ability, inflict_status_later: bool):
	for effect in ability.effects_:
		if inflict_status_later && effect.is_status_inflict() && effect.target_ == AbilityEffect.TARGET.PLAYER:
			statuses_to_inflict.append(effect)
			continue
		process_effect(effect)

func process_effect(effect: AbilityEffect):
	match effect.type_:
		AbilityEffect.TYPE.DAMAGE:
			var dmg = effect.process_value(occurences)
			# process other statuses (eg strength, weaknesses)
			inflict_damage(effect.target_, compute_damage(dmg, (effect.target_ + 1) % 2, effect.target_))
		AbilityEffect.TYPE.SHIELD:
			var amt = effect.process_value(occurences)
			# process other statuses (eg strength)
			change_block(effect.target_, amt)
		AbilityEffect.TYPE.VULNERABLE:
			var amt = effect.process_value(occurences)
			# process other statuses (eg strength)
			add_status(effect.target_, AbilityEffect.TYPE.VULNERABLE, amt, true)
		AbilityEffect.TYPE.STRENGTH:
			var amt = effect.process_value(occurences)
			# process other statuses (eg strength)
			add_status(effect.target_, AbilityEffect.TYPE.STRENGTH, amt, false)

func process_end_turn():
	state = CombatState.END_TURN
	process_relics()
	
	print("player statuses:")
	for s in statuses[0]:
		print(s.as_string())
	print("monster statuses:")
	for s in statuses[1]:
		print(s.as_string())
	
	process_new_turn()

func process_relics():
	for r in GameState.player.relics:
		r.process_relic(self)

func render_health():
	$Combatscreen/PlayerHealth.text = str(GameState.player.health) + "/" + str(GameState.player.max_health)
	$Combatscreen/MonsterHealth.text = str(monster.health) + "/" + str(monster.max_health)
	$Combatscreen/PlayerBlock.text = str(GameState.player.block)
	$Combatscreen/MonsterBlock.text = str(monster.block)

func change_health(target: AbilityEffect.TARGET, amount: int):
	if target == AbilityEffect.TARGET.PLAYER:
		GameState.player.health += amount
	else:
		monster.health += amount
	#animate?
	render_health()

func change_block(target: AbilityEffect.TARGET, amount: int):
	if target == AbilityEffect.TARGET.PLAYER:
		GameState.player.block += amount
	else:
		monster.block += amount
	#animate?
	render_health()

func inflict_damage(target: AbilityEffect.TARGET, dmg: int):
	var cur_block = GameState.player.block 
	if target == AbilityEffect.TARGET.MONSTER:
		cur_block = monster.block
	
	if cur_block > dmg:
		change_block(target, -dmg)
	else:
		change_health(target, cur_block - dmg)
		change_block(target, -cur_block)

func disable_abilities_and_rerollbtn():
	$Combatscreen/RerollButton.disabled = true
	$Combatscreen/ModeVal.text = "?"
	for ab in ability_boxes:
		ab.set_enabled(false)

func add_status(target: AbilityEffect.TARGET, type: AbilityEffect.TYPE, amt: int, auto_reduce:bool):
	for s in statuses[target]:
		if s.type == type:
			s.add_amount(amt)
			return
	statuses[target].append(Status.new(type, amt, auto_reduce))

func reduce_statuses(target: AbilityEffect.TARGET):
	for i in range(statuses[target].size() - 1, -1, -1):
		if statuses[target][i].reduce_at_newturn:
			statuses[target][i].add_amount(-1)
			# animate and wait?
			if statuses[target][i].amount == 0:
				statuses[target][i].free()
				statuses[target].remove_at(i)

func compute_damage(base_dmg: int, source: AbilityEffect.TARGET, target: AbilityEffect.TARGET) -> int:
	var dmg = base_dmg
	# first go through strength modifiers
	for s in statuses[source]:
		match s.type:
			AbilityEffect.TYPE.STRENGTH:
				dmg += s.amount
			_:
				pass
	for s in statuses[target]:
		match s.type:
			AbilityEffect.TYPE.VULNERABLE:
				dmg *= 2
			_:
				pass
	return dmg
