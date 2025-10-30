extends Camera2D

# Oblique camera that follows player, allows zoom in/out but not panning

var min_zoom = 0.5
var max_zoom = 2.0

func _ready():
    current = true
    zoom = Vector2(1, 1)
    offset = Vector2(0, 0)
    smoothing_enabled = true
    smoothing_speed = 6.0
    # Set oblique angle (e.g., tilt or offset if needed)

func _process(delta):
    if Input.is_action_just_pressed("zoom_in"):
        zoom = Vector2(clamp(zoom.x - 0.1, min_zoom, max_zoom), clamp(zoom.y - 0.1, min_zoom, max_zoom))
    elif Input.is_action_just_pressed("zoom_out"):
        zoom = Vector2(clamp(zoom.x + 0.1, min_zoom, max_zoom), clamp(zoom.y + 0.1, min_zoom, max_zoom))
