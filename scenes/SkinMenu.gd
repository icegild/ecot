extends CanvasLayer


@onready var wheel = $SkinWheel


var player_skin_component: CharacterAnimationComponent


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



func _ready():

	player_skin_component = get_parent().get_node("Blood/PlayerSkinComponent")

	wheel.visible = false

	wheel.selected_skin = selected_skin
	wheel.queue_redraw()



func _process(delta):

	if Input.is_key_pressed(KEY_CTRL):

		wheel.visible = true


		if Input.is_action_just_pressed("next_skin"):

			selected_skin += 1


			if selected_skin >= skins.size():
				selected_skin = 0


			print("Selected skin: ", skins[selected_skin])


			wheel.selected_skin = selected_skin
			wheel.queue_redraw()



	else:

		if wheel.visible:

			wheel.visible = false


			player_skin_component.switch_to_character(
				skins[selected_skin]
			)
