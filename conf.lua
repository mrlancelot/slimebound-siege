function love.conf(t)
	t.identity = "slimebound-siege"
	t.version = "11.5"
	t.console = false
	t.accelerometerjoystick = true
	t.externalstorage = false
	t.gammacorrect = true

	t.window.title = "Slimebound Siege"
	t.window.width = 960
	t.window.height = 540
	t.window.minwidth = 640
	t.window.minheight = 360
	t.window.resizable = true
	t.window.vsync = 1
	t.window.msaa = 0

	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = true
	t.modules.sound = true
	t.modules.system = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = false
	t.modules.window = true
	t.modules.thread = true
end
