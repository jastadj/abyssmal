class_name ConsoleCommands
extends Node

class Command:
	var cmd_name:String = ""
	var cmd_help:String = ""
	var sub_cmds:Dictionary = {}
	var function = null
	func add_cmd(_cmd_name:String, _cmd_help:String, _function = null) -> bool:
		if !sub_cmds.has(_cmd_name):
			sub_cmds[_cmd_name] = Command.new(_cmd_name, _cmd_help, _function)
			return true
		return false
	func is_menu() -> bool:
		return !sub_cmds.is_empty() and function == null
	func _init(_cmd_name:String, _cmd_help:String, _function = null):
		cmd_name = _cmd_name
		cmd_help = _cmd_help
		function = _function

var commands:Command = Command.new("Main Menu", "")

func _init():
	commands.add_cmd("help", "Show Help", do_help)
	commands.add_cmd("quit", "Quit", do_quit)
	commands.add_cmd("settings", "Settings Menu")
	commands.sub_cmds["settings"].add_cmd("show", "Show Settings", do_settings_show)
	commands.sub_cmds["settings"].add_cmd("new", "New Settings", do_settings_new)
	

func execute(cmd_str:String):
	if cmd_str.is_empty(): return
	var words:PackedStringArray = cmd_str.split(" ")
	if words.is_empty(): return
	var command:Command = find_command(commands, words)
	if command != null:
		if command.is_menu(): print_help(command)
		else: command.function.call(words)

func find_command(menu:Command, words:PackedStringArray) -> Command:
	if words.is_empty():
		printerr("Unable to find cmd, empty")
	else:
		var cmd:String = words[0]
		words.remove_at(0)
		if menu.sub_cmds.has(cmd) and menu.sub_cmds[cmd] is Command:
			var command:Command = menu.sub_cmds[cmd]
			# if this command has sub commands (and no function) then it is a menu, do recursive
			if !command.sub_cmds.is_empty() and command.function == null:
				# if this is a menu without arguments, pass back the menu
				if words.is_empty(): return command
				return find_command(command, words)
			elif command and command.function != null:
				return command
			else:
				printerr("Bad cmd format for cmd: ", cmd)
		else:
			print("Unable to find cmd: ", cmd)
	return null

###################################################################################################

func print_help(menu:Command):
	if menu and menu.is_menu():
		print(menu.cmd_name)
		var linestr:String = ""
		for i in range(0, menu.cmd_name.length()):
			linestr += "-"
		print(linestr)
		for key in menu.sub_cmds.keys():
			if menu.sub_cmds[key] is Command:
				var command:Command = menu.sub_cmds[key]
				print(key, " - ", command.cmd_help)
	else:
		printerr("Error printing menu.")

func do_help(_args:PackedStringArray):
	print_help(commands)

func do_quit(_args:PackedStringArray):
	Console.get_tree().quit()

func do_settings_show(_args:PackedStringArray):
	print(JSON.stringify(Settings._data, "  "))
	
func do_settings_new(_args:PackedStringArray):
	Settings.new_settings()
