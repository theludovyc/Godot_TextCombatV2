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

enum {PLAYER_ATTACK, TREASURE, PLAYER_DEATH, END}

var state:=0

var turn_ini:int

var player_attack:bool
var monster_attack:bool

var player_key:int
var player_keyMax:int

var treasure

var lvl:=0

var hero_def=0

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
	
func help_addText(s):
	$Label11.text+=s

func help_setVisibiliy(b):
	$Label11.visible=b

func aide_setText(s):
	$Label11.text=s

func playerDeath():
	buffer_addLine("Vous êtes mort!")
	state=PLAYER_DEATH

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
	
	buffer_addText(" rate son attaque.")
	return false

func checkIni():
	if hero.ini>mob.ini:
		buffer_addLine(hero.name())
		turn_ini=1
	else:
		buffer_addLine(mob.name())
		turn_ini=2
		
	buffer_addText(" attaque en premier.")

func todo_newTurn():
	player_attack=false
	monster_attack=false
	
	if turn_ini==0:
		checkIni()
		
	if turn_ini==2 and monsterAttack():
		playerDeath()
		return
	
	state=PLAYER_ATTACK

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
	
	turn_ini=0
	
	openDoor()
	apparation()
	todo_newTurn()

func _ready():
	randomize()

	todo_start()
	
	addText()

func newTreasure():
	var id=0

	if lvl%10!=0:
		id=Helper.rand_between(0, items.size()-1)

	treasure=items[id].new(lvl)

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

		buffer_addLine(hero.name())
		writeDamage(damage)

		if mob.remPv(damage):
			return true
		else:
			return false

	buffer_addLine(hero.name()+" rate son attaque.")
	return false

func todo():
	if player_key<=player_keyMax:
		help_setVisibiliy(false)
		match state:
			PLAYER_ATTACK:
				if playerAttack():
					#MONSTER_DEATH
					buffer_addLine(mob.name()+" est mort.")
					
					if lvl==100:
						buffer_addLine("Vous êtes venu à bout du dernier Boss...")
						buffer_addLine("Félicitation !!!")
						buffer_addLine("Fin de la partie, merci d'avoir joué !")
						state=END
						return
					
					buffer_addLine(hero.name()+" a trouvé un trésor!")
					
					newTreasure()

					buffer_addLine("C'est ")

					if treasure.genre:
						buffer_addText("un ")
					else:
						buffer_addText("une ")

					buffer_addText(treasure.name(hero)+" !")
					
					state = TREASURE
				else:
					if monster_attack or !monsterAttack():
						buffer_addLine("- Nouveau tour");
						todo_newTurn();
					else:
						playerDeath()
				
				addLine()
				addText()
				
			TREASURE:
				buffer_addLine(hero.name())
				
				if player_key==0 :
					if treasure.equip:
						buffer_addText(" s'en equipe.")
					else:
						buffer_addText(" l'utilise.")
					treasure.use(hero)
				else:
					buffer_addText(" continu son chemin.")

				treasure=null

				hero.pvMax +=1

				todo_start();
				
				addLine()
				addText()
				
			PLAYER_DEATH:
				if player_key==0:
					buffer_addLine("Un ange a entendu votre prière...")
					buffer_addLine("Il accepte de vous réanimer...")
					buffer_addLine("En échange de votre équipement...")
					buffer_addLine("Et si vous prenez un nouveau départ...")
					
					randomize()
					lvl=0
					hero._init()
					
					todo_start()
					
					addLine()
					addText()
					return
				get_tree().quit()
					
			END:
				if player_key==0:
					randomize()
					lvl=0
					hero._init()
					
					todo_start()
					
					addLine()
					addText()
					return
				get_tree().quit()

func todo_help():
	match state:
		PLAYER_ATTACK:
			help_setText("a.Atk z.Atk++ e.Def")
			help_setVisibiliy(true)
			player_key=3
			player_keyMax=2
			
		TREASURE:
			if treasure.equip:
				help_setText("a.Equiper ")
			else:
				help_setText("a.Utiliser ")
				
			help_addText("z.Laisser")
			help_setVisibiliy(true)
			player_key=2
			player_keyMax=1
			
		PLAYER_DEATH:
			help_setText("a.Prier z.Abandonner")
			help_setVisibiliy(true)
			player_key=3
			player_keyMax=2
			
		END:
			help_setText("a.Recommencer z.Quitter")
			help_setVisibiliy(true)
			player_key=3
			player_keyMax=2

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
			todo()
		elif Input.is_action_just_pressed("MyKey_1"):
			player_key=1
			todo()
		elif Input.is_action_just_pressed("MyKey_2"):
			player_key=2
			todo()
		elif Input.is_action_just_pressed("MyKey_3"):
			player_key=3
			todo()
	pass
