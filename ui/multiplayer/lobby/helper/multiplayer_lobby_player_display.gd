extends Control

#############
# CONSTANTS #
#############

###########
# GLOBALS #
###########
@onready var PlayerBG = $MarginBG/BG/InfoMargin/CardVerticalSplits/PlayerBG/Player/PlayerBG
@onready var PlayerFG = $MarginBG/BG/InfoMargin/CardVerticalSplits/PlayerBG/Player/PlayerFG

@onready var PlayerName = $MarginBG/BG/InfoMargin/CardVerticalSplits/PlayerName
@onready var ColorLeft = $MarginBG/BG/InfoMargin/CardVerticalSplits/ColorSelector/ColorLeft
@onready var ColorPreview = $MarginBG/BG/InfoMargin/CardVerticalSplits/ColorSelector/ColorPreview
@onready var ColorRight = $MarginBG/BG/InfoMargin/CardVerticalSplits/ColorSelector/ColorRight

@onready var Ability1Left = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability1/AbilityLeft
@onready var Ability1Preview = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability1/AbilityBG/AbilityPreview
@onready var Ability1Right = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability1/AbilityRight

@onready var Ability2Left = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability2/AbilityLeft
@onready var Ability2Preview = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability2/AbilityBG/AbilityPreview
@onready var Ability2Right = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability2/AbilityRight

@onready var Ability3Left = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability3/AbilityLeft
@onready var Ability3Preview = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability3/AbilityBG/AbilityPreview
@onready var Ability3Right = $MarginBG/BG/InfoMargin/CardVerticalSplits/Ability3/AbilityRight

@onready var Player = PlayerData.new()
var ColorIndex: int = 1

func _ready() -> void:
	ColorIndex = 1
	Player.color = PlayerData.COLOR_PALETTE[ColorIndex]
	ColorPreview.color = Player.color
	PlayerFG.color = Player.color
	PlayerBG.color = Player.color.darkened(0.5)


func _process(delta: float) -> void:
	pass
	

func _on_color_left_pressed() -> void:
	ColorIndex -= 1
	if ColorIndex > 12:
		ColorIndex = 1
	elif ColorIndex < 1:
		ColorIndex = 12
	Player.color = PlayerData.COLOR_PALETTE[ColorIndex]
	ColorPreview.color = Player.color
	PlayerFG.color = Player.color
	PlayerBG.color = Player.color.darkened(0.5)

func _on_color_right_pressed() -> void:
	ColorIndex += 1
	if ColorIndex > 12:
		ColorIndex = 1
	elif ColorIndex < 1:
		ColorIndex = 12
	Player.color = PlayerData.COLOR_PALETTE[ColorIndex]
	ColorPreview.color = Player.color
	PlayerFG.color = Player.color
	PlayerBG.color = Player.color.darkened(0.5)


func _on_ability1_left_pressed() -> void:
	pass # Replace with function body.


func _on_ability1_right_pressed() -> void:
	pass # Replace with function body.


func _on_ability2_left_pressed() -> void:
	pass # Replace with function body.


func _on_ability2_right_pressed() -> void:
	pass # Replace with function body.


func _on_ability3_left_pressed() -> void:
	pass # Replace with function body.


func _on_ability3_right_pressed() -> void:
	pass # Replace with function body.
