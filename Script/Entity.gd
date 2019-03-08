var name

#point de vie
var pv
var pvMax

#armure
var arm
var armMax

#capacite de combat
var cc

#degat
var degMin
var degMax

#initiative
var ini

func name():
	var s=name+"("+str(pv)

	if arm>0:
		s+=", "+str(arm)
		
	return s+")"

func setToPvMax():
	pv=pvMax

func addPv(i):
	pv+=i
	if pv>pvMax:
		pv=pvMax

func setToArmMax():
	arm=armMax

func remPv(i):
	if arm>0:
		if i==arm:
			arm=0
			return 0
		else:
			if i>arm:
				i-=arm
				pv-=i
				arm=0
				return i
			
			arm-=i
			return 0
	
	pv-=i
	return i

func getDifDegMaxMin():
	return degMax-degMin

func testAttack():
	if randf()<=cc:
		return true
	return false

func attack():
	return Helper.rand_between(degMin, degMax)