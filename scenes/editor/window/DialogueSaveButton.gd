extends Button

var string
signal clicked

var dialogue: PoolStringArray
var dialogue_page: int = 0

var expression: int = 1
var action: int = 0

export var back_button_path: NodePath
export var next_button_path: NodePath
onready var back_button = get_node(back_button_path)
onready var next_button = get_node(next_button_path)

export var remove_button_path: NodePath
onready var remove_button = get_node(remove_button_path)

export var text_edit_path: NodePath
onready var text_edit = get_node(text_edit_path)

export var expression_sprite_path: NodePath
export var action_sprite_path: NodePath
onready var expression_sprite = get_node(expression_sprite_path)
onready var action_sprite = get_node(action_sprite_path)

# just in case ur confused im using the editor ui to connect
# signals for most of these buttons

func _ready():
	var connect = connect("clicked", self, "_pressed")
	
	yield(get_tree(), "idle_frame")
	dialogue = string.dialogue
	update()

func _pressed():
	save_page()
	
	string.dialogue = dialogue
	string.update_value()
	get_parent().get_parent().close()

func save_page():
	dialogue[dialogue_page] = str(expression).pad_zeros(2) + str(action).pad_zeros(2) + text_edit.text


func update(): change_page(0)
func change_page(direction: int):
	dialogue_page = clamp(dialogue_page + direction, 0, dialogue.size() - 1)
	back_button.disabled = (dialogue_page == 0)
	next_button.disabled = (dialogue_page >= dialogue.size() - 1)
	
	var display_text = dialogue[dialogue_page].substr(4)
	text_edit.text = display_text
	
	# basicallyyy i'm storing these as two double digit numbers
	# at the start of each page, primitive but works fine :D
	expression = int(dialogue[dialogue_page].left(2))
	action = int(dialogue[dialogue_page].substr(2, 2))
	update_expression()
	update_action()

func remove_page():
	dialogue.remove(dialogue_page)
	update()
	
	remove_button.disabled = (dialogue.size() <= 1)

func add_page():
	dialogue.insert(dialogue_page + 1, "0100")
	update()
	
	remove_button.disabled = (dialogue.size() <= 1)


const EXPRESSIONS_AMOUNT = 8
func update_expression(): expression_sprite.region_rect.position.x = expression * 32
func cycle_expression():
	expression = wrapi(expression + 1, 0, EXPRESSIONS_AMOUNT)
	update_expression()

const ACTIONS_AMOUNT = 2
func update_action(): action_sprite.region_rect.position.x = action * 32
func cycle_action():
	action = wrapi(action + 1, 0, ACTIONS_AMOUNT)
	update_action()