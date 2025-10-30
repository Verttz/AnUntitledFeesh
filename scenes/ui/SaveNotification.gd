extends Label

# Shows and fades out the save notification
var fade_time := 1.5
var show_time := 1.0

func show_notification():
    visible = true
    modulate.a = 0.9
    create_tween().tween_property(self, "modulate:a", 0.9, 0.1)
    yield(get_tree().create_timer(show_time), "timeout")
    create_tween().tween_property(self, "modulate:a", 0.0, fade_time)
    yield(get_tree().create_timer(fade_time), "timeout")
    visible = false
