extends Node

var Player=preload("EntityPlayer.gd")
var Monster=preload("EntityMonster.gd")

var items=[preload("ItemPotionVie.gd"), 
preload("ItemArmure.gd"),
preload("ItemEpee.gd"),
preload("ItemCeinture.gd"),
preload("ItemBotte.gd")]

var string_buffer = []

var hero=Player.new()
var mob=Monster.new()

var labels
var labels_index=0

enum {PLAYER_ATTACK}

var state=0

var player_attack=false
var monster_attack=false

var mob_doAttack=false
var hero_doAttack=false

var heroTurn=false

var player_key:int
var player_keyMax:int

var hero_press=false
var hero_key0=false
var hero_key1=false
var hero_key2=false
var hero_key3=false

var treasure

var lvl=0

var hero_def=0

var hero_restore_ed=false
var mob_restore_ed=false

func addLine():
	$RTL.newline()
	
	if $RTL.get_line_count() > 10:
		$RTL.remove_line(0)

func addText():
	$RTL.add_text(string_buffer.pop_back())

func buffer_addLine(s):
	string_buffer.push_front(s)
	
func buffer_addText(s):
	string_buffer[0] += s

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

func help_setText(s):
	$Label11.text=s

func help_setVisibiliy(b):
	$Label11.visible=b

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

func writeDamage(i):
	buffer_addText("inflige "+str(i)+" dégat(s).")

func monsterAttack():
	monster_attack=true

	buffer_addLine(mob.name())

	if mob.testAttack():
		buffer_addText(" attaque, ")

		if hero.testAttack():
			buffer_addText("mais "+hero.name()+" se défend !")
			return false
		else:
			var dam = mob.attack()
			buffer_addText("et ")
			writeDamage(dam)

			if hero.remPv(dam):
				return true
			else:
				return false
	
	buffer_addText(mob.name()+" rate son attaque.")
	return false

func checkIni():
	var b:=false
	
	if hero.ini>mob.ini:
		buffer_addLine(hero.name())
		b=true
	else:
		buffer_addLine(mob.name())
		
	buffer_addText(" attaque en premier.")
	
	return b

func todo_newTurn():
	player_attack=false
	monster_attack=false
	
	if !checkIni():
		if monsterAttack():
			print("PLAYER_DEATH")
	
	state=PLAYER_ATTACK
	
	print(state)

func apparation():
	if(lvl%10==0):
		mob.initBoss(lvl)
	else:
		mob.initMonster(lvl)

	buffer_addLine("Un "+mob.name()+" apparait !")
	
func openDoor():
	buffer_addLine("--- "+hero.name()+" ouvre une porte("+str(lvl)+").")

func todo_start():
	lvl+=1
	openDoor()
	apparation()
	todo_newTurn()

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
			if mob_doAttack and hero_doAttack:
				state+=3
		4:
			disableDef()
			
			addLine()
			buffer_addText(mob.name+" est mort.")

			if(lvl==100):
				state=16
				return
			
			state+=3

		5:
			addLine()
			buffer_addText(hero.name+" est mort.")
			state+=3

		6:
			addLine()
			mob_doAttack=false
			hero_doAttack=false
			buffer_addText("- Nouveau tour")
			state-=3

		7:
			addLine()
			buffer_addText("-- "+hero.name()+" a trouvé un trésor.")
			state+=2

		8:
			addLine()
			buffer_addText("Fin de la partie, merci d'avoir joué !")
			aide_setText("A. Prier Z. Abandonner")

			hero_press=true
			setKeys(true, true, false, false)

			state+=3

		9:
			addLine()
			newTreasure()

			buffer_addText("C'est ")

			if treasure.genre:
				buffer_addText("un ")
			else:
				buffer_addText("une ")

			buffer_addText(treasure.name(hero)+" !")

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

				buffer_addText(hero.name)

				if treasure.equip:
					buffer_addText(" s'en equipe.")
				else:
					buffer_addText(" l'utilise.")

				treasure=null
			elif !hero_key1:
				addLine()
				buffer_addText(hero.name+" continu son chemin.")

			mob_doAttack=false
			hero_doAttack=false
			hero.setToArmMax()
			lvl+=1
			state=0

		11:
			if !hero_key0:
				addLine()
				buffer_addText("Un ange a entendu votre prière...")
				state+=1
			elif !hero_key1:
				get_tree().quit()

		12:
			addLine()
			buffer_addText("Il accepte de vous réanimer...")
			state+=1

		13:
			addLine()
			buffer_addText("En échange de votre équipement...")

			state+=1

		14:
			addLine()
			buffer_addText("Et si vous prenez un nouveau départ...")

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
			buffer_addText("Vous êtes venu à bout du dernier Boss...")
			state+=1

		17:
			addLine()
			buffer_addText("Félicitation !!!")
			state+=1

		18:
			addLine()
			buffer_addText("Fin de la partie, merci d'avoir joué !")
			aide_setText("A. Recommencer Z. Quitter")
			hero_press=true
			setKeys(true, true, false, false)
			state=15

func _ready():
	randomize()

	labels=[$Label10, $Label9, $Label8, $Label7, $Label6, $Label5, $Label4, $Label3, $Label2, $Label]

	todo_start()
	
	addText()

func playerAttack():
	player_attack=true

	if player_key==2:
		#bonusDef()
		hero.setToArmMax()
		buffer_addLine(hero.name()+" prépare sa défense.")
		return false
		
	if hero.testAttack():
		var damage=hero.attack()

		if player_key==1:
			#malusDef()
			damage*=2

		buffer_addText(hero.name())
		writeDamage(damage)

		if mob.remPv(damage):
			return true
		else:
			return false

	buffer_addText(hero.name()+" rate son attaque.")
	return false

func todo1():
	if player_key<=player_keyMax:
		help_setVisibiliy(false)
		match state:
			PLAYER_ATTACK:
				if playerAttack():
					#MONSTER_DEATH
					buffer_addLine(mob.name()+" est mort.")
					buffer_addLine(hero.name()+" a trouvé un trésor!")
					pass

func todo_help():
	match state:
		PLAYER_ATTACK:
			help_setText("a.Atk z.Atk++ e.Def")
			help_setVisibiliy(true)
			player_key=4
			player_keyMax=3
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if !string_buffer.empty():
		if Input.is_action_just_pressed("ui_accept"):
			addLine()
			addText()
		
			if string_buffer.empty():
				todo_help()
	else:
		if Input.is_action_just_pressed("MyKey_0"):
			player_key=0
			todo1()
		elif Input.is_action_just_pressed("MyKey_1"):
			player_key=1
			todo1()
		elif Input.is_action_just_pressed("MyKey_2"):
			player_key=2
			todo1()
		elif Input.is_action_just_pressed("MyKey_3"):
			player_key=3
			todo1()
	pass
