extends Node

var _open_panel: Control = null

func toggle_panel(panel: Control) -> void:
	if _open_panel == panel:
		panel.visible = false
		_open_panel = null
		return
	
	if _open_panel:
		_open_panel.visible = false
	
	panel.visible = true
	_open_panel = panel
