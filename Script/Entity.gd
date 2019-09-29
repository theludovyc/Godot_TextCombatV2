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
	if i>=(arm+pv):
		pv=0
		arm=0
		return true
	elif i==arm:
		arm=0
		return false
	i-=arm
	arm=0
	if i>=pv:
		pv=0
		return true
	pv-=i
	return false

func getDifDegMaxMin():
	return degMax-degMin

func testAttack():
	if randf()<=cc:
		return true
	return false

func attack():
	return Helper.rand_between(degMin, degMax)