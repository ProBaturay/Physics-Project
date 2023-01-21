--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 30/09/2022 19:13
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local SECURITY_KEY = "  ᠎‍ 	​    	  ​ ‌    　 ⁠    ⁠     ​ ⁠⁠　           ‌ ‌​ ​  　  ‌	          　 ᠎​           ᠎   	 ​⁠ ‍   ​​  ‍  　     ⁠ ‍  	   ​   ​  ‍    ⁠   ᠎   ᠎    ᠎​  ‌​  ‍     ​  ᠎    ᠎     　      ‌	​​     ‍  ‌‌ 	 ⁠ 　    	  	᠎ ‌‍　 	 ⁠  ‌ ​    ‌　      ᠎‌‍  ‍   	  ᠎‌᠎　‍      ‌᠎ ​   ⁠       	    　 ‌ ‍ 		    　        ‍       ᠎  ‌　᠎  	  ⁠‌   ᠎ ​　   ⁠    	    ᠎  　   ‍           ᠎ ‍ ‌         　 ‍    　    ​     ‍   ​     ⁠ 	          ⁠ ​  ⁠		      ⁠ ‍ ᠎    ⁠	  　    ‌​ ⁠     	     ᠎‌ 　        ᠎ 	  ‌   	‌ ‍ ‍‌     　  ‌        ‍  ​   ​      ​‌    ‌    	  ⁠   ⁠᠎  ‍  ᠎    ᠎ 	᠎     	       ‍  	 ‍⁠   ‍ 　​ 	   ⁠᠎  ‌ ​   　 ​ ᠎​　 	 ⁠  ​  ‍  　 ​        　  ​  　⁠     　    ‌        　​        	⁠‌᠎  ‍     ‍ ‍᠎    ​      ‌   ‍  ‌‌	 ‌​  ​​᠎᠎᠎    ⁠⁠   　               ‍  ​ ​    ​ ‍     ᠎‌　   ‍ ⁠⁠   ‌ ⁠    	  ‍ 	  	​      ⁠       ⁠⁠ ​ 　  ‍          ​ 	        ‍	 ‍  ​  	   ​     	  　     	       	  ᠎         　	  	  	    ‌  ‍  ᠎᠎  ⁠	 	         ᠎⁠ ​  ⁠    ‍　  　              ​      	　 ‍⁠  ⁠ ⁠ "
local WAITFORCHILD_TIMEOUT = 100
local currentPlayers = {}

local TInfo_Narrower : TweenInfo = TweenInfo.new(
	2,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local Utility = require(ServerStorage:WaitForChild("Utility", WAITFORCHILD_TIMEOUT))
local trackModule = Utility.Track()

local path : Path = PathfindingService:CreatePath({
	AgentRadius = 1,
	AgentHeight = 3,
	WaypointSpacing = math.huge,
	Costs = {
		Grass = 6,
		Asphalt = 0.5
	}
	
})

local ProjectFolder = workspace:WaitForChild("Project", WAITFORCHILD_TIMEOUT)

local RemoteControls = ReplicatedStorage:WaitForChild("RemoteControls", WAITFORCHILD_TIMEOUT)

local Hitboxes = workspace:WaitForChild("Hitboxes", WAITFORCHILD_TIMEOUT)
local Objects = workspace:WaitForChild("Objects", WAITFORCHILD_TIMEOUT)

local HouseDoorHitbox = Hitboxes:WaitForChild("HouseDoor", WAITFORCHILD_TIMEOUT)

local houseDoor : BasePart = Objects:WaitForChild("Door", WAITFORCHILD_TIMEOUT) :: BasePart

local humanoidCollisionId = PhysicsService:RegisterCollisionGroup("HumanoidCollision")

local doorCollisionId = PhysicsService:RegisterCollisionGroup("DoorAnimation_Door")
local exceptDoorCollisionId = PhysicsService:RegisterCollisionGroup("DoorAnimation_ExceptDoor")

local DropsCollisionGroup = PhysicsService:RegisterCollisionGroup("Drops")
local WithoutDropsCollisionGroup = PhysicsService:RegisterCollisionGroup("WithoutDrops")

local function forPlayerAdded(player : Player) : any?
	if table.find(currentPlayers, player) then
		return trackModule:Validate(player.UserId, {[1] = true, [2] = "PlayerAddedEventFiredArbitrarily" :: never})
	else
		table.insert(currentPlayers, player)
	end

	coroutine.wrap(function()
		ServerStorage:WaitForChild("PlayerJoined", 1000):Fire(player)
		player.Neutral = false
	end)()

	local character = player.Character or player.CharacterAdded:Wait()	
	local Humanoid : Humanoid = character:WaitForChild("Humanoid", WAITFORCHILD_TIMEOUT) :: Humanoid
	local HumanoidRootPart : Part = character:WaitForChild("HumanoidRootPart", WAITFORCHILD_TIMEOUT) :: Part

	for i, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "HumanoidCollision"
		end
	end

	character.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "HumanoidCollision"
		end
	end)

	character:PivotTo(CFrame.new(11.3901119, 47.6095238, -223.265366, -0.336827934, 0.0186916813, -0.941380739, -0, 0.999803007, 0.0198516902, 0.941566229, 0.00668660365, -0.336761564))

	local waypoints : {[number] : PathWaypoint}

	local success, err

	repeat
		success, err = pcall(function()
			path:ComputeAsync(Vector3.new(11.3901119, 47.6095238, -223.265366), Vector3.new(195.741913, 50.2618484, -215.85817))
		end)
	until success

	waypoints = path:GetWaypoints()

	for i, v in waypoints do
		Humanoid:MoveTo(v.Position)
		Humanoid.MoveToFinished:Wait()
	end
	
	return
end

coroutine.wrap(function()
	for i, player in Players:GetPlayers() do
		forPlayerAdded(player)
	end
end)()

Players.PlayerAdded:Connect(function(player : Player)
	forPlayerAdded(player)
end)

Players.PlayerRemoving:Connect(function(player : Player)
	local playerInTable = table.find(currentPlayers, player)
	
	if table.find(currentPlayers, player) then
		table.remove(currentPlayers, playerInTable)
	else
		trackModule:Validate(player.UserId, {[1] = true, [2] = "PlayerAddedEventFiredAfterPlayerRemoving" :: never})
	end

	ServerStorage:WaitForChild("PlayerLeft", WAITFORCHILD_TIMEOUT):Fire(player)
end)

houseDoor.CollisionGroup = "DoorAnimation_Door"

for i : number, v : BasePart in Objects:GetDescendants() do
	if v:IsA("BasePart") and v.Name ~= "Door" then
		if v:CanSetNetworkOwnership() then
			v:SetNetworkOwnershipAuto()
		end
		
		v.CollisionGroup = "DoorAnimation_ExceptDoor"
	elseif v:IsA("BasePart") and v.Name == "Door" then
		v.CollisionGroup = "DoorAnimation_Door"
	end
end

HouseDoorHitbox.CollisionGroup = "DoorAnimation_ExceptDoor"

PhysicsService:CollisionGroupSetCollidable("DoorAnimation_Door", "DoorAnimation_ExceptDoor", false)
PhysicsService:CollisionGroupSetCollidable("HumanoidCollision", "DoorAnimation_Door", true)

PhysicsService:CollisionGroupSetCollidable("WithoutDrops", "Drops", true)
