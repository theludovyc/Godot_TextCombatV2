var name=""

var genre=false

var equip=false

var item_var=0

func _init(i, s, b):
	item_var=Helper.rand_between(i, i+5)

	#print("item_var_min ", item_var_min, " / i1 ", i1," / item_var ", item_var)

	name=s
	genre=b

func use(e):
	pass

func name(e):
	return name