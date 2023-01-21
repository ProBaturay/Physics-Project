--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 15/10/2022 23:36
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local trackTypes = {
	[1] = "ExploitsAccessToServer",
	[2] = "MouseLeaveAndMouseEnterCoincide",
	[3] = "ResetButtonCallbackUnprompted",
	[4] = "PlayerAddedEventFiredArbitrarily",
	[5] = "PlayerAddedEventFiredAfterPlayerRemoving",
	[6] = "ContentLoadingFailed",
	[7] = "ContentLoadingExceededAllowedTime"
}

local typeEquivalents = {
	["ExploitsAccessToServer"] = "Müşteri, sunucu tarafına elle girmeye çalıştı.",
	["MouseLeaveAndMouseEnterCoincide"] = "GuiObject.MouseLeave ve GuiObject.MouseEnter olayları çakıştı.",
	["ResetButtonCallbackUnprompted"] = "Karakter sıfırlama düğmesi devre dışı bırakılamadı.",
	["PlayerAddedEventFiredArbitrarily"] = "Players.PlayerAdded olayı ikinci kez işlev gördü.",
	["PlayerAddedEventFiredAfterPlayerRemoving"] = "Players.PlayerRemoving olayı Players.PlayerAdded olayından önce meydana geldi.",
	["ContentLoadingFailed"] = "ContentProvider:PreloadAsync() işlevi içeriği yükleyemedi.",
	["ContentLoadingExceededAllowedTime"] = "ContentProvider:PreloadAsync() işlevi izin verilen sürede kullanılamadı."
}

local metaTrackData = setmetatable({}, {
	__index = function(tab, key)
		if rawget(tab, key) then
			return tab[key]
		else
			tab[key] = {}
			return tab[key]
		end
	end,

	__newindex = function(tab, key, value)
		rawset(tab, key, value)
	end,
})

local track = {}

function track:Validate<g1, g2>(targetUserId : number, tab : {[number] : g1 | g2}, func : (...any) -> (...any)?) : boolean
	if typeof(tab) ~= "table" then
		error("Expected type 'table', got" .. typeof(tab) .. " instead.")
	end	
	
	if not tab[1] then
		table.insert(metaTrackData[targetUserId], typeEquivalents[tab[2]])
		
		if typeof(func) == "function" then
			task.spawn(func)
		end
		
		return false
	end
	
	return true
end

function track:ReturnSessionTracking() : typeof(setmetatable({}, {}))
	return metaTrackData
end

return track
