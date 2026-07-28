extends Node
var upgrade_data: UpgradeData

enum Ability {
	EMPTY = 0,
	DASH = 1,
	SWORD = 2,
	GRENADE = 3,
}

@export var id: StringName = upgrade_data.id
@export var display_name: String = upgrade_data.display_name
@export var description: String = upgrade_data.description
@export var rarity = upgrade_data.rarity_type
@export var color = upgrade_data.rarity_type_color
@export var base_cooldown: float = 1.0

@export var base_velocity: float
@export var cast_sound: AudioStream
@export var duration_sound: AudioStream
@export var impact_sound: AudioStream
