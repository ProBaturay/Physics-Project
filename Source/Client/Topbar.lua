--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 11/12/2022 22:22
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local WAITFORCHILD_TIMEOUT = 100

local RunService = game:GetService("RunService")

local localPlayer : Player = script.Parent.Parent.Parent
local PlayerGui = localPlayer:WaitForChild("PlayerGui", WAITFORCHILD_TIMEOUT)
local Topbar = PlayerGui:WaitForChild("Topbar", WAITFORCHILD_TIMEOUT)

local TopbarFrame = Topbar:WaitForChild("Frame")
local FPS = TopbarFrame:WaitForChild("FPS", WAITFORCHILD_TIMEOUT) :: TextLabel
local Latency = TopbarFrame:WaitForChild("Latency", WAITFORCHILD_TIMEOUT) :: TextLabel

local topbarModule = {}

function topbarModule:FPS()
	coroutine.wrap(function()
		while true do
			FPS.Text = "Saniye Başına Kare: " .. math.floor(1 / RunService.RenderStepped:Wait())
			task.wait(0.1)
		end
	end)()
end

function topbarModule:Ping()
	coroutine.wrap(function()
		while true do
			Latency.Text = "Gecikme: ".. tostring(math.floor(localPlayer:GetNetworkPing() * 1000)) .. " ms"
			task.wait(0.1)
		end
	end)()
end

return topbarModule
