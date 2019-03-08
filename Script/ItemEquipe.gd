extends "Item.gd"

func _init(i, s, b).(i, s, b):
	equip=true

func checkCarac(e):
	pass

func name(e):
	var i=checkCarac(e)
	if i>0:
		return name+"(+"+str(i)+")"
	return name+"("+str(i)+")"