extends "Item.gd"

var degMin=0

func _init(i).(i, "Epee", false):
	equip=true

	if item_var>5:
		degMin=Helper.rand_between(item_var-5, item_var)
		return
	
	degMin=1

func use(e):
	e.setDegMinMax(degMin, item_var)

func name(e):
	var j=degMin-e.degMin
	var j1=item_var-e.degMax

	var s=name+"("

	if j>0:
		s+="+"

	s+=str(j)+", "

	if j1>0:
		s+="+"

	return s+str(j1)+")"