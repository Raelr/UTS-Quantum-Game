extends Node2D
const util = preload("Util.gd")
onready var wireboard = get_node("/root/Node2D/WireBoard")
onready var raycast = RayCastController.new()
var target
var is_held : bool
var offset = Vector2()
var maths = MathUtils.new()

func _ready():
	var state = [1, 0, 0, 0, 0, 0, 0, 0]
	var matrix = maths.create_mat4([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]])
	matrix.print_matrix()
	var mat2 = maths.create_mat4([[0, 1], [1, 0]])
	var hademard = maths.create_mat4([[1/sqrt(2), 1/sqrt(2)], [1/sqrt(2), (-1)/sqrt(2)]])
	var kron = maths.kronecker(matrix, mat2)
	kron.print_matrix()
	kron = maths.kronecker(hademard, matrix)
	var product = kron.get_product(kron, state)
	kron.print_matrix()
	print(product)
	
	var state2 = [0,0,0,0,1,0,0,0]
	var matrix2 = maths.create_mat4([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0]])
	var other = maths.create_mat4([[1, 0], [0,1]])
	var kron2 = maths.kronecker(matrix2, other)
	kron2.print_matrix()
	print("Product: ", kron2.get_product(kron2, state2))
	
func check_input():
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("left_click"):
		target = set_target(raycast.raycast_for_groups(self, mouse_pos, ["LogicGate", "Button"]))
		if target:
			offset = util.get_offset(target.position, mouse_pos, position)
	elif Input.is_action_pressed("left_click") and !is_held:
		is_held = true
	elif Input.is_action_just_released("left_click"):
		target = remove_target(target)
	if target:
		set_target_for_movement(mouse_pos + offset, target)

func check_for_insertable_slot(target):
	wireboard.insert_gate(target, target.position)
	return target

func set_target_for_movement(pos, target):
	if target.is_movable() and is_held:
		target.set_destination(pos, true)

func set_target(target):
	if target:
		target.z_index = 1
		target = check_if_button(target)
	if target and target.logic_gate.inserted:
		wireboard.remove_gate(target.position)
	return target

func check_if_button(target):
	if target.name.find("Button") != -1:
		target = target.on_click(target.position, self)
	return target

func remove_target(target):
	if target and target.is_movable():
		target = check_for_insertable_slot(target)
	is_held = false 
	target = null
	return target

func _process(delta):
	check_input()