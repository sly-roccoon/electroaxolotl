@icon("res://addons/godOSC/images/OSCMessage.svg")
class_name ParticlesOSC
extends Node
## Convenience class for organizing an OSC message. Used with an OSCClient. To add your own code, extend the script attached to the OSCReceiver you create by right clicking and "extend script"

## The client to send the OSC message with
@export var target_client : OSCClient

@export var enabled := true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sendContinuous()
	
func sendContinuous() -> void:
	# sends continuous particle osc messages
	var particles : Array = get_children()
	particles = particles.filter(func(node):
		if node is SoundParticle:
			return node.continuous == true
		return false
	)
	
	for particle in particles:
		target_client.send_message("/continuous", particle.getData())
	
func _on_particle_collision(body, particle):
	if particle.continuous == true: return
	
	target_client.send_message("/collision", particle.getData())

func _on_particle_exiting(particle):
	if particle.continuous:
		target_client.send_message("/rm_continuous", [particle.get_instance_id()])
