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
	monster = Monster.new()
	render_health()
	add_coins(0)
	go_to_scene(GameState.GameScene.INTRO)
	for i in 6:
		ability_boxes[i].init(i+1, GameState.player.abilities[i])
	
	Events.connect("coins_updated", anim_coins)
	Events.connect("health_updated", render_health)
	Events.connect("abilities_updated", update_abilities)
	Events.connect("sacrificed_die", sacrificed_die)
#	process_start_combat()

func go_to_scene(gs: GameState.GameScene):
	GameState.game_scene = gs
	hide_all_scenes()
	match gs:
		GameState.GameScene.INTRO:
			var doors:Array[GameState.GameScene] = [GameState.GameScene.COMBAT]
#			var doors:Array[GameState.GameScene] = [GameState.GameScene.SELECT_ABILITY]
			$DoorChoiceScreen.init(doors, "After a long trek you finally made it to the dungeon entrance..\nYou take a deep breath and enter through the front door")
			$DoorChoiceScreen.connect("door_selected", _on_door_selected)
			$DoorChoiceScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.DOORS:
			var doors:Array[GameState.GameScene] = GameState.generate_next_doors()
			print("LEVEL: ", GameState.level, "DOORS: ", doors)
			if doors.size() == 1:
				$DoorChoiceScreen.init(doors, "You find yourself in front of a large door")
			else:
				$DoorChoiceScreen.init(doors, "You find yourself in front of two doors\nPick a door")
			$DoorChoiceScreen.connect("door_selected", _on_door_selected)
			$DoorChoiceScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.COMBAT:
			$MonsterUI.show()
			$Combatscreen.show()
			process_start_combat()
		GameState.GameScene.SELECT_ABILITY:
			var new_abs:Array[Ability] = [Global.abilities[2], Global.abilities[3], Global.abilities[6]]
			$AbilityChoiceScreen.init(ability_boxes, new_abs)
			$AbilityChoiceScreen.connect("gg_go_next", generate_next_door_scene)
			$AbilityChoiceScreen.show()
			animate_abilities_slide(true)
		GameState.GameScene.LOOT:
			var c = 2 if monster == null else monster.coins_dropped
			$LootScreen.init(c, null)
			$LootScreen.connect("gg_go_next", go_to_scene.bind(GameState.GameScene.SELECT_ABILITY))
			$LootScreen.connect("add_coins", add_coins)
			$LootScreen.show()
			animate_abilities_slide(false)
		GameState.GameScene.DICE_SHOP:
			$DiceShopScreen.connect("gg_go_next", end_dice_shop)
			$DiceShopScreen.show()
			animate_abilities_slide(false)
			#start dice rolls
			init_dice_shop()
		GameState.GameScene.REST:
			$RestScreen.connect("gg_go_next", end_rest_scene)
			$RestScreen.show()
			$RestScreen.connect("begin_upgrade", process_upgrade)
			animate_abilities_slide(false)
		GameState.GameScene.RITUAL:
			$RitualScreen.connect("gg_go_next", end_ritual_scene)
			$RitualScreen.show()
			init_ritual_scene()
			animate_abilities_slide(false)


func hide_all_scenes():
	$MonsterUI.hide()
	$Combatscreen.hide()
	$DoorChoiceScreen.hide()
	$AbilityChoiceScreen.hide()
	$LootScreen.hide()
	$DiceShopScreen.hide()
	$RestScreen.hide()
	$RitualScreen.hide()


func generate_next_door_scene():
	go_to_scene(GameState.GameScene.DOORS)


func _on_door_selected(gs: GameState.GameScene):
	go_to_scene(gs)
	GameState.level += 1


func process_start_combat():
	disable_abilities_and_rerollbtn()
	monster.init_slime()
	$MonsterUI/character2.init(monster.image)
	$MonsterUI/MonsterName.text = monster.name_
	update_abilities(false)
#	$Abilities/ability_box1.init(1, GameState.player.abilities[0])
#	$Abilities/ability_box2.init(2, GameState.player.abilities[1])
#	$Abilities/ability_box3.init(3, GameState.player.abilities[2])
#	$Abilities/ability_box4.init(4, GameState.player.abilities[3])
#	$Abilities/ability_box5.init(5, GameState.player.abilities[4])
#	$Abilities/ability_box6.init(6, GameState.player.abilities[5])
	for ab in ability_boxes:
		ab.connect("ability_clicked", _on_ability_clicked)
	$Combatscreen/RerollButton.connect("pressed", _on_reroll_button_pressed)
	dice_mgr.line_up_dice_after_roll = true
	dice_mgr.mouse_handler.remove_on_select = false
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 9.5, 5.5)
	dice_mgr.connect("complete_roll", _on_complete_roll)
	dice_mgr.dice.clear()
	for d in GameState.player.dice:
		dice_mgr.add_die(d[0], d[1])
	turn_counter = -1
	rerolls = 3
	statuses = [[], []]
	GameState.player.block = 0
	
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
	$MonsterUI/Intent/MonsterIntent.text = monster_intent.name_
	_on_monster_intent_exited()
#	print("monster intent: ", monster_intent.name_)
	
	$Combatscreen/RerollButton.disabled = false
	$Combatscreen/RerollButton.text = "ROLL"
	$Combatscreen/ModeVal.text = "Mode: ? | X=?"
	

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
	$Combatscreen/ModeVal.text = "Mode=" + ",".join(modes) + " | X=" + str(occurences)
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
	var d:Dictionary = process_ability(ability_boxes[val-1].ability, val, false)
	if d.get("deplete_ability", false):
		ability_boxes[val-1].init(val, Global.depleted_ability)
	
#	animate_status_changes()
	
	# check if anyone died
	
	$PlayerUI/character.play_attack()
	await wait_secs(0.5)
	animate_status_changes()
	render_health()
	await wait_secs(0.5)
	
	if monster.health <= 0:
		combat_win()
		return
	if GameState.player.health <= 0:
		combat_loss()
		return
	
	process_monster_turn()

func process_monster_turn():
	combat_state = CombatState.MONSTER_ABILITY
	process_ability(monster_intent, 0, true)
	
	$MonsterUI/character2.play_attack()
	await wait_secs(0.5)
	animate_status_changes()
	render_health()
	await wait_secs(0.5)
	
	if monster.health <= 0:
		combat_win()
		return
	if GameState.player.health <= 0:
		combat_loss()
		return
	
	process_end_turn()

func process_ability(ability: Ability, face:int, inflict_status_later: bool) -> Dictionary:
	var dict:Dictionary = {}
	for effect in ability.effects_:
		if inflict_status_later && effect.is_status_inflict() && effect.target_ == AbilityEffect.TARGET.PLAYER:
			statuses_to_inflict.append(effect)
			continue
		var d:Dictionary = process_effect(effect, face)
		if d.get("deplete_ability", false):
			dict["deplete_ability"] = true
	#TODO: return type of animation to play (instead of just attack always)
	return dict

# returns bool if ability is now depleted
func process_effect(effect: AbilityEffect, face:int = 0) -> Dictionary:
	var dict:Dictionary = {}
	match effect.type_:
		AbilityEffect.TYPE.DAMAGE:
			var dmg = effect.process_value(occurences, face)
			# process other statuses (eg strength, weaknesses)
			inflict_damage(effect.target_, max(0, compute_damage(dmg, (effect.target_ + 1) % 2, effect.target_)))
		AbilityEffect.TYPE.SHIELD:
			var amt = effect.process_value(occurences, face)
			# process other statuses (eg strength)
			change_block(effect.target_, amt)
		AbilityEffect.TYPE.VULNERABLE:
			var amt = effect.process_value(occurences, face)
			# process other statuses (eg strength)
			add_status(effect.target_, AbilityEffect.TYPE.VULNERABLE, amt, true)
		AbilityEffect.TYPE.STRENGTH:
			var amt = effect.process_value(occurences, face)
			# process other statuses (eg strength)
			add_status(effect.target_, AbilityEffect.TYPE.STRENGTH, amt, false)
		AbilityEffect.TYPE.LIMITED_USES:
			effect.uses_left -= 1
			if effect.uses_left <= 0:
				dict["deplete_ability"] = true
		AbilityEffect.TYPE.HEAL:
			var amt = effect.process_value(occurences, face)
			change_health(effect.target_, -1 * amt)
		AbilityEffect.TYPE.SELF_DMG:
			var dmg = effect.process_value(occurences, face)
			# don't include strength, do include vulnerable
			inflict_damage(effect.target_, max(0, compute_damage(dmg, AbilityEffect.TARGET.NOONE, effect.target_)))
	return dict

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

func combat_win():
	print("MONSTER DIED")
	combat_state = CombatState.END_COMBAT
	
	for ab in ability_boxes:
		ab.disconnect("ability_clicked", _on_ability_clicked)
	$Combatscreen/RerollButton.disconnect("pressed", _on_reroll_button_pressed)
	dice_mgr.disconnect("complete_roll", _on_complete_roll)
	dice_mgr.dice.clear()
	turn_counter = -1
	rerolls = 3
	statuses = [[], []]
	GameState.player.block = 0
	
	$MonsterUI/character2.play_fade_die()
	animate_status_changes()
	await wait_secs(0.5)
	
	update_abilities(false)
	#generate loot scene
		# coins, and relic
	# which will then generate the ability screen
	go_to_scene(GameState.GameScene.LOOT)

func combat_loss():
	print("YOU DIED")
	pass

func process_relics():
	for r in GameState.player.relics:
		r.process_relic(self)

func render_health():
	$PlayerUI/PlayerHealth.text = str(GameState.player.health) + "/" + str(GameState.player.max_health)
	$PlayerUI/PlayerBlock.text = str(GameState.player.block)
	if monster && GameState.game_scene == GameState.GameScene.COMBAT:
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

func get_monster_desc() -> String:
	var s:String = monster_intent.desc_
	if s.contains("[D]"):
		for e in monster_intent.effects_:
			if e.type_ == AbilityEffect.TYPE.DAMAGE && e.target_ == AbilityEffect.TARGET.PLAYER:
				var dmg = e.process_value(0,0)
				s = s.replace("[D]", str(compute_damage(dmg, AbilityEffect.TARGET.MONSTER, AbilityEffect.TARGET.PLAYER)))
				break
	if s.contains("[B]"):
		for e in monster_intent.effects_:
			if e.type_ == AbilityEffect.TYPE.SHIELD && e.target_ == AbilityEffect.TARGET.MONSTER:
				var v = e.process_value(0,0)
				s = s.replace("[B]", str(v))
				break
	if s.contains("[S]"):
		for e in monster_intent.effects_:
			if e.type_ == AbilityEffect.TYPE.STRENGTH && e.target_ == AbilityEffect.TARGET.MONSTER:
				var v = e.process_value(0,0)
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
	GameState.player.coins += amt
	anim_coins()

func anim_coins():
	$PlayerUI/PlayerCoins.text = str(GameState.player.coins)
	$PlayerUI/PlayerCoins.scale = Vector2.ONE * 1.5
	var tween = get_tree().create_tween()
	tween.tween_property($PlayerUI/PlayerCoins, "scale", Vector2.ONE, 0.5)

func update_abilities(disable:bool):
	for i in 6:
		ability_boxes[i].init(i+1, GameState.player.abilities[i])
	if disable:
		disable_abilities_and_rerollbtn()

func init_dice_shop():
	$DiceShopScreen/NextButton.disabled = true
	dice_mgr.line_up_dice_after_roll = true
#	dice_mgr.line_up_dice_after_roll = false
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 4, 5.5)
	dice_mgr.connect("complete_roll", dice_shop_on_complete_roll)
	dice_mgr.mouse_handler.remove_on_select = true
	dice_mgr.dice.clear()
	for i in 5:
		dice_mgr.add_die(DiceConstructor.generate_random_die(), DiceConstructor.generate_random_die_color())
	dice_mgr.drop_all_dice()

func dice_shop_on_complete_roll(_results):
	$DiceShopScreen/NextButton.disabled = false
	dice_mgr.disconnect("complete_roll", dice_shop_on_complete_roll)

func end_dice_shop():
	dice_mgr.fade_away_dice()
	dice_mgr.dice.clear()
	generate_next_door_scene()

func process_upgrade():
	animate_abilities_slide(true)
	for ab in ability_boxes:
		ab.connect("ability_clicked", show_preview)
	for i in 6:
		ability_boxes[i].set_enabled(ability_boxes[i].ability.is_upgradeable())

func show_preview(val):
	$RestScreen.show_preview(val, Global.get_upgraded_ability(ability_boxes[val - 1].ability))

func end_rest_scene():
	disable_abilities_and_rerollbtn()
	for ab in ability_boxes:
		ab.disconnect("ability_clicked", show_preview)
	generate_next_door_scene()

func init_ritual_scene():
	$RestScreen/NextButton.disabled = true
	dice_mgr.line_up_dice_after_roll = true
#	dice_mgr.line_up_dice_after_roll = false
	dice_mgr.dice_box_rect = Rect2(-7, -1.5, 9.5, 5.5)
	dice_mgr.connect("complete_roll", ritual_screen_on_roll_complete)
	dice_mgr.mouse_handler.remove_on_select = true
	dice_mgr.dice.clear()
	for d in GameState.player.dice:
		dice_mgr.add_die(d[0], d[1])
	dice_mgr.drop_all_dice()

func ritual_screen_on_roll_complete(_results):
	$RestScreen/NextButton.disabled = false
	dice_mgr.disconnect("complete_roll", ritual_screen_on_roll_complete)

func sacrificed_die(index:int):
	GameState.player.dice.remove_at(index)
	$RitualScreen.sacrificed_die()
	await wait_secs(0.2)
	dice_mgr.fade_away_dice()
	dice_mgr.dice.clear()

func end_ritual_scene():
	dice_mgr.fade_away_dice()
	dice_mgr.dice.clear()
	generate_next_door_scene()

