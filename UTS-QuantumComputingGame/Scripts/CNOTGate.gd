extends Node
onready var logic_gate = LogicGate.new()
onready var maths = MathUtils.new()
var cnot_matrix
var pauli_x
var should_snap
var controlling_gate
var entangled_bit
var control
var passed_value

func on_removed():
	if controlling_gate:
		controlling_gate.on_removed()
		controlling_gate = null

func on_insert(wireboard, wire, slot):
	if wire.idx > 0:
		var other_wire = wireboard.wires[wire.idx - 1]
		if other_wire:
			var other = other_wire.wire_gates[slot.idx]
			for group in other.get_groups():
				if group == "Control":
					other.attach_gate(self, wireboard, other_wire)
					if not other_wire.wire_gates[slot.idx - 1].name.find("Hademard") == -1:
						print("ENTANGLED")
						wire.entangled = true
						other_wire.entangled = true
						entangled_bit = other_wire
					elif other_wire.entangled:
						print("ENTANGLED")
						wire.entangled = true
						entangled_bit = other_wire

func process_value():
	var bit_vec
	if control:
		var tensor = maths.tensor([control, passed_value])
		if tensor.size() != cnot_matrix.matrix.size():
			var kron = maths.scale_vector(tensor, cnot_matrix)
			bit_vec = [kron.get_product(kron, tensor), null]
		else:
			bit_vec = [cnot_matrix.get_product(cnot_matrix, tensor), null]
	else:
		if passed_value.size() != pauli_x.matrix.size():
			var kron = maths.scale_vector(passed_value, pauli_x)
			bit_vec = [kron.get_product(kron, passed_value), null]
		else:
			bit_vec = [pauli_x.get_product(pauli_x, passed_value), null]
	if entangled_bit:
		bit_vec[1] = entangled_bit
	return bit_vec

func _ready():
	initialise(true)

# TODO Abstract all of these methods into an all encompassing class group. 
func initialise(status):
	var row_1 = [1, 0, 0, 0]
	cnot_matrix = maths.create_mat4([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0]])
	pauli_x = maths.create_mat4([[0,1],[1,0]])
	set_movable(status)

func destroy_after_movement():
	should_snap = false
	logic_gate.destroy = true
	set_movable(false)
	remove_from_group("LogicGate")
	logic_gate.destination = get_tree().get_nodes_in_group("bitButton")[0].position

func set_movable(status):
	logic_gate.is_movable = status

func is_movable():
	return logic_gate.is_movable

func set_destination(destination, snap):
	logic_gate.destination = destination
	should_snap = snap

func destination():
	return logic_gate.destination

func will_be_destroyed():
	return logic_gate.destroy

func _process(delta):
	logic_gate.process_movement(delta, should_snap, self)