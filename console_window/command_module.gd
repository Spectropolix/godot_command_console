extends Node
class_name CommandModule, "./icons/module.png"

# Optional command handler target, parent is assumed by default
export(NodePath) var command_handler_target = ".."
export var module_description: String = ""

var command_refs: Dictionary
var command_handler = null
var console = null

func _ready():
	command_handler = get_node(command_handler_target)
	_build_command_dictionary(self)

func command_entered(command, args):
	var command_node = command_refs[command]
	assert(command_node != null)
	
	var parse_result = command_node.parse_arguments(args)
	if parse_result is String:
		console.push_message(parse_result)
		console.push_message(command_node.get_usage())
		return
	
	if !command_handler.has_method(command_node.callback):
		console.push_message("Command callback not found: " + command_node.callback)
		return
	
	command_handler.call(command_node.callback, console, parse_result)

func has_command(command: String):
	return command_refs.has(command)

func _build_command_dictionary(target: Node):
	for child in target.get_children():
		assert(child is Command || child is CommandGroup)
		
		if child is Command:
			var namespace = child.get_namespace_to(self)
			child.callback = namespace.join("_")
			command_refs[namespace.join(".")] = child
		else:
			_build_command_dictionary(child)

func generate_help_string():
	var msg = "Module: " + name
	msg += " %s\n\n" % module_description
	
	for i in range(command_refs.keys().size()):
		var command_string = command_refs.keys()[i]
		var command_node = command_refs.values()[i]
		
		msg += "* %s\n" % command_string
		msg += "    %s\n" % command_node.help
	
	return msg
