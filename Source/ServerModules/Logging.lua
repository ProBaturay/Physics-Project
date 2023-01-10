--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 18/11/2022 15:23
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local canOutputWarnings = game:GetService("ReplicatedStorage"):WaitForChild("DevelopmentRelated", 1000):WaitForChild("canOutputWarnings", 1000).Value
local CollectionService = game:GetService("CollectionService")

local function count(scr)
	local counted = 0
	
	xpcall(function()
		local source = scr.Source

		for i in string.gmatch(source, "\n") do
			counted += 1
		end
	end, function()
		if canOutputWarnings then
			warn("The current environment does not permit the engine to perform the following code." .. debug.traceback())
		end
	end)
		
	return counted
end

local logging = {}

function logging:CountLinesOfCode(locations : {[number] : Instance?}?)
	local linesOfCode = 0
	
	local scripts = CollectionService:GetTagged("DeveloperContent")
	
	--if locations then
	--	if type(locations) ~= "table" then
	--		if canOutputWarnings then
	--			error("Expected type 'table', got " .. type(locations) .. " instead.")
	--		end
	--	end
	--end

	if locations then
		for i, v in scripts do
			if table.find(locations, v) then
				linesOfCode += count(v)
			end
		end
	else
		for i, v in scripts do
			linesOfCode += count(v)
		end
	end
	
	return linesOfCode
end

return logging
