extends Node

signal theme_changed

@onready var stage = $"/root/Main/Stage"
@onready var tile_map: TileMap = $"/root/Main/Stage/TileMap"

enum StageTheme {
	OVERWORLD,
	UNDERGROUND,
}

const _THEMES = {
	StageTheme.OVERWORLD: preload("res://themes/overworld.tres"),
	StageTheme.UNDERGROUND: preload("res://themes/underground.tres"),
}

var theme: StageTheme = StageTheme.OVERWORLD:
	set(value):
		theme = value
		var data = _THEMES[value] as ThemeData
		tile_map.tile_set.get_source(0).texture = data.tile_set_texture
		RenderingServer.set_default_clear_color(data.background_color)
		theme_changed.emit(value)
