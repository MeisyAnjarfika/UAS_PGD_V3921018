extends KinematicBody2D

var laju_cepat = 300
var laju_normal = 120
var laju = laju_normal
var kecepatan = Vector2.ZERO
var laju_lompat = -310
var gravitasi = 15
var koin = 0
var sedang_terluka = false
var health_maks = 200
var health = 200

onready var sprite = $Sprite

signal hero_apdet_health(value)
signal hero_apdet_koin(value)

func _physics_process(delta):
	kecepatan.y = kecepatan.y + gravitasi
	
	if(not sedang_terluka and Input.is_action_pressed("gerak_kanan")):
		kecepatan.x = laju
	if(not sedang_terluka and Input.is_action_pressed("gerak_kiri")):
		kecepatan.x = -laju
	
	if(not sedang_terluka and Input.is_action_just_pressed("lari_cepat")):
		lari_cepat()
	
	if(not sedang_terluka and Input.is_action_pressed("lompat") and is_on_floor()):
		kecepatan.y = laju_lompat
	
	kecepatan.x = lerp(kecepatan.x, 0, 0.2)
	kecepatan = move_and_slide(kecepatan, Vector2.UP)
	
	if not sedang_terluka:
		update_animasi()
	
func update_animasi():
	if is_on_floor():
		if kecepatan.x < (laju * 0.5) and kecepatan.x > (-laju * 0.5):
			sprite.play("Diam")
		else:
			if laju == laju_normal:
				sprite.play("Lari")
			elif laju == laju_cepat:
				sprite.play("LariCepat")
	else:
		if kecepatan.y > 0:
			# jatuh
			sprite.play("Jatuh")
		else:
			# lompat
			sprite.play("Lompat")
		
	if kecepatan.x > 0:
		$CollisionShape2D.position.x = -2
		sprite.flip_h = false
	if kecepatan.x < 0:
		$CollisionShape2D.position.x = 2
		sprite.flip_h = true
		
func lari_cepat():
	laju = laju_cepat
	$Timer.start()

func _on_Timer_timeout():
	laju = laju_normal

func ambil_koin():
	koin = koin + 1
	emit_signal("hero_apdet_koin", koin)
	
func terluka():
	sedang_terluka = true
	
	health -= 50
	emit_signal("hero_apdet_health", (float(health)/float(health_maks)) * 100)
	
	if kecepatan.x > 0:
		kecepatan.x = -500
	else:
		kecepatan.x = 500
	
	sprite.play("Terluka")
	yield(get_tree().create_timer(1), "timeout")
	
	if health <= 0:
		mati()
	else:
		sedang_terluka = false

func mati():
	sprite.play("Mati")
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(2, false)
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Level1.tscn")
