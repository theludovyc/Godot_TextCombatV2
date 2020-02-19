class_name Entity

var name:String

#point de vie
var pv:int
var pvMax:int

#armure
var arm:int
var armMax:int

#defense
var defLvl = 1

#capacite de combat
var cc:float

#degat
var degMin:int
var degMax:int

#initiative
var ini:int

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

func testDef0():
	match(defLvl):
		0:
			return (randf() <= 0.25)
			
		1:
			return (randf() <= 0.5)
		
		2:
			return (randf() <= 0.75)

func testDef(mod:int):
	match(int(clamp(defLvl + mod, 0, 2 ) ) ):
		0:
			return (randf() <= 0.25)
			
		1:
			return (randf() <= 0.5)
		
		2:
			return (randf() <= 0.75)

func addDef():
	if defLvl < 2:
		defLvl += 1

func remDef():
	if defLvl > 0:
		defLvl -= 1

func doDef():
	addDef()

func getDifDegMaxMin():
	return degMax-degMin

func testAttack():
	return (randf() <= cc)

func getDamage():
	return Helper.rand_between(degMin, degMax)
