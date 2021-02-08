extends Node

var Player=preload("EntityPlayer.gd")
var Monster=preload("EntityMonster.gd")

var items=[preload("ItemPotionVie.gd"), 
preload("ItemArmure.gd"),
preload("ItemEpee.gd"),
preload("ItemCeinture.gd"),
preload("ItemBotte.gd")]

onready var RTL = $Panel/MarginContainer/RTL

onready var buttons = [$HBoxContainer/Button0,
$HBoxContainer/Button1,
$HBoxContainer/Button2,
$HBoxContainer/Button3]

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
	RTL.newline()
	
	if RTL.get_line_count() > 10:
		RTL.remove_line(0)

func addText():
	RTL.add_text(string_buffer.pop_back())

func buffer_addLine(s):
	string_buffer.push_front(s)
	
func buffer_addText(s):
	string_buffer[0] += s

func action_set0(button:Button, s:String):
	if s != "":
		button.text = s
		button.visible = true
	else:
		button.visible = false

func action_set(s0:String, s1:String, s2:String = "", s3:String = ""):
	var s = [s0, s1, s2, s3]
	
	for i in range(4):
		action_set0(buttons[i], s[i])
	
func action_set_byId(i:int, s:String):
	action_set0(buttons[i], s)
	
func action_hide():
	for i in range(4):
		buttons[i].visible = false

func playerDeath():
	buffer_addLine("Vous êtes mort!")
	state=PLAYER_DEATH

func writeDamage(i):
	buffer_addText("inflige "+str(i)+" dégat(s).")

func entityAttack(a:Entity, b:Entity):
	if a.testAttack():
		buffer_addText(" attaque, ")

		if b.testDef0():
			buffer_addText("mais "+b.name()+" se défend !")
			return false
		else:
			var dam = a.getDamage()
			buffer_addText("et ")
			writeDamage(dam)

			if b.remPv(dam):
				return true
			else:
				return false
	
	buffer_addText(" rate son attaque.")
	return false

func entityStrongAttack(a:Entity, b:Entity):
	a.remDef()
	
	if a.testAttack():
		buffer_addText(" attaque, ")

		if b.testDef(-1):
			buffer_addText("mais "+b.name()+" se défend !")
			return false
		else:
			var dam = a.getDamage() * 2
			buffer_addText("et ")
			writeDamage(dam)

			if b.remPv(dam):
				return true
			else:
				return false
	
	buffer_addText(" rate son attaque.")
	return false

func monsterTodo():
	monster_attack=true

	buffer_addLine(mob.name())

	var rmob = randf()

	match(mob.defLvl):
		0:
			if rmob <= 0.75:
				buffer_addText(" prépare sa défense.")
				mob.addDef()
				return false
			
			return entityAttack(mob, hero)
			
		1:
			if rmob <= 0.5:
				return entityAttack(mob, hero)
			elif rmob <= 0.75:
				return entityStrongAttack(mob, hero)
				
			buffer_addText(" prépare sa défense.")
			mob.addDef()
			return false
		
		2:
			if rmob <= 0.75:
				return entityStrongAttack(mob, hero)
			return entityAttack(mob, hero)

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
	
	hero.defLvl = 1
	
	if turn_ini==0:
		checkIni()
		
	if turn_ini==2 and monsterTodo():
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

	buffer_addLine("Click in this area to start...")

	todo_start()
	
	addText()

func newTreasure():
	var id=0

	if lvl%10!=0:
		id=Helper.rand_between(0, items.size()-1)

	treasure=items[id].new(lvl)

func playerAttack():
	player_attack=true

	buffer_addLine(hero.name())

	if player_key==2:
		hero.addDef()
		buffer_addText(" prépare sa défense.")
		return false
	
	if player_key == 1:
		return entityStrongAttack(hero, mob)

	return entityAttack(hero, mob)

func todo():
	if player_key<=player_keyMax:
		action_hide()
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
					if monster_attack or !monsterTodo():
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
			action_set("atk", "atk++", "def")
			player_key=3
			player_keyMax=2
			
		TREASURE:
			if treasure.equip:
				action_set_byId(0, "Equiper ")
			else:
				action_set_byId(0, "Utiliser ")
			
			action_set_byId(1, "Laisser")
			player_key=2
			player_keyMax=1
			
		PLAYER_DEATH:
			action_set("Prier", "Abandonner")
			player_key=3
			player_keyMax=2
			
		END:
			action_set("Recommencer", "Quitter")
			player_key=3
			player_keyMax=2

func checkMouse():
	if Input.is_action_just_pressed("mouse_left"):
		var mousePos = get_viewport().get_mouse_position()
		
		if RTL.get_global_rect().has_point(mousePos):
			return true
	return false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if !string_buffer.empty() and checkMouse():
		addLine()
		addText()
	
		if string_buffer.empty():
			todo_help()
	pass

func on_button_down(i:int):
	if string_buffer.empty():
		player_key=i
		todo()

func _on_Button0_button_down():
	on_button_down(0)


func _on_Button1_button_down():
	on_button_down(1)


func _on_Button2_button_down():
	on_button_down(2)


func _on_Button3_button_down():
	on_button_down(3)
