extends "ItemEquipe.gd"

func _init(i).(i, "Ceinture", false):
	pass

func use(e):
	e.setForce(item_var)

func checkCarac(e):
	return item_var-e.fr