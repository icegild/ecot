extends Control


var skins = [
	"blood",
	"dark",
	"electricity",
	"fairy",
	"moon",
	"shell",
	"time",
	"vine"
]


var selected_skin := 0


var icon_textures = {

	"blood": preload("res://ui/skin_icons/blood.png"),
	"dark": preload("res://ui/skin_icons/dark.png"),
	"electricity": preload("res://ui/skin_icons/electricity.png"),
	"fairy": preload("res://ui/skin_icons/fairy.png"),
	"moon": preload("res://ui/skin_icons/moon.png"),
	"shell": preload("res://ui/skin_icons/shell.png"),
	"time": preload("res://ui/skin_icons/time.png"),
	"vine": preload("res://ui/skin_icons/vine.png")

}



func _ready():

	size = Vector2(800,800)

	position = get_viewport_rect().size / 2 - size / 2

	queue_redraw()



func _draw():

	var center = size / 2

	var radius = 340

	var slice_angle = TAU / skins.size()


	# Dark center cutout
	draw_circle(
		center,
		90,
		Color(0.05,0.05,0.05,0.9)
	)



	for i in range(skins.size()):


		# Blood starts at the top
		var start_angle = i * slice_angle - PI / 2

		var end_angle = start_angle + slice_angle



		var color = Color(
			0.08,
			0.08,
			0.1,
			0.9
		)



		# Selected slice
		if i == selected_skin:

			color = Color(
				0.2,
				0.55,
				1.0,
				1.0
			)



		draw_colored_polygon(
			create_slice(
				center,
				radius,
				start_angle,
				end_angle
			),
			color
		)



		# Slice separator
		draw_line(
			center,
			center + Vector2(
				cos(start_angle),
				sin(start_angle)
			) * radius,
			Color(0,0,0,0.6),
			3
		)



		var angle = start_angle + slice_angle / 2



		# Icon position
		var icon_position = center + Vector2(
			cos(angle),
			sin(angle)
		) * 250



		# Selected icon glow
		if i == selected_skin:

			draw_circle(
				icon_position,
				55,
				Color(0.2,0.6,1,0.25)
			)


			draw_circle(
				icon_position,
				45,
				Color(0.3,0.8,1,0.35)
			)



		var texture = icon_textures[skins[i]]



		if texture:

			var icon_size = Vector2(64,64)


			var icon_rect = Rect2(
				icon_position - icon_size / 2,
				icon_size
			)


			draw_texture_rect(
				texture,
				icon_rect,
				false
			)



		# Text under icon

		var text = skins[i].to_upper()

		var font = ThemeDB.fallback_font


		var text_width = font.get_string_size(
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			16
		).x



		var text_position = icon_position + Vector2(
			-text_width / 2,
			55
		)



		draw_string(
			font,
			text_position,
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			16
		)



	# Outer ring
	draw_arc(
		center,
		radius,
		0,
		TAU,
		100,
		Color(0.7,0.7,0.7,0.5),
		4
	)


	# Inner ring
	draw_arc(
		center,
		90,
		0,
		TAU,
		100,
		Color(0.8,0.8,0.8,0.3),
		3
	)





func create_slice(center, radius, start_angle, end_angle):

	var points = []

	points.append(center)


	var steps = 40


	for i in range(steps + 1):

		var angle = lerp(
			start_angle,
			end_angle,
			float(i) / steps
		)


		points.append(
			center + Vector2(
				cos(angle),
				sin(angle)
			) * radius
		)


	return PackedVector2Array(points)
