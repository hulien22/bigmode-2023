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
var cur_abilities: Array[AbilityDesc]

# player statuses followed by monster statuses
var statuses:Array[Array] = [[], []]
var statuses_to_inflict: Array[AbilityEffect]

var occurences:int = 0
var last_mode_used:int = 0

var ritual_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	ability_boxes = [$Abilities/ability_box1, $Abilities/ability_box2, \
					$Abilities/ability_box3, $Abilities/ability_box4, \
					$Abilities/ability_box5, $Abilities/ability_box6]
	monster = Monster.new()
	GameState.reset_game_state()
	render_health()
	add_coins(0)
	go_to_scene(GameState.GameScene.INTRO)
	for i in 6:
		ability_boxes[i].init(i+1, GameState.player.abilities[i])
	
	$RelicHolder.update_relics()
	
	Events.connect("coins_updated", anim_coins)
	Events.connect("health_updated", render_health)
	Events.connect("abilities_updated", update_abilities_with_player_vals)
	Events.connect("relics_updated", render_relics)
	Events.connect("sacrificed_die", sacrificed_die)
	
	$GameoverScreen.connect("gg_go_home", return_to_main_menu)
	$tutorial.connect("gg_go_next", close_tutorial)
	
	$DoorChoiceScreen.connect("door_selected", _on_door_selected)
	$AbilityChoiceScreen.connect("gg_go_next", generate_next_door_scene)
	$LootScreen.connect("gg_go_next", end_loot_screen)
	$LootScreen.connect("add_coins", add_coins)
	$DiceShopScreen.connect("gg_go_next", end_dice_shop)
	$RestScreen.connect("gg_go_next", end_rest_scene)
	$RestScreen.connect("begin_upgrade", process_upgrade)
	$RestScreen.connect("begin_heal", process_heal)
	$RitualScreen.connect("gg_go_next", end_ritual_scene)
	$ChestScreen.connect("gg_go_next", generate_next_door_scene)
	$VictoryScreen.connect("gg_go_home", return_to_main_menu)
	$BossLootScreen.connect("gg_go_next", go_to_scene.bind(GameState.GameScene.SELECT_ABILITY))
#	process_start_combat()


####################################################################################################
####################################################################################################
####################################################################################################
func go_to_scene(gs: GameState.GameScene):
	GameState.game_scene = gs
	hide_all_scenes()
	update_abilities_with_player_vals(false)
	match gs:
		GameState.GameScene.INTRO:
			var doors:Array[GameState.GameScene] = [GameState.GameScene.COMBAT]
#			var doors:Array[GameState.GameScene] = [GameState.GameScene.SELECT_ABILITY]
			$DoorChoiceScreen.init(doors, "After a long trek you finally made it to the dungeon entrance..\nYou take a deep breath and enter through the front door")
			$DoorChoiceScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.DOORS:
			var doors:Array[GameState.GameScene] = GameState.generate_next_doors()
			print("LEVEL: ", GameState.level, "DOORS: ", doors)
			if GameState.level == 10 || GameState.level == 20:
				$DoorChoiceScreen.init(doors, "You find an entrance leading to the next level of the dungeon\n\nYou ready yourself to delve deeper and see what lies below\n\nLevel Up! Max health increased!")
				GameState.player.max_health += 5
				GameState.player.health = GameState.player.max_health
				render_health()
			elif doors.size() == 1:
				$DoorChoiceScreen.init(doors, "You find yourself in front of a large door")
			else:
				$DoorChoiceScreen.init(doors, "You find yourself in front of two doors\nPick a door")
			$DoorChoiceScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.COMBAT:
			if GameState.level == 0 && GameState.games_played <= 1:
				open_tutorial()
			else:
				$MonsterUI.show()
				$Combatscreen.show()
				process_start_combat()
		GameState.GameScene.ELITE:
			$MonsterUI.show()
			$Combatscreen.show()
			process_start_combat(true)
		GameState.GameScene.SELECT_ABILITY:
			var new_abs:Array[Ability] = Global.generate_abilities(3, GameState.level)
			$AbilityChoiceScreen.init(ability_boxes, new_abs)
			$AbilityChoiceScreen.show()
			animate_abilities_slide(true)
		GameState.GameScene.LOOT:
			var c = 2 if monster == null else monster.coins_dropped
			var r = null if !monster.is_elite else GameState.generate_new_relic()
			$LootScreen.init(c, r)
			$LootScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.BOSSLOOT:
			$BossLootScreen.init()
			$BossLootScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.DICE_SHOP:
			$DiceShopScreen.init()
			$DiceShopScreen.show()
			animate_abilities_slide(false)
			#start dice rolls
			init_dice_shop()
		GameState.GameScene.REST:
			$RestScreen.init()
			$RestScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.RITUAL:
			ritual_count = 0
			$RitualScreen.init()
			$RitualScreen.show()
			init_ritual_scene()
			animate_abilities_slide(false)
		GameState.GameScene.CHEST:
			$ChestScreen.init(GameState.generate_new_relic())
			$ChestScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.VICTORY:
			$VictoryScreen.show()
			animate_abilities_slide(true)


func hide_all_scenes():
	$MonsterUI.hide()
	$Combatscreen.hide()
	$DoorChoiceScreen.hide()
	$AbilityChoiceScreen.hide()
	$LootScreen.hide()
	$BossLootScreen.hide()
	$DiceShopScreen.hide()
	$RestScreen.hide()
	$RitualScreen.hide()
	$ChestScreen.hide()
	$VictoryScreen.hide()
	$GameoverScreen.hide()


func generate_next_door_scene():
	go_to_scene(GameState.GameScene.DOORS)


func _on_door_selected(gs: GameState.GameScene):
	go_to_scene(gs)
	GameState.level += 1

####################################################################################################
####################################################################################################
####################################################################################################
func process_start_combat(is_elite: bool = false):
	disable_abilities_and_rerollbtn()
	monster.init_monster(GameState.generate_monster_to_fight())
	if is_elite:
		monster.set_elite()
	$MonsterUI/character2.init(monster.image)
	$MonsterUI/MonsterName.text = monster.name_

	# init copy of abilities with extra metadata
	cur_abilities = []
	for i in 6:
		cur_abilities.append(AbilityDesc.new(GameState.player.abilities[i]))
		if cur_abilities[i].has_limited_uses && GameState.player.has_relic(Relic.TYPE.RATIONS):
			cur_abilities[i].limited_uses_left += 1
	update_abilities_with_current_vals()

	for ab in ability_boxes:
		ab.connect("ability_clicked", _on_ability_clicked)
	$Combatscreen/RerollButton.connect("pressed", _on_reroll_button_pressed)
	dice_mgr.line_up_dice_after_roll = true
	dice_mgr.mouse_handler.remove_on_select = false
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 9.5, 5.5)
	dice_mgr.connect("complete_roll", _on_complete_roll)
	dice_mgr.clear_dice()
	for d in GameState.player.dice:
		dice_mgr.add_die(d[0], d[1])
	turn_counter = -1
	occurences = 0
	rerolls = 3
	statuses = [[], []]
	GameState.player.block = 0
	
	render_health()
	animate_abilities_slide(true)
	$MonsterUI/Intent/AnimationPlayer.play("intent")
	
#	add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.CONFUSE, 99, true)
#	add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BURN, 99, true)
#	add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BLIND, 2, true)
#	add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DAZZLED, 99, false)
	
	process_new_turn()
	#todo timer between states? to play anims or smth


func process_new_turn():
	combat_state = CombatState.NEW_TURN
	turn_counter += 1
	print("starting turn ", turn_counter)
	
	# process relics
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.TITAN_BELT):
		$RelicHolder.update_relic_type(Relic.TYPE.TITAN_BELT)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.STRENGTH, 1, false)
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.CAT_SLIPPERS):
		$RelicHolder.update_relic_type(Relic.TYPE.CAT_SLIPPERS)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DEXTERITY, 1, false)
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.SENTINEL_SHIELD):
		$RelicHolder.update_relic_type(Relic.TYPE.SENTINEL_SHIELD)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.EVADE, 1, true)

	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.COOL_GUY_GLASSES):
		$RelicHolder.update_relic_type(Relic.TYPE.COOL_GUY_GLASSES)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DAZZLED, 99, true)
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.FRONTLOADED):
		$RelicHolder.update_relic_type(Relic.TYPE.FRONTLOADED)
		rerolls = 10
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.INFERNAL_ENGINE):
		$RelicHolder.update_relic_type(Relic.TYPE.INFERNAL_ENGINE)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BURN, 3, true)
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.FROZEN_SUPERSUIT):
		$RelicHolder.update_relic_type(Relic.TYPE.FROZEN_SUPERSUIT)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.FREEZE, 3, true)
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.DRUNKEN_BRAWLER):
		$RelicHolder.update_relic_type(Relic.TYPE.DRUNKEN_BRAWLER)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BLIND, 2, true)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DEXTERITY, 3, false)
	if turn_counter == 0 &&GameState.player.has_relic(Relic.TYPE.MASOCHIST):
		$RelicHolder.update_relic_type(Relic.TYPE.MASOCHIST)
		var r: Relic = GameState.player.get_relic(Relic.TYPE.MASOCHIST)
		add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.STRENGTH, r.value, false)
	
	#monster starting statuses
	if turn_counter == 0 && monster.type == Monster.MonsterType.ARCHER:
		add_status(AbilityEffect.TARGET.MONSTER, AbilityEffect.TYPE.EVADE, 1, true)
	if turn_counter == 0 && monster.type == Monster.MonsterType.MIMIC:
		add_status(AbilityEffect.TARGET.MONSTER, AbilityEffect.TYPE.MIMICKING, 1, false)
	if turn_counter == 0 && monster.type == Monster.MonsterType.GIANT:
		add_status(AbilityEffect.TARGET.MONSTER, AbilityEffect.TYPE.THIKKSKIN, 3, false)
	
	# process statuses on player and monster
	if turn_counter > 0:
		# get copy of statuses before hand
		reduce_statuses(AbilityEffect.TARGET.PLAYER)
		for s in statuses_to_inflict:
			process_effect(s)
		reduce_statuses(AbilityEffect.TARGET.MONSTER)
		# animate status changes
	statuses_to_inflict.clear()
	
	if has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.TRAPPED):
		match last_mode_used:
			0:
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DISABLE_ABILITY1, 1, true)
			1:
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DISABLE_ABILITY2, 1, true)
			2:
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DISABLE_ABILITY3, 1, true)
			3:
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DISABLE_ABILITY4, 1, true)
			4:
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DISABLE_ABILITY5, 1, true)
			5:
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DISABLE_ABILITY6, 1, true)
	animate_status_changes()
	
	if has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BLIND):
		dice_mgr.blind_all_dice()
	else :
		dice_mgr.unblind_all_dice()
	
	if has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.DAZZLED):
		var num_dice:int = dice_mgr.dice.size()
		dice_mgr.clear_dice()
		for i in num_dice:
			dice_mgr.add_die(DiceConstructor.generate_random_die(), DiceConstructor.generate_random_die_color())
	
	# Reset disabled abilities
	for i in 6:
		cur_abilities[i].is_disabled = false
	# Shuffle abilities before applying disabled statuses
	if has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.CONFUSE):
		cur_abilities.shuffle()
	# Apply disabled abilities
	for s in statuses[AbilityEffect.TARGET.PLAYER]:
		match s.type:
			AbilityEffect.TYPE.DISABLE_ABILITY1:
				cur_abilities[0].is_disabled = true
			AbilityEffect.TYPE.DISABLE_ABILITY2:
				cur_abilities[1].is_disabled = true
			AbilityEffect.TYPE.DISABLE_ABILITY3:
				cur_abilities[2].is_disabled = true
			AbilityEffect.TYPE.DISABLE_ABILITY4:
				cur_abilities[3].is_disabled = true
			AbilityEffect.TYPE.DISABLE_ABILITY5:
				cur_abilities[4].is_disabled = true
			AbilityEffect.TYPE.DISABLE_ABILITY6:
				cur_abilities[5].is_disabled = true
			AbilityEffect.TYPE.DISABLE_ABILITYR:
				cur_abilities[randi_range(0,5)].is_disabled = true
	update_abilities_with_current_vals()
	
	# trying this
	if !GameState.player.has_relic(Relic.TYPE.FRONTLOADED):
		rerolls = 2
	
	if turn_counter == 0 && GameState.player.has_relic(Relic.TYPE.TRUSTY_SHIELD):
		$RelicHolder.update_relic_type(Relic.TYPE.TRUSTY_SHIELD)
		rerolls += 1
		change_block(AbilityEffect.TARGET.PLAYER, 2)
		render_health()
	if GameState.player.has_relic(Relic.TYPE.GREED):
		$RelicHolder.update_relic_type(Relic.TYPE.GREED)
		rerolls += 1
	if GameState.player.has_relic(Relic.TYPE.MORE_OPTIONS):
		$RelicHolder.update_relic_type(Relic.TYPE.MORE_OPTIONS)
		var r: Relic = GameState.player.get_relic(Relic.TYPE.MORE_OPTIONS)
		r.value += 1
		if r.value >= 3:
			r.value = 0
			rerolls += 1
	
	print("player statuses:")
	for s in statuses[0]:
		print(s.as_string())
	print("monster statuses:")
	for s in statuses[1]:
		print(s.as_string())
	
	# select monster intent
	monster_intent = monster.get_next_move(turn_counter, last_mode_used)
	$MonsterUI/Intent/MonsterIntent.text = monster_intent.name_
	_on_monster_intent_exited()
#	print("monster intent: ", monster_intent.name_)
	
	$Combatscreen/RerollButton.set_disabled(false)
	$Combatscreen/RerollButton.set_text("ROLL!")
	$Combatscreen/ModeVal.text = "Mode: ? | X=?"
	

func _on_complete_roll(results):
	print(results)
	
	# handle frozen / burned first
	if has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.FREEZE):
		if !has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BURN):
			results[0] += results[1]
			for i in range(1,5):
				results[i] = results[i + 1]
			results[5] = 0
	elif has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.BURN):
		results[5] += results[4]
		for i in range(4,0, -1):
			results[i] = results[i - 1]
		results[0] = 0
	
	occurences = results.max()
	var modes:Array = []
	for i in results.size():
		if results[i] == occurences:
			modes.append(i+1)
			ability_boxes[i].set_enabled(true)
		else:
			ability_boxes[i].set_enabled(false)
	$Combatscreen/ModeVal.text = "Mode=" + ",".join(modes) + " | X=" + str(occurences)
	animate_abilities_slide(true)
	
	if has_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.STUNNED):
		$Combatscreen/RerollButton.set_disabled(true)
		$Combatscreen/RerollButton.set_text("STUNNED")
	elif rerolls > 0:
		$Combatscreen/RerollButton.set_disabled(false)
		$Combatscreen/RerollButton.set_text("REROLL! (" + str(rerolls) + ")")
	elif rerolls == 0 && GameState.player.has_relic(Relic.TYPE.DEAL_WITH_THE_DEVIL):
		$Combatscreen/RerollButton.set_disabled(false)
		$Combatscreen/RerollButton.set_text("REROLL! (-2HP)")
		

func _on_reroll_button_pressed():
	if combat_state == CombatState.NEW_TURN:
		dice_mgr.reset_dice()
		combat_state = CombatState.ROLLING
	elif rerolls == 0 && GameState.player.has_relic(Relic.TYPE.DEAL_WITH_THE_DEVIL):
		inflict_damage(AbilityEffect.TARGET.PLAYER, 2)
		render_health()
		if GameState.player.health <= 0:
			combat_loss()
			return
		elif GameState.player.has_relic(Relic.TYPE.MASOCHIST):
			$RelicHolder.update_relic_type(Relic.TYPE.MASOCHIST)
			var r: Relic = GameState.player.get_relic(Relic.TYPE.MASOCHIST)
			r.value += 1
			add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.STRENGTH, 1, false)
			animate_status_changes()
	else:
		rerolls -= 1
		$Combatscreen/RerollButton.set_text("REROLL! (" + str(rerolls) + ")")
	dice_mgr.drop_all_dice()
	disable_abilities_and_rerollbtn()

func _on_ability_clicked(val):
	disable_abilities_and_rerollbtn()
	dice_mgr.fade_away_dice()
	if combat_state != CombatState.ROLLING:
		return
	combat_state = CombatState.ABILITY_SELECTED
	
	last_mode_used = val - 1
	print("selected ability ", ability_boxes[val-1].ability.name_)

	combat_state = CombatState.PLAYER_ABILITY
	
	var health_on_lethal: int = 0
	
	var num_loops:int = 1
	var haste_status:Status = get_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.HASTE)
	if haste_status != null:
		num_loops = 2
	
	for loop in num_loops:
		if loop == 1 && haste_status != null:
			haste_status.add_amount(-1)
			if haste_status.amount <= 0:
				for i in statuses[AbilityEffect.TARGET.PLAYER].size():
					if statuses[AbilityEffect.TARGET.PLAYER][i].type == AbilityEffect.TYPE.HASTE:
						statuses[AbilityEffect.TARGET.PLAYER].remove_at(i)
						break
			animate_status_changes()
		# Only process the selected ability if it is enabled
		if !cur_abilities[val-1].is_disabled:
			var d:Dictionary = process_ability(ability_boxes[val-1].ability, val, false)
		#	if d.get("deplete_ability", false):
		#		ability_boxes[val-1].init(val, Global.depleted_ability)
			if cur_abilities[val-1].has_limited_uses:
				cur_abilities[val-1].limited_uses_left -= 1
				if cur_abilities[val-1].limited_uses_left <= 0:
					cur_abilities[val-1] = AbilityDesc.new(Global.depleted_ability)
			if d.has("health_on_lethal"):
				health_on_lethal += d.get("health_on_lethal", 0)
		$PlayerUI/character.play_attack()
		await wait_secs(0.5)
		animate_status_changes()
		render_health()
		await wait_secs(0.5)

	# check if anyone died, check player first for game over
	if GameState.player.health <= 0:
		combat_loss()
		return
	if monster.health <= 0:
		if health_on_lethal > 0:
			GameState.player.max_health += health_on_lethal
			render_health()
		combat_win()
		return
	
	if GameState.player.has_relic(Relic.TYPE.BACKUP_PLANS) && GameState.player.block == 0:
		change_block(AbilityEffect.TARGET.PLAYER, 2)
		$RelicHolder.update_relic_type(Relic.TYPE.BACKUP_PLANS)
	var fortify_val: int = get_status_value(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.FORTIFY)
	if fortify_val > 0:
		change_block(AbilityEffect.TARGET.PLAYER, fortify_val)
		render_health()
	
	if has_status(AbilityEffect.TARGET.MONSTER, AbilityEffect.TYPE.BREATH_RECHARGE):
		if last_mode_used == 5 || last_mode_used == 4:
			monster.can_breath_attack = true
			for i in statuses[AbilityEffect.TARGET.MONSTER].size():
				if statuses[AbilityEffect.TARGET.MONSTER][i].type == AbilityEffect.TYPE.BREATH_RECHARGE:
					statuses[AbilityEffect.TARGET.MONSTER].remove_at(i)
					break
			animate_status_changes()
	
	process_monster_turn()

func process_monster_turn():
	combat_state = CombatState.MONSTER_ABILITY
	process_ability(monster_intent, 0, true)
	

	var fortify_val: int = get_status_value(AbilityEffect.TARGET.MONSTER, AbilityEffect.TYPE.FORTIFY)
	if fortify_val > 0:
		change_block(AbilityEffect.TARGET.MONSTER, fortify_val)
		render_health()
	
	$MonsterUI/character2.play_attack()
	await wait_secs(0.5)
	animate_status_changes()
	render_health()
	await wait_secs(0.5)
	
	# check player first for game over
	if GameState.player.health <= 0:
		combat_loss()
		return
	if monster.health <= 0:
		combat_win()
		return
	
	process_end_turn()

func process_ability(ability: Ability, face:int, inflict_status_later: bool) -> Dictionary:
	var dict:Dictionary = {}
	for effect in ability.effects_:
		if inflict_status_later && effect.is_status_inflict() && effect.target_ == AbilityEffect.TARGET.PLAYER:
			statuses_to_inflict.append(effect)
			continue
		var d:Dictionary = process_effect(effect, face)
		dict.merge(d)
	#TODO: return type of animation to play (instead of just attack always)
	return dict

# returns dictionary of follow up things
func process_effect(effect: AbilityEffect, face:int = 0) -> Dictionary:
	var dict:Dictionary = {}
	match effect.type_:
		AbilityEffect.TYPE.DAMAGE:
			var dmg = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			# process other statuses (eg strength, weaknesses)
			inflict_damage(effect.target_, max(0, compute_damage(dmg, (effect.target_ + 1) % 2, effect.target_)))
		AbilityEffect.TYPE.SHIELD:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			# process other statuses (eg strength)
			change_block(effect.target_, amt)
		AbilityEffect.TYPE.VULNERABLE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			# process other statuses (eg strength)
			add_status(effect.target_, AbilityEffect.TYPE.VULNERABLE, amt, true)
		AbilityEffect.TYPE.STRENGTH:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			# process other statuses (eg strength)
			add_status(effect.target_, AbilityEffect.TYPE.STRENGTH, amt, false)
#		AbilityEffect.TYPE.LIMITED_USES:
#			effect.uses_left -= 1
#			if effect.uses_left <= 0:
#				dict["deplete_ability"] = true
		AbilityEffect.TYPE.HEAL:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			change_health(effect.target_, -1 * amt)
		AbilityEffect.TYPE.SELF_DMG:
			var dmg = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			# don't include strength, do include vulnerable
			inflict_damage(effect.target_, max(0, compute_damage(dmg, AbilityEffect.TARGET.NOONE, effect.target_)))
			if effect.target_ == AbilityEffect.TARGET.PLAYER && GameState.player.has_relic(Relic.TYPE.MASOCHIST):
				$RelicHolder.update_relic_type(Relic.TYPE.MASOCHIST)
				var r: Relic = GameState.player.get_relic(Relic.TYPE.MASOCHIST)
				r.value += 1
				add_status(AbilityEffect.TARGET.PLAYER, AbilityEffect.TYPE.STRENGTH, 1, false)
		AbilityEffect.TYPE.DISABLE_ABILITY1:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITY1, amt, true)
		AbilityEffect.TYPE.DISABLE_ABILITY2:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITY2, amt, true)
		AbilityEffect.TYPE.DISABLE_ABILITY3:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITY3, amt, true)
		AbilityEffect.TYPE.DISABLE_ABILITY4:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITY4, amt, true)
		AbilityEffect.TYPE.DISABLE_ABILITY5:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITY5, amt, true)
		AbilityEffect.TYPE.DISABLE_ABILITY6:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITY6, amt, true)
		AbilityEffect.TYPE.DISABLE_ABILITYR:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DISABLE_ABILITYR, amt, true)
		AbilityEffect.TYPE.CONFUSE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.CONFUSE, amt, true)
		AbilityEffect.TYPE.BURN:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.BURN, amt, true)
		AbilityEffect.TYPE.FREEZE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.FREEZE, amt, true)
		AbilityEffect.TYPE.EVADE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.EVADE, amt, true)
		AbilityEffect.TYPE.FORTIFY:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.FORTIFY, amt, false)
		AbilityEffect.TYPE.HASTE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.HASTE, amt, false)
		AbilityEffect.TYPE.LOOT:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_coins(amt)
		AbilityEffect.TYPE.SCAVENGE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			for i in amt:
				dice_mgr.add_die(DiceConstructor.generate_random_die(), DiceConstructor.generate_random_die_color())
		AbilityEffect.TYPE.RUMMAGE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			for i in amt:
				dice_mgr.add_die([1,2,6,5,3,4], DiceConstructor.generate_random_die_color())
		AbilityEffect.TYPE.STUNNED:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.STUNNED, amt, true)
		AbilityEffect.TYPE.HEALTH_ON_LETHAL:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			dict["health_on_lethal"] = amt
		AbilityEffect.TYPE.EXHAUSTED:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.EXHAUSTED, amt, true)
		AbilityEffect.TYPE.TRAPPED:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.TRAPPED, amt, true)
		AbilityEffect.TYPE.DAZZLED:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.DAZZLED, amt, true)
		AbilityEffect.TYPE.FORESIGHT:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.FORESIGHT, amt, false)
		AbilityEffect.TYPE.BREATH_RECHARGE:
			var amt = effect.process_value(occurences, face, rerolls, GameState.player.block, dice_mgr.dice.size() - occurences)
			add_status(effect.target_, AbilityEffect.TYPE.BREATH_RECHARGE, amt, false)
		AbilityEffect.TYPE.DIESTEAL:
			dice_mgr.remove_random_die()
	return dict

func process_end_turn():
	combat_state = CombatState.END_TURN
	
	var fortify_val: int = get_status_value(AbilityEffect.TARGET.MONSTER, AbilityEffect.TYPE.FORTIFY)
	if fortify_val > 0:
		change_block(AbilityEffect.TARGET.MONSTER, fortify_val)
		render_health()
	
	process_new_turn()

func combat_win():
	print("MONSTER DIED")
	combat_state = CombatState.END_COMBAT
	
	for ab in ability_boxes:
		ab.disconnect("ability_clicked", _on_ability_clicked)
	$Combatscreen/RerollButton.disconnect("pressed", _on_reroll_button_pressed)
	dice_mgr.disconnect("complete_roll", _on_complete_roll)
	dice_mgr.clear_dice()
	turn_counter = -1
	rerolls = 3
	statuses = [[], []]
	GameState.player.block = 0
	
	$MonsterUI/character2.play_fade_die()
	$MonsterUI/Intent/AnimationPlayer.stop()
	animate_status_changes()
	await wait_secs(0.5)
	
	update_abilities_with_player_vals(false)
	
	if GameState.player.has_relic(Relic.TYPE.TROLL_HEART):
		$RelicHolder.update_relic_type(Relic.TYPE.TROLL_HEART)
		change_health(AbilityEffect.TARGET.PLAYER, 1)
	#generate loot scene
		# coins, and relic
	# which will then generate the ability screen
	go_to_scene(GameState.GameScene.LOOT)

func combat_loss():
	$GameoverScreen.set_level(GameState.level)
	$GameoverScreen.show()
	print("YOU DIED")
	pass

func render_health():
	$PlayerUI/PlayerHealth.text = str(GameState.player.health) + "/" + str(GameState.player.max_health)
	$PlayerUI/PlayerBlock.text = str(GameState.player.block)
	if monster && (GameState.game_scene == GameState.GameScene.COMBAT || GameState.game_scene == GameState.GameScene.ELITE || GameState.game_scene == GameState.GameScene.BOSS):
		$MonsterUI/MonsterHealth.text = str(monster.health) + "/" + str(monster.max_health)
		$MonsterUI/MonsterBlock.text = str(monster.block)

func change_health(target: AbilityEffect.TARGET, amount: int):
	if target == AbilityEffect.TARGET.PLAYER:
		GameState.player.health = min(GameState.player.health + amount, GameState.player.max_health)
	else:
		monster.health = min(monster.health + amount, monster.max_health)
	#animate?
#	render_health()

func change_block(target: AbilityEffect.TARGET, amount: int):
	if amount > 0:
		var dex_val: int = get_status_value(target, AbilityEffect.TYPE.DEXTERITY)
		amount += dex_val
	if target == AbilityEffect.TARGET.PLAYER:
		GameState.player.block += amount
	else:
		monster.block += amount
	#animate?
#	render_health()

var DAMAGE_NUMBER_SCENE = preload("res://scenes/damagenumbers.tscn")
func inflict_damage(target: AbilityEffect.TARGET, dmg: int):
	if has_status(target, AbilityEffect.TYPE.EVADE):
		# ignore damage if evading
		return
	var cur_block = GameState.player.block 
	if target == AbilityEffect.TARGET.MONSTER:
		cur_block = monster.block
	
	if cur_block > dmg:
		change_block(target, -dmg)
	else:
		change_health(target, cur_block - dmg)
		change_block(target, -cur_block)
	if dmg >= 0:
		var ds = DAMAGE_NUMBER_SCENE.instantiate()
		ds.init(dmg)
		if target == AbilityEffect.TARGET.PLAYER:
			ds.position = Vector2(828,184)
		else:
			ds.position = Vector2(1104,184)
		add_child(ds)


func disable_abilities_and_rerollbtn():
#	animate_abilities_slide(false)
	$Combatscreen/RerollButton.set_disabled(true)
	$Combatscreen/ModeVal.text = "Mode: ? | X=?"
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
				statuses[target].remove_at(i)

func animate_status_changes():
	$Combatscreen/Statuses/PlayerStatusHolder.update_statuses(statuses[0])
	$Combatscreen/Statuses/MonsterStatusHolder.update_statuses(statuses[1])

func compute_damage(base_dmg: int, source: AbilityEffect.TARGET, target: AbilityEffect.TARGET) -> int:
	var dmg = base_dmg
	# first go through strength modifiers
	if source != AbilityEffect.TARGET.NOONE:
		var str:int = get_status_value(source, AbilityEffect.TYPE.STRENGTH)
		dmg += str
		if has_status(source, AbilityEffect.TYPE.EXHAUSTED):
			dmg /= 2.0
	
	if has_status(target, AbilityEffect.TYPE.THIKKSKIN):
		dmg = max(0, dmg - 3)
	if has_status(target, AbilityEffect.TYPE.VULNERABLE):
		dmg *= 2.0
	return dmg

func get_monster_desc() -> String:
	var s:String = monster_intent.desc_
	if s.contains("[D]"):
		for e in monster_intent.effects_:
			if e.type_ == AbilityEffect.TYPE.DAMAGE && e.target_ == AbilityEffect.TARGET.PLAYER:
				var dmg = e.process_value(0,0, rerolls, monster.block, dice_mgr.dice.size() - occurences)
				s = s.replace("[D]", str(compute_damage(dmg, AbilityEffect.TARGET.MONSTER, AbilityEffect.TARGET.PLAYER)))
				break
	if s.contains("[B]"):
		for e in monster_intent.effects_:
			if e.type_ == AbilityEffect.TYPE.SHIELD && e.target_ == AbilityEffect.TARGET.MONSTER:
				var v = e.process_value(0,0, rerolls, monster.block, dice_mgr.dice.size() - occurences)
				s = s.replace("[B]", str(v))
				break
	if s.contains("[S]"):
		for e in monster_intent.effects_:
			if e.type_ == AbilityEffect.TYPE.STRENGTH && e.target_ == AbilityEffect.TARGET.MONSTER:
				var v = e.process_value(0,0, rerolls, monster.block, dice_mgr.dice.size() - occurences)
				s = s.replace("[S]", str(v))
				break
	return s

func _on_monster_intent_enter():
	$MonsterUI/Intent.scale = Vector2.ONE * 1.1
	$MonsterUI/Intent/Description/Label2.text = get_monster_desc() + monster_intent.get_effect_descs()
	$MonsterUI/Intent/Description.show()
	SfxHandler.play_sfx(SfxHandler.PAPER_SFX, self, 1)

func _on_monster_intent_exited():
	$MonsterUI/Intent.scale = Vector2.ONE
	$MonsterUI/Intent/Description.hide()


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

func add_coins(amt: int):
	if GameState.player.has_relic(Relic.TYPE.GREED):
		$RelicHolder.update_relic_type(Relic.TYPE.GREED)
		return
	GameState.player.coins += amt
	anim_coins()

func anim_coins():
	$PlayerUI/PlayerCoins.text = str(GameState.player.coins)
	$PlayerUI/PlayerCoins.scale = Vector2.ONE * 1.5
	var tween = get_tree().create_tween()
	tween.tween_property($PlayerUI/PlayerCoins, "scale", Vector2.ONE, 0.5)
	SfxHandler.play_sfx(SfxHandler.COIN_SFX, self, 0.5)

func update_abilities_with_player_vals(disable:bool):
	for i in 6:
		ability_boxes[i].init(i+1, GameState.player.abilities[i])
	if disable:
		disable_abilities_and_rerollbtn()

func update_abilities_with_current_vals():
	for i in 6:
		if cur_abilities[i].is_disabled:
			ability_boxes[i].init(i+1, Global.disabled_ability)
		else:
			ability_boxes[i].init(i+1, cur_abilities[i].ab)

func init_dice_shop():
	$DiceShopScreen/NextButton.set_disabled(true)
	dice_mgr.line_up_dice_after_roll = true
#	dice_mgr.line_up_dice_after_roll = false
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 4, 5.5)
	dice_mgr.connect("complete_roll", dice_shop_on_complete_roll)
	dice_mgr.mouse_handler.remove_on_select = true
	dice_mgr.clear_dice()
	for i in 5:
		dice_mgr.add_die(DiceConstructor.generate_random_die(), DiceConstructor.generate_random_die_color())
	dice_mgr.drop_all_dice()

func dice_shop_on_complete_roll(_results):
	$DiceShopScreen/NextButton.set_disabled(false)
	dice_mgr.disconnect("complete_roll", dice_shop_on_complete_roll)
	animate_abilities_slide(true)

func end_dice_shop():
	dice_mgr.fade_away_dice()
	dice_mgr.clear_dice()
	generate_next_door_scene()

func process_upgrade():
	animate_abilities_slide(true)
	for ab in ability_boxes:
		ab.connect("ability_clicked", show_preview)
	for i in 6:
		ability_boxes[i].set_enabled(ability_boxes[i].ability.is_upgradeable())

func process_heal():
	$RestScreen/NextButton.set_disabled(true)
	dice_mgr.line_up_dice_after_roll = true
	dice_mgr.mouse_handler.remove_on_select = true
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 4, 5.5)
	dice_mgr.connect("complete_roll", rest_screen_on_roll_complete)
	dice_mgr.clear_dice()
	dice_mgr.add_die([1,2,6,5,3,4], Color.DARK_RED)
	dice_mgr.add_die([1,2,6,5,3,4], Color.DARK_RED)
	if GameState.player.has_relic(Relic.TYPE.DWARVEN_MEAD):
		$RelicHolder.update_relic_type(Relic.TYPE.DWARVEN_MEAD)
		dice_mgr.add_die([1,2,6,5,3,4], Color.DARK_RED)
		dice_mgr.add_die([1,2,6,5,3,4], Color.DARK_RED)
	dice_mgr.drop_all_dice()

func rest_screen_on_roll_complete(_results):
	$RestScreen/NextButton.set_disabled(false)
	dice_mgr.disconnect("complete_roll", rest_screen_on_roll_complete)

func show_preview(val):
	$RestScreen.show_preview(val, Global.get_upgraded_ability(ability_boxes[val - 1].ability))

func end_rest_scene():
	dice_mgr.fade_away_dice()
	dice_mgr.clear_dice()
	disable_abilities_and_rerollbtn()
	for ab in ability_boxes:
		if ab.is_connected("ability_clicked", show_preview):
			ab.disconnect("ability_clicked", show_preview)
	generate_next_door_scene()

func init_ritual_scene():
	ritual_count += 1
	$RitualScreen/NextButton.set_disabled(true)
	dice_mgr.line_up_dice_after_roll = true
#	dice_mgr.line_up_dice_after_roll = false
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 9.5, 5.5)
	dice_mgr.connect("complete_roll", ritual_screen_on_roll_complete)
	dice_mgr.mouse_handler.remove_on_select = true
	dice_mgr.clear_dice()
	for d in GameState.player.dice:
		dice_mgr.add_die(d[0], d[1])
	dice_mgr.drop_all_dice()

func ritual_screen_on_roll_complete(_results):
	$RitualScreen/NextButton.set_disabled(false)
	dice_mgr.disconnect("complete_roll", ritual_screen_on_roll_complete)

func sacrificed_die(index:int):
	GameState.player.dice.remove_at(index)
	$RitualScreen.sacrificed_die()
	await wait_secs(0.2)
	dice_mgr.fade_away_dice()
	dice_mgr.clear_dice()

func end_ritual_scene():
	dice_mgr.fade_away_dice()
	dice_mgr.clear_dice()
	
	if GameState.player.has_relic(Relic.TYPE.CULTIST_HEAD) && ritual_count < 2:
		$RelicHolder.update_relic_type(Relic.TYPE.CULTIST_HEAD)
		init_ritual_scene()
	else:
		generate_next_door_scene()

func has_status(c: AbilityEffect.TARGET, t: AbilityEffect.TYPE) -> bool:
	for s in statuses[c]:
		if s.type == t:
			return true
	return false

func get_status(c: AbilityEffect.TARGET, t: AbilityEffect.TYPE) -> Status:
	for s in statuses[c]:
		if s.type == t:
			return s
	return null

func get_status_value(c: AbilityEffect.TARGET, t: AbilityEffect.TYPE) -> int:
	var s: Status = get_status(c, t)
	if s == null:
		return 0
	return s.amount

func render_relics():
	$RelicHolder.update_relics()

func return_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
#	var s = MENU_SCENE.instantiate()
#	get_tree().root.add_child(s)
#	queue_free()

func end_loot_screen():
	if monster.is_boss:
		go_to_scene(GameState.GameScene.BOSSLOOT)
	else:
		go_to_scene(GameState.GameScene.SELECT_ABILITY)

func close_tutorial():
	$tutorial.hide()
	$MonsterUI.show()
	$Combatscreen.show()
	process_start_combat()

func open_tutorial():
	$tutorial.show()
