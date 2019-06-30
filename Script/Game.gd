extends Node

var Player=preload("EntityPlayer.gd")
var Monster=preload("EntityMonster.gd")

var items=[preload("ItemPotionVie.gd"), 
preload("ItemArmure.gd"),
preload("ItemEpee.gd"),
preload("ItemCeinture.gd"),
preload("ItemBotte.gd")]

var hero=Player.new()
var mob=Monster.new()

var labels
var labels_index=0

var state=0

var mob_doAttack=false
var hero_doAttack=false

var heroTurn=false

var hero_press=false
var hero_key0=false
var hero_key1=false
var hero_key2=false
var hero_key3=false

var treasure

var lvl=1

var hero_def=0

var hero_restore_ed=false
var mob_restore_ed=false

func addLine():
	$RTL.newline()
	
	if $RTL.get_line_count() > 10:
		$RTL.remove_line(0)

func addText(s):
	$RTL.add_text(s)

func openDoor():
	addText("--- "+hero.name()+" ouvre une porte("+str(lvl)+").")

func apparation():
	if(lvl%10==0):
		mob.initBoss(lvl)
	else:
		mob.initMonster(lvl)

	addText("Un "+mob.name()+" apparait !")

func writeDamage(i):
	addText(" inflige ")
	$RTL.push_color(Color.rosybrown)
	addText(str(i))
	$RTL.pop()
	addText(" dégat(s).")

func checkIni():
	if hero.ini<mob.ini:
		addText(hero.name())
		heroTurn=true
		aide_setText("A. Def Z. Atk++ E. Atk")
		hero_press=true
		setKeys(true, true, true, false)
	else:
		addText(mob.name())
		heroTurn=false
	addText(" attaque en premier.")

func bonusDef():
	hero.cc+=0.1
	hero_def=1

func malusDef():
	hero.cc-=0.4
	hero_def=2

func disableDef():
	match hero_def:
		0:
			return
		1:
			hero.cc-=0.1
			hero_def=0
		2:
			hero.cc+=0.4
			hero_def=0

func aide_addText(s):
	$Label11.text+=s

func aide_setText(s):
	$Label11.text=s

func setKeys(b0, b1, b2, b3):
	hero_key0=b0
	hero_key1=b1
	hero_key2=b2
	hero_key3=b3

func newTreasure():
	var id=0

	if lvl%10!=0:
		id=Helper.rand_between(0, items.size()-1)

	treasure=items[id].new(lvl)

func todo():
	match state:
		0:
			addLine()
			openDoor()
			state+=1
		1:
			addLine()
			apparation()
			state+=1
		2:
			addLine()
			checkIni()
			state+=1
		3:
			addLine()
			if !heroTurn:
				mob_doAttack=true

				if mob.testAttack():
					addText(mob.name()+" attaque, ")

					var b=true

					if hero.testAttack():
						addText("mais "+hero.name+" se défend !")
						b=false

					disableDef()
					
					if b:
						addText("et ")
						writeDamage(hero.remPv( mob.attack() ))

						if hero.pv<1:
							state+=2
							return
				else:
					disableDef()

					addText(mob.name()+" rate son attaque.")

				heroTurn=true
				aide_setText("A. Def Z. Atk++ E. Atk")
				hero_press=true
				setKeys(true, true, true, false)
			else:
				hero_doAttack=true
				heroTurn=false

				if !hero_key0:
					bonusDef()
					hero.setToArmMax()
					addText(hero.name+" prépare sa défense.")
				else:
					if hero.testAttack():
						var damage=hero.attack()

						if !hero_key1:
							malusDef()
							damage*=2

						addText(hero.name())
						writeDamage(mob.remPv( damage ))

						if mob.pv<=0:
							state+=1
							return
					else:
						addText(hero.name()+" rate son attaque.")

			if mob_doAttack and hero_doAttack:
				state+=3
		4:
			disableDef()
			
			addLine()
			addText(mob.name+" est mort.")

			if(lvl==100):
				state=16
				return
			
			state+=3

		5:
			addLine()
			addText(hero.name+" est mort.")
			state+=3

		6:
			addLine()
			mob_doAttack=false
			hero_doAttack=false
			addText("- Nouveau tour")
			state-=3

		7:
			addLine()
			addText("-- "+hero.name()+" a trouvé un trésor.")
			state+=2

		8:
			addLine()
			addText("Fin de la partie, merci d'avoir joué !")
			aide_setText("A. Prier Z. Abandonner")

			hero_press=true
			setKeys(true, true, false, false)

			state+=3

		9:
			addLine()
			newTreasure()

			addText("C'est ")

			if treasure.genre:
				addText("un ")
			else:
				addText("une ")

			addText(treasure.name(hero)+" !")

			if treasure.equip:
				aide_setText("A. Equiper ")
			else:
				aide_setText("A. Utiliser ")

			aide_addText("Z. Laisser")

			hero_press=true
			setKeys(true, true, false, false)

			state+=1

		10:
			hero.pvMax+=1

			if !hero_key0:
				addLine()
				treasure.use(hero)

				addText(hero.name)

				if treasure.equip:
					addText(" s'en equipe.")
				else:
					addText(" l'utilise.")

				treasure=null
			elif !hero_key1:
				addLine()
				addText(hero.name+" continu son chemin.")

			mob_doAttack=false
			hero_doAttack=false
			hero.setToArmMax()
			lvl+=1
			state=0

		11:
			if !hero_key0:
				addLine()
				addText("Un ange a entendu votre prière...")
				state+=1
			elif !hero_key1:
				get_tree().quit()

		12:
			addLine()
			addText("Il accepte de vous réanimer...")
			state+=1

		13:
			addLine()
			addText("En échange de votre équipement...")

			state+=1

		14:
			addLine()
			addText("Et si vous prenez un nouveau départ...")

			aide_setText("A. Accepter Z. Refuser")

			hero_press=true
			setKeys(true, true, false, false)

			state+=1

		15:
			if !hero_key0:
				randomize()

				lvl=1

				hero._init()

				addLine()
				openDoor()

				state=1
			elif !hero_key1:
				get_tree().quit()

		16:
			addLine()
			addText("Vous êtes venu à bout du dernier Boss...")
			state+=1

		17:
			addLine()
			addText("Félicitation !!!")
			state+=1

		18:
			addLine()
			addText("Fin de la partie, merci d'avoir joué !")
			aide_setText("A. Recommencer Z. Quitter")
			hero_press=true
			setKeys(true, true, false, false)
			state=15

func _ready():
	randomize()

	labels=[$Label10, $Label9, $Label8, $Label7, $Label6, $Label5, $Label4, $Label3, $Label2, $Label]

	openDoor()

	state=1

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if !hero_press and Input.is_action_just_pressed("ui_accept"):
		todo()
	else:
		if hero_key0 and Input.is_action_just_pressed("MyKey_0"):
			hero_key0=false
			todo()
			aide_setText("")
			hero_press=false
		elif hero_key1 and Input.is_action_just_pressed("MyKey_1"):
			hero_key1=false
			todo()
			aide_setText("")
			hero_press=false
		elif hero_key2 and Input.is_action_just_pressed("MyKey_2"):
			hero_key2=false
			todo()
			aide_setText("")
			hero_press=false
	pass
