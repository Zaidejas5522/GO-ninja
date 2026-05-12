extends GdUnitTestSuite

const MAIN_MENU_SCENE := "res://Scenes/UI/MainMenu.tscn"

func get_menu(runner) -> Control:
	await get_tree().process_frame
	var menu = runner.scene()
	if menu == null or not menu is Control:
		push_error("Main menu not found")
	return menu

func find_button_by_name(menu: Control, node_name: String) -> Button:
	var btn = menu.find_child(node_name, true, false)
	return btn if btn is Button else null

func find_button_by_text(menu: Control, text: String) -> Button:
	var buttons = menu.find_children("*", "Button", true, false)
	for btn in buttons:
		if btn.text == text:
			return btn
	return null

# Helper to get the method name from a signal connection
func get_connection_method(button: Button) -> String:
	var connections = button.pressed.get_connections()
	if connections.is_empty():
		return ""
	# In Godot 4, each connection is a dict with keys: signal, callable, flags, binds
	var callable = connections[0]["callable"]
	if callable is Callable:
		return callable.get_method()
	return ""

func test_initial_state() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	var menu := await get_menu(runner)
	assert_bool(menu != null).is_true()
	
	var main_buttons := menu.find_child("MainButtons", true, false)
	var options_panel := menu.find_child("Options", true, false)
	
	assert_bool(main_buttons != null and options_panel != null).is_true()
	assert_bool(main_buttons.visible).is_true()
	assert_bool(options_panel.visible).is_false()

func test_start_button_connected_to_method() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	var menu := await get_menu(runner)
	
	var start_btn := find_button_by_name(menu, "Button")
	assert_bool(start_btn != null).override_failure_message("Start button (Button) not found").is_true()
	
	var method_name := get_connection_method(start_btn)
	assert_str(method_name).is_equal("_on_start_pressed")

func test_settings_button_shows_options() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	var menu := await get_menu(runner)
	
	var settings_btn := find_button_by_name(menu, "Button2")
	assert_bool(settings_btn != null).is_true()
	
	var main_buttons := menu.find_child("MainButtons", true, false)
	var options_panel := menu.find_child("Options", true, false)
	assert_bool(main_buttons != null and options_panel != null).is_true()
	
	assert_bool(main_buttons.visible).is_true()
	assert_bool(options_panel.visible).is_false()
	
	settings_btn.pressed.emit()
	await get_tree().process_frame
	
	assert_bool(main_buttons.visible).is_false()
	assert_bool(options_panel.visible).is_true()

func test_back_options_button_returns_to_main() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	var menu := await get_menu(runner)
	
	var settings_btn := find_button_by_name(menu, "Button2")
	assert_bool(settings_btn != null).is_true()
	
	# Try multiple ways to find the back button
	var back_btn := find_button_by_name(menu, "BackOptions")
	if back_btn == null:
		back_btn = find_button_by_name(menu, "Back")
	if back_btn == null:
		back_btn = find_button_by_text(menu, "Back")
	if back_btn == null:
		back_btn = find_button_by_text(menu, "Return")
	
	assert_bool(back_btn != null).override_failure_message("Back button not found (tried names: BackOptions, Back; texts: Back, Return)").is_true()
	
	var main_buttons := menu.find_child("MainButtons", true, false)
	var options_panel := menu.find_child("Options", true, false)
	
	# Go to options
	settings_btn.pressed.emit()
	await get_tree().process_frame
	assert_bool(main_buttons.visible).is_false()
	assert_bool(options_panel.visible).is_true()
	
	# Press back
	back_btn.pressed.emit()
	await get_tree().process_frame
	
	assert_bool(main_buttons.visible).is_true()
	assert_bool(options_panel.visible).is_false()

func test_exit_button_connected_to_method() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	var menu := await get_menu(runner)
	
	var exit_btn := find_button_by_name(menu, "Button3")
	assert_bool(exit_btn != null).is_true()
	
	var method_name := get_connection_method(exit_btn)
	assert_str(method_name).is_equal("_on_exit_pressed")
	
	# Verify exit SFX node exists and has a stream
	var exit_sfx := menu.find_child("ExitSFX", true, false)
	assert_bool(exit_sfx != null).is_true()
	assert_bool(exit_sfx.stream != null).is_true()

func test_audio_nodes_exist() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	var menu := await get_menu(runner)
	
	var main_menu_sfx := menu.find_child("MainMenuSFX", true, false)
	var button_sfx := menu.find_child("ButtonSFX", true, false)
	var exit_sfx := menu.find_child("ExitSFX", true, false)
	
	assert_bool(main_menu_sfx != null).is_true()
	assert_bool(button_sfx != null).is_true()
	assert_bool(exit_sfx != null).is_true()
