extends TileMapLayer

# Define all 25 tiles with their atlas coordinates
# Change these to match YOUR tiles' actual atlas coordinates
var tile_list = [
	Vector2i(0, 0),  # Tile 1  - Press 1
	Vector2i(1, 0),  # Tile 2  - Press 2
	Vector2i(2, 0),  # Tile 3  - Press 3
	Vector2i(3, 0),  # Tile 4  - Press 4
	Vector2i(4, 0),  # Tile 5  - Press 5
	Vector2i(0, 1),  # Tile 6  - Press 6
	Vector2i(1, 1),  # Tile 7  - Press 7
	Vector2i(2, 1),  # Tile 8  - Press 8
	Vector2i(3, 1),  # Tile 9  - Press 9
	Vector2i(4, 1),  # Tile 10 - Press 0
	Vector2i(0, 2),  # Tile 11 - Press Q
	Vector2i(1, 2),  # Tile 12 - Press W
	Vector2i(2, 2),  # Tile 13 - Press E
	Vector2i(3, 2),  # Tile 14 - Press R
	Vector2i(4, 2),  # Tile 15 - Press T
	Vector2i(0, 3),  # Tile 16 - Press Y
	Vector2i(1, 3),  # Tile 17 - Press U
	Vector2i(2, 3),  # Tile 18 - Press I
	Vector2i(3, 3),  # Tile 19 - Press O
	Vector2i(4, 3),  # Tile 20 - Press P
	Vector2i(0, 4),  # Tile 21 - Press A
	Vector2i(1, 4),  # Tile 22 - Press S
	Vector2i(2, 4),  # Tile 23 - Press D
	Vector2i(3, 4),  # Tile 24 - Press F
	Vector2i(4, 4),  # Tile 25 - Press G
]

var current_tile_index = 0

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			# Number keys for tiles 1-10
			KEY_1: current_tile_index = 0
			KEY_2: current_tile_index = 1
			KEY_3: current_tile_index = 2
			KEY_4: current_tile_index = 3
			KEY_5: current_tile_index = 4
			KEY_6: current_tile_index = 5
			KEY_7: current_tile_index = 6
			KEY_8: current_tile_index = 7
			KEY_9: current_tile_index = 8
			KEY_0: current_tile_index = 9

			# Letter keys for tiles 11-20
			KEY_Q: current_tile_index = 10
			KEY_W: current_tile_index = 11
			KEY_E: current_tile_index = 12
			KEY_R: current_tile_index = 13
			KEY_T: current_tile_index = 14
			KEY_Y: current_tile_index = 15
			KEY_U: current_tile_index = 16
			KEY_I: current_tile_index = 17
			KEY_O: current_tile_index = 18
			KEY_P: current_tile_index = 19

			# Letter keys for tiles 21-25
			KEY_A: current_tile_index = 20
			KEY_S: current_tile_index = 21
			KEY_D: current_tile_index = 22
			KEY_F: current_tile_index = 23
			KEY_G: current_tile_index = 24

	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var tile_pos = local_to_map(mouse_pos)

		if event.button_index == MOUSE_BUTTON_LEFT:
			set_cell(tile_pos, 0, tile_list[current_tile_index])
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			erase_cell(tile_pos)
