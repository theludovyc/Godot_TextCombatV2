extends "Entity.gd"

func initMonster(i):
	name="Monstre"

	pv=i
	pvMax=i

	armMax=Helper.rand_between(i*0.25, i*0.75)
	arm=armMax

	cc=Helper.rand_between(25, 75)/100.0

	ini=Helper.rand_between(1,10)

	degMax=i

	if i>3:
		degMin=degMax-3
		return

	degMin=1
	pass

func initBoss(i):
	name="Boss"

	pv=i
	pvMax=i

	armMax=int(i*0.75)
	arm=armMax

	cc=i/100.0

	degMin=i
	degMax=i

	ini=1
	pass
	
