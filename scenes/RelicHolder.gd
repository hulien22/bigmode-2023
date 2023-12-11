extends Node2D

const RELIC_OBJ_SCENE = preload("res://scenes/relicobj.tscn")
var relics: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	relics = []

func clear():
	for r in relics:
		r.queue_free()
	relics.clear()

func update_relics():
	#assume can only add relics
	for r in range(relics.size(), GameState.player.relics.size()):
		var robj = RELIC_OBJ_SCENE.instantiate()
		robj.relic = GameState.player.relics[r]
		robj.position = Vector2(0, relics.size() * 80)
		$Relics.add_child(robj)
		relics.append(robj)
		update_relic(relics.size() - 1)

func update_relic(i:int):
	relics[i].update_sprite()
	relics[i].animate()

func update_relic_type(t:Relic.TYPE):
	for i in relics.size():
		if relics[i].relic.type == t:
			update_relic(i)
			return
