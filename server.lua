--
-- Server Lua Advanced Smart Player TV
-- 
-- AUTHOR: Stefano Viola (estebanSannin)
-- Hackathon ROMA
--

----------- NOTE
--
-- Volume control: amixer -D pulse sset Master 50%
-- Modify Alpha: set_alpha fb0 0
-- gst-launch-0.10 playbin2 uri=file:///path/to/file/mp4
--

local turbo = require "turbo"
local log = turbo.log

local clock = os.clock

function sleep(n) -- seconds
	local t0 = clock()
	while clock() -t0 <= n do end
end

local channel={
		["1"]={id="1",video="/home/ubuntu/server/video/italiansgot.mp4"},
		["2"]={id="2",video="/home/ubuntu/server/video/madeinsud.mp4"},
		["3"]={id="3",video="/home/ubuntu/server/video/chilhavisto.mp4"},
		["4"]={id="4",video="/home/ubuntu/server/video/iostocongliippopotami.mp4"},
		["5"]={id="5",video="/home/ubuntu/server/video/cepostaperte.mp4"},
		["6"]={id="6",video="/home/ubuntu/server/video/motogp.mp4"},
		["7"]={id="7",video="/home/ubuntu/server/video/calcio.mp4"},
		["8"]={id="8",video="/home/ubuntu/server/video/bear.mp4"},
		["9"]={id="9",video="/home/ubuntu/server/video/river.mp4"},
		["10"]={id="10",video="/home/ubuntu/server/video/lupinconan.mp4"},
		["11"]={id="10",video="/home/ubuntu/server/video/tronodispade.mp4"},
 		["12"]={id="10",video="/home/ubuntu/server/video/iron3.mp4"}



	}

local command={}

function command.setVolume(level)
	log.debug("Try to set Volume to level: " .. level)
	io.popen("amixer -D pulse sset Master ".. level .. "%")
end

function command.startVideo(videoPath)
	log.debug("Put level alpha to 0")
	io.popen("set_alpha fb0 0")
	log.debug("Starting video: " .. videoPath)
	io.popen("gst-launch-0.10 playbin2 uri=file://" .. videoPath .. " &")
end

function command.stopVideo()
	log.debug("Stopping video...")
	--io.popen("killall -9 gst-launch-0.10")
	os.execute("killall -9 gst-launch-0.10")
end

local ZappingHandler = class("ZappingHandler", turbo.web.RequestHandler)
local SearchHandler = class("SearchHandler", turbo.web.RequestHandler)
local InfoHandler = class("InfoHandler", turbo.web.RequestHandler)
local ChannelsHandler = class("ChannelsHandler", turbo.web.RequestHandler)
local TestHandler = class("TestHandler", turbo.web.RequestHandler)
local VolumeHandler = class("VolumeHandler", turbo.web.RequestHandler)

function ZappingHandler:post()
	local data = self:get_json(true)
	log.debug("DEBUG JSON RECEIVED:")
	log.debug(data.id)
	log.debug(channel[data.id].video)
	command.stopVideo()
	--sleep(1)
	command.startVideo(channel[data.id].video)
	self:write("zapping")
end

function SearchHandler:post()
	log.debug("SEARCH HANDLER POST")
	local data = self:get_json(true)
	log.debug("DEBUG JSON RECEIVED:")
	log.debug(data)
	self:write("search")
end

function InfoHandler:post()
	log.debug("Info HANDLER POST")
	local data = self:get_json(true)
	log.debug("DEBUG JSON RECEIVED:")
	log.debug(data)
	self:write("info")
end

function VolumeHandler:post()
	local data = self:get_json(true)
	command.setVolume(data.volume)
end

function ChannelsHandler:get()
	local channels={response={
		[1]={id="1",name="sky uno",info="Italian's Got Talent", description="Programma di varieta`"},
		[2]={id="2",name="rai due",info="Made in SUD", description="Programma di varieta`"},
		[3]={id="3",name="rai tre",info="Chi l'ha visto", description="Programma di attualita`"},
		[4]={id="4",name="rete quattro",info="Io sto con gli Ippopotami", description="Film del 1979 diretto da Italo Zingarelli, interpretato da Bud Spenser, e Terens Hill"},
		[5]={id="5",name="canale cinque",info="C'e' posta per te", description="Programma di varieta'"},
		[6]={id="6",name="Italia uno",info="MotoGP", description="Riepilogo Gara MotoGP Qatar 2015"},
		[7]={id="7",name="sport uno",info="Calcio", description="Partita di Champions League"},
		[8]={id="8",name="Discovery Channel",info="Bear Grylls", description="Niente fa paura all'impavido Bear Grylls, che in questa famosissima serie, dispensa consigli per sopravvivere nelle situazioni piu estreme"},
		[9]={id="9",name="National Geographics",info="River Monsters", description="Serie televisiva condotta da Jeremy Wade, biologo e pescatore estremo"},
		[10]={id="10",name="Manga",info="Lupen terzo vs Conan", description="Film di Animazione Giapponese"},
		[11]={id="11",name="fox",info="Trono di spade", description="Serie TV tratta dal libro best seller George Martin"},
		[12]={id="12",name="cinema",info="Iron Man 3", description="Film d'Azione della Marvell"}

		}
	}
	self:write(channels)
end

function TestHandler:get()
	self:write("TEST")
end

turbo.web.Application({
    {"zapping", ZappingHandler},
    {"search", SearchHandler},
    {"info", InfoHandler},
    {"channels", ChannelsHandler},
    {"test", TestHandler},
    {"volume", VolumeHandler}
}):listen(8888)

log.success("Starting SUPER LUAJIT server on port 8888...")
log.debug("Handler Implemented:")
log.debug("zapping/        POST")
log.debug("search/         POST")
log.debug("info/           POST")
log.debug("channels/        GET")
log.debug("volume/         POST")
log.debug("------------------------------")

turbo.ioloop.instance():start()
