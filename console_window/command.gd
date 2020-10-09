extends Node
class_name Command, "./icons/command.png"

enum ArgumentType {
	FLOAT,
	INT,
	STRING
}

export(Array, String) var argument_names = []
export(Array, ArgumentType) var argument_types = []

export var help: String = ""

var callback: String setget callback_set, callback_get
func callback_set(string):
	callback = "on_command_" + string
func callback_get():
	return callback
	
func _ready():
	assert(argument_types.size() == argument_names.size())
	assert(name.find(" ") == -1) # No spaces
	name = name.to_lower() # Case-insensitive for simplicity

func parse_arguments(args: String):
	var arg_array = []
	var segmented = args.split(" ", false)
	var grouped: PoolStringArray = []
	
	var quoted = false
	for segment in segmented:
		if segment.begins_with("\""):
			quoted = true
			segment.erase(0, 1) # Remove quotation mark
		if segment.ends_with("\""):
			quoted = false
			segment.erase(segment.length() - 1, 1) # Remove quotation mark
			grouped.push_back(segment)
			segment = grouped.join(" ")
			grouped = []
		
		if quoted:
			grouped.push_back(segment)
		else:
			arg_array.push_back(segment)
	
	# Incomplete quote
	if grouped.size() != 0:
		return "Invalid argument format (Incomplete quote): " + grouped.join(" ")
	
	# Invalid number of arguments
	if arg_array.size() != argument_types.size():
		return "Invalid number of arguments (Expected: %s, Recieved: %s)." % [
			String(argument_types.size()),
			String(arg_array.size())
		]
		
	# Convert array elements into their actual type
	for i in range(argument_types.size()):
		match(argument_types[i]):
			ArgumentType.FLOAT:
				arg_array[i] = float(arg_array[i])
			ArgumentType.INT:
				arg_array[i] = int(arg_array[i])
	
	return arg_array

func get_usage():
	var usage = "Usage: %s " % name
	
	for i in range(argument_types.size()):
		var arg_type = ArgumentType.keys()[argument_types[i]]
		var arg_name = argument_names[i]
		arg_type = arg_type.to_lower()
		arg_name = arg_name.to_lower()
		
		usage += "<%s:%s> " % [arg_name, arg_type]
		
	return usage
	
func get_namespace_to(target: Node):
	var namespace: PoolStringArray = []
	var node = self
	while node != target:
		namespace.insert(0, node.name)
		node = node.get_parent()
	
	return namespace
