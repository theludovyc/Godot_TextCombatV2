extends "ItemEquipe.gd"

func _init(i).(i, "Armure", false):
	item_var=int(item_var*0.75)
	pass

func use(e):
	e.arm=item_var
	e.armMax=item_var

func checkCarac(e):
	return item_var-e.armMax