--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 6/10/2022 20:15
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local WAITFORCHILD_TIMEOUT = 100
local SECURITY_KEY = "  ᠎‍ 	​    	  ​ ‌    　 ⁠    ⁠     ​ ⁠⁠　           ‌ ‌​ ​  　  ‌	          　 ᠎​           ᠎   	 ​⁠ ‍   ​​  ‍  　     ⁠ ‍  	   ​   ​  ‍    ⁠   ᠎   ᠎    ᠎​  ‌​  ‍     ​  ᠎    ᠎     　      ‌	​​     ‍  ‌‌ 	 ⁠ 　    	  	᠎ ‌‍　 	 ⁠  ‌ ​    ‌　      ᠎‌‍  ‍   	  ᠎‌᠎　‍      ‌᠎ ​   ⁠       	    　 ‌ ‍ 		    　        ‍       ᠎  ‌　᠎  	  ⁠‌   ᠎ ​　   ⁠    	    ᠎  　   ‍           ᠎ ‍ ‌         　 ‍    　    ​     ‍   ​     ⁠ 	          ⁠ ​  ⁠		      ⁠ ‍ ᠎    ⁠	  　    ‌​ ⁠     	     ᠎‌ 　        ᠎ 	  ‌   	‌ ‍ ‍‌     　  ‌        ‍  ​   ​      ​‌    ‌    	  ⁠   ⁠᠎  ‍  ᠎    ᠎ 	᠎     	       ‍  	 ‍⁠   ‍ 　​ 	   ⁠᠎  ‌ ​   　 ​ ᠎​　 	 ⁠  ​  ‍  　 ​        　  ​  　⁠     　    ‌        　​        	⁠‌᠎  ‍     ‍ ‍᠎    ​      ‌   ‍  ‌‌	 ‌​  ​​᠎᠎᠎    ⁠⁠   　               ‍  ​ ​    ​ ‍     ᠎‌　   ‍ ⁠⁠   ‌ ⁠    	  ‍ 	  	​      ⁠       ⁠⁠ ​ 　  ‍          ​ 	        ‍	 ‍  ​  	   ​     	  　     	       	  ᠎         　	  	  	    ‌  ‍  ᠎᠎  ⁠	 	         ᠎⁠ ​  ⁠    ‍　  　              ​      	　 ‍⁠  ⁠ ⁠ "

local traceTypes = {
	[1] = "ExploitAccessToServer",
	[2] = "MouseLeaveAndMouseEnterCoincide",
	[3] = "ResetButtonCallbackUnprompted"
}

local playerData = setmetatable({}, {
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

local locations1, scripts_exceptional1 = {
	game:GetService("StarterGui"),
	game:GetService("StarterPlayer"),
	game:GetService("StarterPack"),
	game:GetService("ServerStorage"),
	game:GetService("ServerScriptService"),
	game:GetService("ReplicatedStorage")
}, {
	game:GetService("ServerScriptService"):WaitForChild("ChatServiceRunner", WAITFORCHILD_TIMEOUT)
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DatastoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteControls = ReplicatedStorage:WaitForChild("RemoteControls", WAITFORCHILD_TIMEOUT)
local TraceData = RemoteControls:WaitForChild("TraceData", WAITFORCHILD_TIMEOUT)

local Utility = require(ServerStorage:WaitForChild("Utility", WAITFORCHILD_TIMEOUT))
local restrictedPromiseModule = Utility.RestrictedPromise()
local trackModule = Utility.Track()

local userIdsToStore = {}

local datastoreOptions = Instance.new("DataStoreOptions")

local dataStore_visitorData = DatastoreService:GetDataStore("VisitorData", nil, datastoreOptions)
local dataStore_visitorData_encounteredBugs = DatastoreService:GetDataStore("VisitorData/EncounteredBugs", nil, datastoreOptions)

coroutine.wrap(function()
	for i, v in locations1 do
		for i, v2 in v:GetDescendants() do
			if v2:IsA("LuaSourceContainer") then
				if not table.find(scripts_exceptional1, v2) then
					CollectionService:AddTag(v2, "DeveloperContent")
				end
			end
		end
	end
	
	ReplicatedStorage:WaitForChild("SimulationModels", WAITFORCHILD_TIMEOUT):WaitForChild("S1", WAITFORCHILD_TIMEOUT):Destroy()
	
	local SampleProjectModel = workspace:WaitForChild("Project", WAITFORCHILD_TIMEOUT):WaitForChild("S1"):Clone()
	SampleProjectModel.Parent = ReplicatedStorage.SimulationModels
		
	for i, v in SampleProjectModel:GetDescendants() do	
		if v:IsA("BasePart") then
			v:SetAttribute("BasePartAssigned", tostring(i))
		elseif v:IsA("Texture") then
			v:SetAttribute("TextureAssigned", tostring(i))
		end
	end

	for i, v in SampleProjectModel:GetDescendants() do
		if v:IsA("BasePart") and not v.Anchored then
			v.CollisionGroup = "WithoutDrops"
		end
	end
end)()

ServerStorage:WaitForChild("PlayerJoined", 1000).Event:Connect(function(player)
	table.insert(userIdsToStore, player.UserId)
end)

ServerStorage:WaitForChild("PlayerLeft", 1000).Event:Connect(function(player)
	local totalEncountered = {}
	
	--for i, v in playerData[userId] do
	--	if not next(totalEncountered[v], i) then
			
	--	end
	--end
	
	--restrictedPromiseModule:ModifyDataStore(dataStore_visitorData_encounteredBugs, "Update", player.UserId, {typeEquivalents["ExploitsAccessToServer"]})

	if userIdsToStore[player.UserId] then
		userIdsToStore[player.UserId] = nil
	end
end)

--local status, err = false, ""

--repeat
--	status, err = pcall(function()
--		dataStore_visitorData:GetAsync("STATUS")
--	end)
	
--	if (not status and err ~= nil) and (string.find(err, "Cannot write to DataStore from studio if API access is not enabled") or string.find(err,  "Studio access to APIs is not allowed")) then
--		AccessToDatastoreEnabled = false
--		status = true
--	elseif status then
--		AccessToDatastoreEnabled = true
--		status = true
--		break
--	end
--until status

TraceData.OnServerEvent:Connect(function(player, key : string, traceType : string)
	local accessGranted1 = trackModule:Validate(player, {[1] = key == SECURITY_KEY, [2] = "ExploitsAccessToServer"})
	local accessGranted2 = trackModule:Validate(player, {[1] = table.find(traceTypes, traceType), [2] = "ExploitsAccessToServer"})
	
	if accessGranted1 and accessGranted2 then
		trackModule:Validate(player, {[1] = true, [2] = traceType})
	end

	--restrictedPromiseModule:ModifyDataStore(dataStore_visitorData_encounteredBugs, "Update", player.UserId, {typeEquivalents["ExploitsAccessToServer"]})
end)
