extends Node

signal tooltip_obj_entered(obj:Object, time_to_show_sec:float, display:ToolTip.DISPLAY)
signal tooltip_obj_clicked(obj:Object, time_to_show_sec:float, display:ToolTip.DISPLAY)
signal tooltip_obj_exited(obj:Object)

signal coins_updated()
signal health_updated()
signal abilities_updated(disable:bool)
signal relics_updated()

signal sacrificed_die(index:int)
