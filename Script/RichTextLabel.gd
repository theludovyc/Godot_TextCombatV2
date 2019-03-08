extends RichTextLabel

func _ready():
	push_color(ColorN("red", 1))
	add_text("Gobelin")
	pop()

	add_text(" appear.")

	remove_line(0)

	pass