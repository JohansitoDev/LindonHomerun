extends SceneTree

const AppFlowState = preload("res://src/domain/app_flow_state.gd")
const StartupFlowUseCase = preload("res://src/application/startup_flow_use_case.gd")


func _initialize() -> void:
	_test_splash_loads_for_ten_seconds()
	_test_login_requires_email_and_password()
	_test_teams_must_be_selected_before_starting()
	print("All startup flow tests passed.")
	quit()


func _test_splash_loads_for_ten_seconds() -> void:
	var flow = StartupFlowUseCase.new()
	flow.tick(9.9)
	assert(flow.state.screen == AppFlowState.Screen.SPLASH)
	assert(is_equal_approx(flow.state.get_loading_progress(), 0.99))
	flow.tick(0.1)
	assert(flow.state.screen == AppFlowState.Screen.LOGIN)
	assert(is_equal_approx(flow.state.get_loading_progress(), 1.0))


func _test_login_requires_email_and_password() -> void:
	var flow = StartupFlowUseCase.new()
	flow.tick(10.0)
	assert(not flow.sign_in("", "password"))
	assert(flow.state.screen == AppFlowState.Screen.LOGIN)
	assert(flow.sign_in("player@example.com", "password"))
	assert(flow.state.screen == AppFlowState.Screen.TEAM_SELECTION)


func _test_teams_must_be_selected_before_starting() -> void:
	var flow = StartupFlowUseCase.new()
	flow.tick(10.0)
	flow.sign_in("player@example.com", "password")
	assert(not flow.confirm_team())
	assert(flow.state.screen == AppFlowState.Screen.TEAM_SELECTION)
	assert(not flow.select_team(-1))
	assert(flow.select_team(3))
	assert(flow.state.get_selected_team_name() == "Leones del Escogido")
	assert(flow.confirm_team())
	assert(flow.state.screen == AppFlowState.Screen.HOME)
	assert(not flow.start_game())
	assert(flow.navigate_to(AppFlowState.Screen.SHOP))
	assert(flow.state.screen == AppFlowState.Screen.SHOP)
	assert(flow.navigate_to(AppFlowState.Screen.HOME))
	assert(flow.start_game())
	assert(flow.state.screen == AppFlowState.Screen.GAMEPLAY)
	assert(flow.finish_game())
	assert(flow.state.screen == AppFlowState.Screen.RESULTS)
	assert(flow.start_game())
	assert(flow.state.screen == AppFlowState.Screen.GAMEPLAY)
