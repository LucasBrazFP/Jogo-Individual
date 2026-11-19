extends Sprite2D

@export var velocidade := Vector2(0, 50)

var tamanho_tile := Vector2.ONE

func _ready():
	if texture == null:
		set_process(false)
		push_error("fundo_estrelas: sem textura")
		return
	centered = false
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	region_enabled = true
	tamanho_tile = texture.get_size()
	region_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)

func _process(delta):
	var p = region_rect.position - velocidade * delta
	p.x = fposmod(p.x, tamanho_tile.x)
	p.y = fposmod(p.y, tamanho_tile.y)
	region_rect = Rect2(p, region_rect.size)
