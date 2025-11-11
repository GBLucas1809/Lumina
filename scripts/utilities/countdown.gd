extends Label3D

var elapsed_time := 0.0

@export var show_numbers = true
@export var max_seconds = 0 
@export var max_minutes = 0

var time_is_up = false

func _process(delta: float) -> void:
	
	elapsed_time += delta
	
	var time_values := format_time(elapsed_time)
		
	var seconds = str(time_values[0])
	var minutes = str(time_values[1])
	# var hours = str(time_values[2])

	if show_numbers == true:
		if not it_surpassed_time_limit(seconds, minutes):
			text = "{0}:{1}".format([minutes, seconds])
		else:
			text = "00:00"
	


func format_time(delta_time: float) -> Array[Variant.Operator]:
	var seconds = int(delta_time)
	var minutes = int(seconds/60)
	var _hours = int(minutes/60)

	if(seconds >= 60):
		seconds -= 60 * minutes
	if(minutes >= 60):
		minutes -= 60 * _hours

	return [seconds, minutes, _hours]

func it_surpassed_time_limit(current_seconds, current_minutes, max_seconds = max_seconds, max_minutes = max_minutes):
	return (int(current_seconds) >= max_seconds) and (int(current_minutes) >= max_minutes)
