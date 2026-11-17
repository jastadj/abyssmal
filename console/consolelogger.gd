class_name ConsoleLogger
extends Logger

signal msg_logged(msg:String, err:bool)

func _log_message(message: String, error: bool):
	msg_logged.emit(message, error)
	
#func log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]):
	#pass
