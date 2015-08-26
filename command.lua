local command={}

function command.setVolume(level)
        print("Try to set Volume to level: " .. level)
        io.popen("amixer -D pulse sset Master ".. level .. "%")
end

function command.startVideo(videoPath)
        print("Put level alpha to 0")
        io.popen("set_alpha fb0 0")
        print("Starting video: " .. videoPath)
        io.popen("gst-launch-0.10 playbin2 uri=file://" .. videoPath .. " &")
end

function command.stopVideo()
        print("Stopping video...")
        io.popen("killall -9 gst-launch-0.10")
end

while true do
	print("Command Test")
	print("------------------")
	print("1. Start Video")
	print("2. Set Volume")
	print("3. Stop Video")
	local choise = io.read()
	if choise == "1" then
		print("Insert complete PATH to the mp4 video file:")
		local path = io.read()
		command.startVideo(path)
	elseif choise == "2" then
		print("Insert Volume level (0-100%):")
		local level = io.read()
		command.setVolume(level)
	elseif choise == "3" then
		command.stopVideo()
	elseif choise == "x" then
		break
	else
		print("Command Error!")
	end
end
