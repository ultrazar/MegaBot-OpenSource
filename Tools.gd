extends Node
#Tools autoload of Megazar21 software:

#MIT License
#
#Copyright (c) 2021 Megazar21 megazar21yt@gmail.com
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

var padre : Node
var pos
var bot : Node
const encryption_passw = "<Any password>"

func guardar(path,data):
	var file = File.new()
	var c = file.open_encrypted_with_pass(Carga.location + path,file.WRITE,encryption_passw)
	if c != OK:
		error("001", "Ha ocurrido un error, lo sentimos, no podemos dar mas información. Por favor, reinicie el programa.")
		print("error 001")
		#breakpoint
		return
	file.store_var(data)
	file.close()

func cargar(path):
	var file = File.new()
	var c = file.open_encrypted_with_pass(Carga.location + path,file.READ,encryption_passw)
	if c != OK:
		error("002", "Ha ocurrido un error, lo sentimos, no podemos dar mas información. Por favor, reinicie el programa.")
		print("error 002")
		#breakpoint
		return
	c = file.get_var()
	file.close()
	return c

func cargar_externo(path,as_text=true):
	var file = File.new()
	var c = file.open(path,file.READ)#file.open_encrypted_with_pass(Carga.location + path,file.READ,encryption_passw)
	if c != OK:
		error("002", "Ha ocurrido un error, lo sentimos, no podemos dar mas información. Por favor, reinicie el programa.")
		print("error 002")
		#breakpoint
		return
	c = file.get_as_text() if as_text else file.get_var()
	file.close()
	return c


func _enter_tree():
	randomize()
	padre = get_tree().current_scene
	
	pos = Carga.location

func _ready():
	
	set_process(false)
	pause_mode = Node.PAUSE_MODE_PROCESS

static func delete_dir(path,own : bool):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					print("Deleting directory: " + file_name)
					delete_dir(path + "/" + file_name,true)
			else:
				print("Deleting: " + file_name)
				dir.remove(path + "/" + file_name)
			file_name = dir.get_next()
		if own:
			dir.remove(path)
	else:
		print("An error occurred when trying to access the path.")

static func delete_childs(nodo : Node):
	var n = 0
	var d = nodo.get_child_count()
	while n < d:
		nodo.get_child(n).queue_free()
		n += 1

func directory_to_array(path):
	var dir = Directory.new()
	var file = File.new()
	var final = []
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				continue
			else:
				file.open(path + "/" + file_name,file.READ)
				final.append(file.get_var(true))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return final

func multiply_string(string,number):
	var final = string
	var n = 1
	
	while n < number:
		final += string
		n += 1
	return final

var popup = preload("res://Error.tscn")
var _popup
func error(title : String, info = "Ha ocurrido un error"):
	if _popup != null:
		_popup.queue_free()
		_popup = null
	get_tree().paused = true
	_popup = popup.instance()
	Tools.padre.add_child(_popup)
	_popup.connect("hide",self,"_error")
	Tools.padre.move_child(_popup,Tools.padre.get_child_count() + 1)
	_popup.window_title = "Error: " + title
	_popup.dialog_text = info
	_popup.popup_centered()
func _error():
	_popup.queue_free()
	_popup = null
	get_tree().paused = false

#Esta función devuelve una array a partir una array compuesta de arrays, cogiendo x pos en cada una. ej: array_in_arrays([[1,2],[3,4]],1) = [2,4]
static func array_in_arrays(array : Array,pos : int):
	var _array = []
	for b in array:
		_array.append(b[pos])
	return _array

func dictionary_string(dictionary,joins=": ",apart=", "):
	var final = ""
	for a in dictionary:
		final += str(a)
		final += joins
		final += str(dictionary[a])
		final += apart
	return final

func string_from_unix(unix,gmt=0):
	var datetime = OS.get_datetime_from_unix_time(unix)
	var final = ""
	final += "%s/%s/%s" % [str(datetime["day"]),str(datetime["month"]),str(datetime["year"])]
	final += " %s:%s" % [str(datetime["hour"] + gmt),str(datetime["minute"])] 
	return final

var loader : ResourceInteractiveLoader
var _loader = []
func cargar_escena(path,output_node=null,output_method=null,representation=null):
	print("cargando " + path)
	loader = ResourceLoader.load_interactive(path)
	get_tree().paused = true
	_loader = [output_node,output_method,representation]
	if representation != null:
		representation.load_state = PoolIntArray([0,loader.get_stage_count()])
	if loader == null:
		breakpoint
		return
	set_process(true)
	wait_frames = 1

var wait_frames = 1
func _process(delta):
	if wait_frames > 0:
		wait_frames -= 1
		return
	var t = OS.get_ticks_msec()
	if not( OS.get_ticks_msec() < t + 100):
		return
	
	var err = loader.poll()
	
	if _loader[2] != null:
		_loader[2].load_state[0] = loader.get_stage()
	
	if err == ERR_FILE_EOF:
		var resource = loader.get_resource()
		loader = null
		resource = resource.instance()
		padre = resource
		Tools.padre = resource
		TwitchApi.nodo = Tools.padre
		get_tree().root.add_child(resource)
		if _loader[0] != null and _loader[1] != null:
			_loader[0].call(_loader[1])
		get_tree().current_scene.free()
		get_tree().current_scene = resource
		set_process(false)
		get_tree().paused = false
	elif err == OK:
		print("+1 - " + str(loader.get_stage()))
	else:
		breakpoint
		loader = null
		set_process(false)

func ventana(titulo : String, texto : String, nodo=null,metodo : String = ""):
	var popup = ConfirmationDialog.new() if nodo != null else AcceptDialog.new()
	padre.add_child(popup)
	popup.dialog_text = texto
	popup.window_title = titulo
	popup.dialog_autowrap = true
	popup.rect_min_size = Vector2(400,0)
	popup.popup_centered()
	if nodo!= null:
		popup.connect("confirmed",nodo,metodo)
	popup.connect("popup_hide",self,"autodelete",[popup])

func autodelete(node):
	node.queue_free()

static func build_url(base_url:String,_headers:Dictionary):
	var headers = ""
	headers += "?%s=%s" % [_headers.keys()[0],_headers[_headers.keys()[0]]]
	_headers.erase(_headers.keys()[0])
	for a in _headers:
		headers += "&%s=%s" % [a,_headers[a]] 
	return base_url + headers

const sample = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM0123456789"
func token_generate(length : int):
	var final = ""
	var n = 0
	while n < length:
		final += sample[int(rand_range(0,61))]
		n += 1
	return final

class localhost:
#Classe con intención de usar el localhost del dispositivo para cualquier situación
#Por Megazar21

	signal posted(query_string)
	var _node = Timer.new()
	var server = TCP_Server.new()
	var response : String
	func _init(port,node, _response):
		print("started")
		Tools.add_child(_node)
		response = _response
		_node.wait_time = 0.1
		_node.connect("timeout",self,"process")
		_node.start()
		var try = server.listen(port)
		if  try != OK:
			breakpoint
	
	static func query_string_to_dictionary(query_string):
		query_string = query_string.right(2)
		query_string = query_string.split("&")
		var result = {}
		for a in query_string:
			var t = a.split("=")
			result[t[0]] = t[1]
		return result
	func send_sample():
		conection.put_data(sample.to_ascii())
	
	func stop():
		_node.queue_free()
	
	var conection : StreamPeer
	#El html de "Grácias por inciar sesión"
	var HTTP_PROTOCOL = "HTTP/1.1 200 OK\nContent-Type: text/html\n\n".to_ascii()
	func process():
		if server.is_connection_available():
			conection = server.take_connection()
			if conection == null:
				print("Connection failed")
				return
			print("Connecting \n")
			var data = conection.get_data(conection.get_available_bytes())[1].get_string_from_ascii()
			if data == "":
				conection.disconnect_from_host()
				return
			print("data: " + data + "\n")
			var query_string = data.split(" ",true,2)[1]
			query_string = query_string_to_dictionary(query_string)
			print("query_string: " + str(query_string))
			#send_sample()
			conection.put_data(HTTP_PROTOCOL +  response.to_ascii())
			print("sended... \n")
			emit_signal("posted",query_string)
		return

func rapid_request(url:String,url_method,query,node,method,custom_headers=[]):
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed",self,"_rapid_request",[http,node,method])
	http.request(url,custom_headers,false,url_method,JSON.print(query))
func _rapid_request(suda_uno,suda_dos,suda_tres,body,http,node,method): #LOL
	node.call(method,[JSON.parse(body.get_string_from_utf8()).result])
	http.queue_free()

func file_popup(title="Selecciona",filters=PoolStringArray([]),type=FileDialog.MODE_OPEN_FILE,mode=FileDialog.ACCESS_FILESYSTEM):
	var p = FileDialog.new()
	padre.add_child(p)
	p.resizable = true
	p.dialog_hide_on_ok = true
	p.window_title = title
	p.filters=filters
	p.access=mode
	p.mode=type
	p.popup_centered(Vector2(500,300))
	yield(p,"popup_hide") # espera a que se cierre
	p.queue_free()
	return p.current_path if p.current_path[0]!="/" else ("C:" + p.current_path) #+ p.current_file

func ImageFrames_to_animatedtexture(ImageFrame:ImageFrames):
	var result = AnimatedTexture.new()
	result.frames = ImageFrame.get_frame_count()
	var n = 0
	while n < result.frames:
		var d = ImageTexture.new()
		d.create_from_image(ImageFrame.get_frame_image(n))
		result.set_frame_texture(n,d)
		result.set_frame_delay(n,ImageFrame.get_frame_delay(n))
		n += 1
	result.fps = 0
	return result

class GDScriptAudioImport:
#Classe para importar sonidos externos del programa durante su ejecución
#Original de https://github.com/Gianclgar/GDScriptAudioImport

	func loadfile(filepath):
		var file = File.new()
		file.open(filepath, File.READ)
		var bytes = file.get_buffer(file.get_len())
		if filepath.ends_with(".wav"):
			var newstream = AudioStreamSample.new()
			for i in range(0, 100):
				var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
				
				if those4bytes == "RIFF": 
					print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
					#RIP bytes 4-7 integer for now
				if those4bytes == "WAVE": 
					print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))

				if those4bytes == "fmt ":
					print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
					
					#get format subchunk size, 4 bytes next to "fmt " are an int32
					var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
					print ("Format subchunk size: " + str(formatsubchunksize))
					
					#using formatsubchunk index so it's easier to understand what's going on
					var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

					#get format code [Bytes 0-1]
					var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
					var format_name
					if format_code == 0: format_name = "8_BITS"
					elif format_code == 1: format_name = "16_BITS"
					elif format_code == 2: format_name = "IMA_ADPCM"
					print ("Format: " + str(format_code) + " " + format_name)
					#assign format to our AudioStreamSample
					newstream.format = format_code
					
					#get channel num [Bytes 2-3]
					var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
					print ("Number of channels: " + str(channel_num))
					#set our AudioStreamSample to stereo if needed
					if channel_num == 2: newstream.stereo = true
					
					#get sample rate [Bytes 4-7]
					var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
					print ("Sample rate: " + str(sample_rate))
					#set our AudioStreamSample mixrate
					newstream.mix_rate = sample_rate
					
					#get byte_rate [Bytes 8-11] because we can
					var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
					print ("Byte rate: " + str(byte_rate))
					
					#same with bits*sample*channel [Bytes 12-13]
					var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
					print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
					#aaaand bits per sample [Bytes 14-15]
					var bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
					print ("Bits per sample: " + str(bits_per_sample))
					
					
				if those4bytes == "data":
					var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
					print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

					var data_entry_point = (i+8)
					print ("Audio data starts at byte " + str(data_entry_point))
					
					newstream.data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
					
				# end of parsing
				#---------------------------
			#get samples and set loop end
			var samplenum = newstream.data.size() / 4
			newstream.loop_end = samplenum
			newstream.loop_mode = 1 #change to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs
			return newstream  #:D
		#if file is ogg
		elif filepath.ends_with(".ogg"):
			var newstream = AudioStreamOGGVorbis.new()
			newstream.loop = true #set to false or delete this line if you don't want to loop
			newstream.data = bytes
			return newstream
		#if file is mp3
		elif filepath.ends_with(".mp3"):
			var newstream = AudioStreamMP3.new()
			newstream.loop = true #set to false or delete this line if you don't want to loop
			newstream.data = bytes
			return newstream
		else:
			print ("ERROR: Wrong filetype or format")
		file.close()

func sound(sound):
	var player = AudioStreamPlayer.new()
	
	padre.add_child(player)
	player.stream = sound
	player.play()

func _input(event):
	if event.is_action_pressed("ui_end"):
		breakpoint

static func dictionary_sum(dic_one,dic_two): #Tiene preferencia el segundo!!
	var result = {}
	for a in dic_one:
		result[a] = dic_one[a]
	for a in dic_two:
		result[a] = dic_two[a]
	return result

enum window_modes {
	LOAD,
	RUNTIME
}
func window_mode(mode):
	match mode:
		window_modes.LOAD:
			OS.set_window_always_on_top(true)
			OS.window_per_pixel_transparency_enabled = true
			get_tree().get_root().transparent_bg = true
			OS.window_borderless = true
			OS.min_window_size = Vector2(512,5512)
			OS.window_size = Vector2(512,512)
			OS.window_position = (OS.get_screen_size() / 2) - Vector2(256,256)

		window_modes.RUNTIME:
			OS.set_window_always_on_top(false)
			OS.window_per_pixel_transparency_enabled = false
			get_tree().get_root().transparent_bg = false
			OS.window_borderless = false
			OS.window_size = Vector2(1280,720)
			OS.min_window_size = Vector2(1000,600)
			OS.window_position = (OS.get_screen_size() / 2) - Vector2(640,360)
