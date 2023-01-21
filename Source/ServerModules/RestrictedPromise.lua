--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 15/10/2022 23:25
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

--export type RestrictedPromise = {
--	ModifyDatastore : (dataStore : DataStore, method : string, ...any) -> (boolean?)
--}

local areDatastoresActive = false -- whether datastores are in use or not
local AccessToDatastoreEnabled = true -- whether the game blocked datastores or not

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local canOutputWarnings = ReplicatedStorage:WaitForChild("DevelopmentRelated", 100):WaitForChild("canOutputWarnings", 100).Value

if not AccessToDatastoreEnabled then
	if canOutputWarnings then
		warn("DatastoreService is blocked. Please enable it via game settings.")
	end
else
	if not areDatastoresActive then
		if canOutputWarnings then
			warn("No datastore is used at the moment.")
		end
	end
end

local restrictedPromise = {}

function restrictedPromise:ModifyDataStore(dataStore : DataStore, method : string, ...)
	--| 1: datastore
	--| 2: method "set" "update"
	--| 3: player UserId
	--| 4: dataToStore
	if areDatastoresActive and AccessToDatastoreEnabled then
		local packed = {...}
		local success, err = nil, nil
		
		if string.lower(method) == "set" then
			repeat
				success, err = pcall(function()
					dataStore:SetAsync(packed[1], packed[2])
				end)
			until success
		elseif string.lower(method) == "update" then
			repeat
				success, err = pcall(function()
					dataStore:UpdateAsync(packed[1], function(currentValue)
						local newValue = {}
						
						if currentValue then							
							newValue = currentValue
						end
						
						local typ = typeof(packed[2])
						
						if typ == "table" then
							newValue = if typeof(currentValue) == "table" then currentValue else {}
							
							for i, v in pairs(packed[2]) do
								table.insert(newValue, v)
							end
						end
						
						return newValue
					end)
				end)
			until success
		end
	end
	
	return true
end

return restrictedPromise
