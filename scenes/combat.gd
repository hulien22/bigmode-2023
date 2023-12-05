extends Node2D
class_name Combat

enum CombatState {START_COMBAT, NEW_TURN, ROLLING, ABILITY_SELECTED, PLAYER_ABILITY, MONSTER_ABILITY, END_TURN, END_COMBAT}

var combat_state: CombatState = CombatState.START_COMBAT

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
	ability_boxes = [$Abilities/ability_box1, $Abilities/ability_box2, \
					$Abilities/ability_box3, $Abilities/ability_box4, \
					$Abilities/ability_box5, $Abilities/ability_box6]
	render_health()
	go_to_scene(GameState.GameScene.INTRO)
#	process_start_combat()

func go_to_scene(gs: GameState.GameScene):
	hide_all_scenes()
	match gs:
		GameState.GameScene.INTRO:
			var doors:Array[GameState.GameScene] = [GameState.GameScene.COMBAT]
			$DoorChoiceScreen.init(doors, "After a long trek you finally made it to the dungeon entrance..\nYou take a deep breath and enter through the front door")
			$DoorChoiceScreen.connect("door_selected", go_to_scene)
			$DoorChoiceScreen.show()
		GameState.GameScene.COMBAT:
			$MonsterUI.show()
			$Combatscreen.show()
			process_start_combat()
	# can do stuff with current game_scene before swapping to target one
	GameState.game_scene = gs

func hide_all_scenes():
	$MonsterUI.hide()
	$Combatscreen.hide()
	$DoorChoiceScreen.hide()

func process_start_combat():
	disable_abilities_and_rerollbtn()
	monster = Monster.new()
	monster.init_slime()
	$Abilities/ability_box1.init(1, GameState.player.abilities[0])
	$Abilities/ability_box2.init(2, GameState.player.abilities[1])
	$Abilities/ability_box3.init(3, GameState.player.abilities[2])
	$Abilities/ability_box4.init(4, GameState.player.abilities[3])
	$Abilities/ability_box5.init(5, GameState.player.abilities[4])
	$Abilities/ability_box6.init(6, GameState.player.abilities[5])
	for ab in ability_boxes:
		ab.connect("ability_clicked", _on_ability_clicked)
	$Combatscreen/RerollButton.connect("pressed", _on_reroll_button_pressed)
	dice_mgr.connect("complete_roll", _on_complete_roll)
	for d in GameState.player.dice:
		dice_mgr.add_die(d[0], d[1])
	turn_counter = -1
	rerolls = 3
	statuses = [[], []]
	
	render_health()
	animate_abilities_slide(true)
	
	process_new_turn()
	#todo timer between states? to play anims or smth


func process_new_turn():
	combat_state = CombatState.NEW_TURN
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
	animate_status_changes()
	
	# trying this
	rerolls = 2
	
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
	$Combatscreen/ModeVal.text = "Mode: ?"
	

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
	$Combatscreen/ModeVal.text = "Mode: " + ",".join(modes)
	animate_abilities_slide(true)
	
	if rerolls > 0:
		$Combatscreen/RerollButton.disabled = false
		$Combatscreen/RerollButton.text = "REROLL (" + str(rerolls) + ")"

func _on_reroll_button_pressed():
	if combat_state == CombatState.NEW_TURN:
		dice_mgr.reset_dice()
		combat_state = CombatState.ROLLING
	else:
		rerolls -= 1
		$Combatscreen/RerollButton.text = "REROLL (" + str(rerolls) + ")"
	dice_mgr.drop_all_dice()
	disable_abilities_and_rerollbtn()

func _on_ability_clicked(val):
	disable_abilities_and_rerollbtn()
	dice_mgr.fade_away_dice()
	if combat_state != CombatState.ROLLING:
		return
	combat_state = CombatState.ABILITY_SELECTED
	print("selected ability ", ability_boxes[val-1].ability.name_)

	combat_state = CombatState.PLAYER_ABILITY
	process_ability(ability_boxes[val-1].ability, false)
	
#	animate_status_changes()
	
	# check if anyone died
	
	$PlayerUI/character.play_attack()
	await wait_secs(0.5)
	animate_status_changes()
	render_health()
	await wait_secs(0.5)
	process_monster_turn()

func process_monster_turn():
	combat_state = CombatState.MONSTER_ABILITY
	process_ability(monster_intent, true)
	
	# check if anyone died
	
	$MonsterUI/character2.play_attack()
	await wait_secs(0.5)
	animate_status_changes()
	render_health()
	await wait_secs(0.5)
	
	process_end_turn()

func process_ability(ability: Ability, inflict_status_later: bool):
	for effect in ability.effects_:
		if inflict_status_later && effect.is_status_inflict() && effect.target_ == AbilityEffect.TARGET.PLAYER:
			statuses_to_inflict.append(effect)
			continue
		process_effect(effect)
	#TODO: return type of animation to play (instead of just attack always)

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
	combat_state = CombatState.END_TURN
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
	$PlayerUI/PlayerHealth.text = str(GameState.player.health) + "/" + str(GameState.player.max_health)
	$PlayerUI/PlayerBlock.text = str(GameState.player.block)
	if monster:
		$MonsterUI/MonsterHealth.text = str(monster.health) + "/" + str(monster.max_health)
		$MonsterUI/MonsterBlock.text = str(monster.block)

func change_health(target: AbilityEffect.TARGET, amount: int):
	if target == AbilityEffect.TARGET.PLAYER:
		GameState.player.health += amount
	else:
		monster.health += amount
	#animate?
#	render_health()

func change_block(target: AbilityEffect.TARGET, amount: int):
	if target == AbilityEffect.TARGET.PLAYER:
		GameState.player.block += amount
	else:
		monster.block += amount
	#animate?
#	render_health()

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
#	animate_abilities_slide(false)
	$Combatscreen/RerollButton.disabled = true
	$Combatscreen/ModeVal.text = "Mode: ?"
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
#				statuses[target][i].free()
				statuses[target].remove_at(i)

func animate_status_changes():
	$Combatscreen/Statuses/PlayerStatusHolder.update_statuses(statuses[0])
	$Combatscreen/Statuses/MonsterStatusHolder.update_statuses(statuses[1])

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

func wait_secs(s: float):
	var tmr = get_tree().create_timer(s)
	await tmr.timeout

func animate_abilities_slide(slide_in:bool):
	var posn: Vector2 = Vector2(1407, 395)
	if !slide_in:
		posn.x += 500
	var alpha = 1 if slide_in else 0
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Abilities, "position", posn, 0.5)
#	tween.tween_property($Abilities, "modulate:a", alpha, 0.5)
	pass
	
