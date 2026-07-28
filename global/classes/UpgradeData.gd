extends Resource
class_name UpgradeData

var rarity_type: Array[String] = [
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
]

var rarity_type_color: Array[Color] = [
	Color.WHITE_SMOKE,
	Color.WEB_GREEN,
	Color.DODGER_BLUE,
	Color.PURPLE,
	Color.GOLDENROD
]

@export var id: StringName
@export var display_name: String
@export var description: String
@export var rarity = rarity_type[0]
@export var color = rarity_type_color[0]
