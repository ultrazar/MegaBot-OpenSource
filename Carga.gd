tool
extends Node
var http_request
var nodo
var carga
var pending = []
var actual = 0
var cache_urls = []
var cache_images = []
var temp_url
var location

#Carga imagenes a partir de una url y la guarda en caché para la proxima vez

func guardar(image,url):
	cache_images.append(image)
	cache_urls.append(url)
	var file = File.new()
	file.open(location + "/cache/images/" + (Tools.multiply_string("0",( 5 - str(cache_urls.size()).length() ))) + str(cache_urls.size()) + ".mega-file",file.WRITE)
	file.store_var(image,true)
	file.open(location + "/cache/resources.mega-file",file.WRITE)
	file.store_var(cache_urls)
	file.close()

func _enter_tree():
	var a = OS.get_executable_path() 
	location = a.left(a.find_last('/'))
	print(location)
	var file = Directory.new()
	file.open(location)
	if !file.dir_exists("cache"):
		file.make_dir("cache")
		file.make_dir("cache/images")
	file = File.new()
	if file.file_exists(location + "/cache/resources.mega-file"):
		file.open(location + "/cache/resources.mega-file",file.READ)
		cache_urls = file.get_var()
		file.close()
		cache_images = Tools.directory_to_array(location + "/cache/images")
		for b in cache_images: #Check de seguridad, no es lo mejor pero algo hace :)
			if b.get_script() != null:
				get_tree().quit()
	else:
		file.open(location + "/cache/resources.mega-file",file.WRITE)
		file.store_var([])
	file.close()
	pass

func _ready():
	carga = preload("res://Imagenes/Cargar.tres")
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = 4
	http_request.connect("request_completed", self, "_http_request_completed")

func _load(url : String, node):
	var pos = cache_urls.find(url)
	if pos != -1:
		node.texture = cache_images[pos]
		node.modulate = Color(1,1,1)
		return
	
	node.texture = carga
	pending.append([url,node])
	if pending.size() == 1:
		iterate()

func iterate():
	var iter = pending[pending.size() - 1]
	actual = pending.size() - 1
	var error = http_request.request(iter[0])
	temp_url = iter[0]
	iter[1].texture = carga
	nodo = iter[1]
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	guardar(texture,temp_url)
	nodo.texture = texture
	nodo.modulate = Color(1,1,1)
	pending.remove(actual)
	
	if pending.size() > 0:
		iterate()


