class_name StateChecker
const FLOAT_EPSILON = 0.01

static func factor_state(state):
	var factor = null
	if state.size() == 2:
		return state
	if state == [1,0,0,0]:
		factor = [[1,0], [1,0]]
	elif state == [0,1,0,0]:
		factor = [[1,0], [0,1]]
	elif state == [0,0,1,0]:
		factor = [[0,1], [1,0]]
	elif state == [0,0,0,1]:
		factor = [[0,1], [0,1]]
	elif array_eq([0.5, 0.5, 0.5, 0.5], state):
		factor = [[1/sqrt(2),1/sqrt(2)],[1/sqrt(2),1/sqrt(2)]]
	elif array_eq([0.5,-0.5,0.5,-0.5], state):
		factor = [[1/sqrt(2),1/sqrt(2)], [1/sqrt(2),-1/sqrt(2)]]
	elif array_eq([0.5,0.5,-0.5,-0.5], state):
		factor = [[1/sqrt(2),-1/sqrt(2)], [1/sqrt(2),1/sqrt(2)]]
	elif array_eq([0.5,-0.5,-0.5,0.5], state):
		factor = [[1/sqrt(2),-1/sqrt(2)], [1/sqrt(2),-1/sqrt(2)]]
	return factor

static func compare(left, right, epsilon = FLOAT_EPSILON):
	var same_sign = sign(left) == sign(right)
	return same_sign and left - right <= FLOAT_EPSILON

static func array_eq(left, right):
	var same = true
	var size = left.size()
	for i in range(0, size):
		if not compare(left[i], right[i]):
			same = false
			break
	return same