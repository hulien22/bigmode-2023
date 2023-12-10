extends Node2D

signal gg_go_next()
signal begin_upgrade()
signal begin_heal()

func _ready():
	$NextButton.connect("pressed", _on_nextbtn_pressed)
	$Rest/Button.connect("mouse_entered", _on_button_mouse_entered.bind($Rest))
	$Rest/Button.connect("mouse_exited", _on_button_mouse_exited.bind($Rest))
	$Rest/Button.connect("pressed", heal)
	$Upgrade/Button.connect("mouse_entered", _on_button_mouse_entered.bind($Upgrade))
	$Upgrade/Button.connect("mouse_exited", _on_button_mouse_exited.bind($Upgrade))
	$Upgrade/Button.connect("pressed", upgrade)
	$AbilityPreview/ability_box.connect("ability_clicked", upgrade_ability)

func init():
	$NextButton.hide()
	if GameState.player.has_upgradeable_ability():
		$Upgrade/Text2.text = "Upgrade"
		$Upgrade.show()
		$Upgrade/Button.disabled = false
	else:
		$Upgrade/Text2.text = "No abilities to upgrade"
		$Upgrade.show()
		$Upgrade/Button.disabled = true
	$Rest.show()
	$AbilityPreview.hide()
	$Text.text = "You find a nice empty room to catch your breath.."

func _on_nextbtn_pressed():
	gg_go_next.emit()

func _on_button_mouse_entered(obj):
	obj.scale = Vector2.ONE * 1.5

func _on_button_mouse_exited(obj):
	obj.scale = Vector2.ONE

func heal():
	begin_heal.emit()
	$NextButton.show()
	$Upgrade.hide()
	$Rest.hide()
	$Text.text = "You spend some time to tend to your wounds\n\n(Click on dice to heal)"

func upgrade():
	begin_upgrade.emit()
	$Upgrade.hide()
	$Rest.hide()
	$Text.text = "Pick an ability to upgrade"
	$AbilityPreview.hide()

var ua:Ability
func show_preview(v: int, upgraded: Ability):
	ua = upgraded
	$AbilityPreview/ability_box.init(v, upgraded)
	$AbilityPreview/ability_box.set_enabled(true)
	$AbilityPreview.show()

func upgrade_ability(val: int):
	if ua:
		GameState.player.abilities[val - 1] = ua
		$Text.text = "You spend some time practicing your moves - ability upgraded!"
		Events.emit_signal("abilities_updated", true)
		$AbilityPreview.hide()
		$NextButton.show()
	
