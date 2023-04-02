extends Camera2D

const CAM_SPEED = 15

func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_pressed("ui_left"):
		self.position.x -= CAM_SPEED
	if Input.is_action_pressed("ui_right"):
		self.position.x += CAM_SPEED
	if Input.is_action_pressed("ui_up"):
		self.position.y -= CAM_SPEED
	if Input.is_action_pressed("ui_down"):
		self.position.y += CAM_SPEED
