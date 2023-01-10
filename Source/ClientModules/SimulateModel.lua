--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 14/12/2022 23:48
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

-- Global functions are the main functions, whereas local functions are nothing more than their side-functions.

local WAITFORCHILD_TIMEOUT = 100

local NARROWER_MAXIMUM_WIDTH = 49.5
local NARROWER_PERIOD = 6
local ROOF_DESCENT_DISTANCE = 8.5

local middleTexts = {
	[1] = "Ekranın sol altındaki mavi çerçevede farenizin sağ tuşunu basılı tutup hareket ettirerek modeli döndürebilirsiniz.",
	[2] = "Ekranın sol altındaki mavi çerçevede farenizin tekerleğini döndürerek modele yakınlaştırma yapabilirsiniz.",
	[3] = "Simülasyonu tam ekranda izlemeniz önerilir."
}

local middleTextsUsed = {}
local activeTweens = {}

local Step2CFrame = CFrame.new(183.772293, 57.1374741, -196.426758, 1.00000024, 1.25858313e-09, 4.80326889e-12, 1.25858313e-09, 1.00000024, 2.32830644e-10, 4.80326889e-12, 2.32830644e-10, 1)

local wedgeAngle = math.deg(math.atan(62/5))
local horizontalDisplacement = math.sin(math.rad(wedgeAngle)) * (NARROWER_MAXIMUM_WIDTH) / 5
local verticalDisplacement = math.cos(math.rad(wedgeAngle)) * (NARROWER_MAXIMUM_WIDTH) / 5

local StepInfo = script:WaitForChild("StepInfo", WAITFORCHILD_TIMEOUT)
local stepInfo = require(StepInfo)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local internalCamera : Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local SimulationModels = ReplicatedStorage:WaitForChild("SimulationModels", WAITFORCHILD_TIMEOUT) :: Folder
local ProjectFolder = workspace:WaitForChild("Project", WAITFORCHILD_TIMEOUT)

local mainFrame = localPlayer:WaitForChild("PlayerGui", WAITFORCHILD_TIMEOUT):WaitForChild("2D", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT)

local viewportFrame = mainFrame:WaitForChild("ViewportFrame", WAITFORCHILD_TIMEOUT) :: ViewportFrame

local _2DModelDisplayArea = viewportFrame:WaitForChild("WorldModel", WAITFORCHILD_TIMEOUT) :: WorldModel
local MiddleText = mainFrame:WaitForChild("MiddleText", WAITFORCHILD_TIMEOUT) :: TextLabel

local ProjectModel : Model = ProjectFolder:FindFirstChildOfClass("Model")

local CameraSubjects = ProjectModel:WaitForChild("CameraSubjects", WAITFORCHILD_TIMEOUT) :: Folder
local MobileRoofConstraints = ProjectModel:WaitForChild("MobileRoofConstraints", WAITFORCHILD_TIMEOUT) :: Folder
local Conveyors = ProjectModel:WaitForChild("Conveyors", WAITFORCHILD_TIMEOUT) :: Folder
local RainDrops = ProjectModel:WaitForChild("RainDrops", WAITFORCHILD_TIMEOUT) :: Folder
local WaterContainers = ProjectModel:WaitForChild("WaterContainers", WAITFORCHILD_TIMEOUT) :: Folder
local Wedges = ProjectModel:WaitForChild("Wedges", WAITFORCHILD_TIMEOUT)

local Narrower = CameraSubjects:WaitForChild("Narrower", WAITFORCHILD_TIMEOUT) :: Part
local conveyor1texture, conveyor2texture = Conveyors:WaitForChild("RainTexture1", WAITFORCHILD_TIMEOUT):WaitForChild("Texture", WAITFORCHILD_TIMEOUT) :: Texture, Conveyors:WaitForChild("RainTexture2", WAITFORCHILD_TIMEOUT):WaitForChild("Texture", WAITFORCHILD_TIMEOUT) :: Texture
local DropEmitter = RainDrops:WaitForChild("DropEmitter", WAITFORCHILD_TIMEOUT) :: BasePart
local Eaves = RainDrops:WaitForChild("Eaves", WAITFORCHILD_TIMEOUT) :: UnionOperation

local isCreatingDropsPermitted = false

local mergeTablesMetatable = {
	__add = function(tab1, tab2)
		local newTab = tab1

		for i, v in tab2 do
			table.insert(newTab, v)
		end

		return newTab
	end,
}

local TInfo_Narrower : TweenInfo = TweenInfo.new(
	NARROWER_PERIOD,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local TInfo_LimitsEnabledRestricted : TweenInfo = TweenInfo.new(
	NARROWER_PERIOD + (NARROWER_PERIOD * (1 / 30)),
	Enum.EasingStyle.Circular,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TInfo_Conveyor : TweenInfo = TweenInfo.new(
	2,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local TInfo_Eaves : TweenInfo = TweenInfo.new(
	4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut,
	1,
	true,
	0
)

local TInfo_MiddleText : TweenInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local TInfo_Camera : TweenInfo = TweenInfo.new(
	3,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TInfo_transparency : TweenInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local function registerTween(tween : Tween)
	coroutine.wrap(function()
		table.insert(activeTweens, tween)
		
		tween.Completed:Connect(function()
			table.remove(activeTweens, table.find(activeTweens, tween))
		end)
	end)()
end

local function forceFinishAllTweens()
	for i, v in activeTweens do
		if v:IsA("Tween") and v.PlaybackState == Enum.PlaybackState.Playing then
			v:Cancel()
		end
	end
end

local function circulateMiddleText()
	local factor = false
	
	while _2DModelDisplayArea:FindFirstChildOfClass("Model") and ProjectFolder:FindFirstChildOfClass("Model") and script.Parent do
		local tween = TweenService:Create(MiddleText, TInfo_MiddleText, {TextTransparency = 1})
		registerTween(tween)

		tween:Play()
		tween.Completed:Wait()

		local rNumber = if not factor then math.random(1, table.getn(middleTexts)) else math.random(1, table.getn(middleTexts) - 1)
		local text = middleTexts[rNumber]

		table.remove(middleTexts, rNumber)
		table.insert(middleTextsUsed, text)

		MiddleText.Text = text	

		local tween = TweenService:Create(MiddleText, TInfo_MiddleText, {TextTransparency = 0})
		registerTween(tween)

		tween:Play()
		tween.Completed:Wait()

		if table.getn(middleTexts) == 0 then
			factor = true
			middleTexts = table.clone(middleTextsUsed)
			table.clear(middleTextsUsed)
		else
			factor = false
		end

		task.wait(3)
	end
end

local function calculateRandomXYZPosition(part : BasePart) : Vector3
	local commonFactor = 100000

	local xComponent = math.random((part.Position.X - (part.Size.X / 2)) * commonFactor, (part.Position.X + (part.Size.X / 2)) * commonFactor) / commonFactor
	local yComponent = math.random((part.Position.Y - (part.Size.Y / 2)) * commonFactor, (part.Position.Y + (part.Size.Y / 2)) * commonFactor) / commonFactor
	local zComponent = math.random((part.Position.Z - (part.Size.Z / 2)) * commonFactor, (part.Position.Z + (part.Size.Z / 2)) * commonFactor) / commonFactor

	return Vector3.new(xComponent, yComponent, zComponent)
end

local function repeatTween(tween : Tween, func : (...any) -> (...any))
	tween:Play()

	local thread = task.spawn(function()
		repeat
			tween.Completed:Wait()

			tween:Play()
		until tween.PlaybackState == Enum.PlaybackState.Cancelled and ProjectFolder:FindFirstChildOfClass("Model")
	end)

	tween.Completed:Connect(function(playbackState : Enum.PlaybackState)
		if playbackState == Enum.PlaybackState.Cancelled then
			task.cancel(thread)
		elseif playbackState == Enum.PlaybackState.Completed then
			if typeof(func) == "function" then
				func()
			elseif func ~= nil then
				error("Expected type function, got " .. typeof(func) .. " instead.")
			end
		end
	end)
end

local function arrangeDrops(stateToApply : boolean)	
	local changeVelocity = coroutine.create(function()
		local accelerationDimension = "+"

		local tween : Tween

		while not isCreatingDropsPermitted and ProjectFolder:FindFirstChildOfClass("Model") and script.Parent do
			tween = TweenService:Create(Eaves, TInfo_Eaves, {AssemblyLinearVelocity = Vector3.new(0, 0, if Eaves.AssemblyLinearVelocity.Z < 0 then 4 else -4)})
			registerTween(tween)
			
			tween:Play()

			tween.Completed:Wait()

			task.wait(0.1)
		end

		tween:Cancel()
	end)

	if stateToApply then
		isCreatingDropsPermitted = true

		coroutine.resume(changeVelocity)

		coroutine.wrap(function()
			while isCreatingDropsPermitted and ProjectFolder:FindFirstChildOfClass("Model") and script.Parent do
				local bluePart = Instance.new("Part")
				bluePart.CollisionGroup = "Drops"
				bluePart.Shape = Enum.PartType.Ball
				bluePart.Transparency = 0.2
				bluePart.Color = Color3.new(0.0313725, 0.611765, 1)
				bluePart.Size = Vector3.new(0.25, 0.25, 0.25)
				bluePart.Position = calculateRandomXYZPosition(DropEmitter)
				bluePart.Parent = DropEmitter

				task.wait(0.1)
			end
		end)()
	else
		isCreatingDropsPermitted = false
	end
end

local function disableConstraints()
	for i, v in ProjectModel:FindFirstChild("MobileRoofConstraints"):GetChildren() do
		local hingeConstraint = v:FindFirstChild("HingeConstraint") :: HingeConstraint

		if hingeConstraint.ActuatorType == Enum.ActuatorType.Servo then
			hingeConstraint.AngularResponsiveness = 5
			hingeConstraint.AngularSpeed = 0
		end
	end
end

local function moveRoof(boolean : boolean) -- Don't use this function as one of the steps of the simulation, use simulation:SetRoofState() instead.
	--// constantNum : total number of periods
	--// varNum : periods completed

	local constantNum, varNum = 5, -1

	local function iterate(numberToIterate, reversed)
		local max = 20

		if not reversed then
			return {math.min(numberToIterate, max), math.min(numberToIterate + 1, max), math.min(numberToIterate + 2, max), math.min(numberToIterate + 3, max)}
		else
			return {math.min((max - numberToIterate), max), math.min((max - numberToIterate) + 1, max), math.min((max - numberToIterate) + 2, max), math.min((max - numberToIterate + 3), max)}
		end
	end

	local wedge1, wedge2 = Wedges:FindFirstChild("Wedge1"):GetChildren() :: {}, Wedges:FindFirstChild("Wedge2"):GetChildren() :: {}

	local tab1, tab2 = setmetatable(wedge1, mergeTablesMetatable), setmetatable(wedge2, mergeTablesMetatable)
	local attachments = {}

	for i, v in tab1 + tab2 :: never do
		table.insert(attachments, v)
	end

	repeat
		varNum += 1

		local tween_Narrower = TweenService:Create(Narrower, TInfo_Narrower, {Position = Vector3.new(if boolean then Narrower.Position.X + horizontalDisplacement else Narrower.Position.X - horizontalDisplacement, if boolean then Narrower.Position.Y - verticalDisplacement else Narrower.Position.Y + verticalDisplacement, Narrower.Position.Z)})
		registerTween(tween_Narrower)

		tween_Narrower:Play()

		for iterated = varNum + 1, constantNum - 1, 1 do
			for i, ropeAttachment : Attachment in attachments :: never do
				coroutine.wrap(function()
					local newHorizontalDisplacement = math.sin(math.rad(wedgeAngle)) * (NARROWER_MAXIMUM_WIDTH) / 5
					local newVerticalDisplacement = math.cos(math.rad(wedgeAngle)) * (NARROWER_MAXIMUM_WIDTH) / 5

					local num = tonumber(string.match(ropeAttachment.Name, "%d+", 1)) :: number

					if num % 4 == 1 and num > ((varNum * 4) + 1) then
						local ropeTween1 = TweenService:Create(ropeAttachment, TInfo_Narrower, {WorldPosition = Vector3.new(if boolean then ropeAttachment.WorldPosition.X + newHorizontalDisplacement else ropeAttachment.WorldPosition.X - newHorizontalDisplacement, if boolean then ropeAttachment.WorldPosition.Y - newVerticalDisplacement else ropeAttachment.WorldPosition.Y + newVerticalDisplacement, ropeAttachment.WorldPosition.Z)})							
						registerTween(ropeTween1)

						ropeTween1:Play()

						local ropeTween2 = TweenService:Create(MobileRoofConstraints:FindFirstChild(string.match(ropeAttachment.Name, "%d+", 1)):FindFirstChild(ropeAttachment.Name), TInfo_Narrower, {WorldPosition = Vector3.new(if boolean then ropeAttachment.WorldPosition.X + newHorizontalDisplacement else ropeAttachment.WorldPosition.X - newHorizontalDisplacement, if boolean then ropeAttachment.WorldPosition.Y - newVerticalDisplacement else ropeAttachment.WorldPosition.Y + newVerticalDisplacement, ropeAttachment.WorldPosition.Z)})
						registerTween(ropeTween2)

						ropeTween2:Play()
					end
				end)()
			end
		end

		for i, order in iterate((varNum * 4) + 1, false) do
			local constraintNumber : Part = MobileRoofConstraints:FindFirstChild(tostring(order)) :: Part
			local constraint : HingeConstraint = constraintNumber:FindFirstChild("HingeConstraint") :: HingeConstraint

			constraint.AngularResponsiveness = 5
			constraint.AngularSpeed = 0

			coroutine.wrap(function()
				local tweenAngle

				if constraintNumber:GetAttribute("HingeTargetAngle") == 90 then
					tweenAngle = TweenService:Create(constraint, TInfo_LimitsEnabledRestricted, {LowerAngle = if boolean then 90 else -90})
					registerTween(tweenAngle)

					tweenAngle:Play()
				else
					tweenAngle = TweenService:Create(constraint, TInfo_LimitsEnabledRestricted, {UpperAngle = if boolean then -90 else 90})
					registerTween(tweenAngle)

					tweenAngle:Play()
				end

				local parent = constraint.Parent :: Instance

				for i, v in parent:GetChildren() do
					if v:IsA("RopeConstraint") then
						v.Enabled = false
					end
				end

				tweenAngle.Completed:Once(function()
					constraint.AngularResponsiveness = 5
					constraint.AngularSpeed = 0
				end)
			end)()
		end

		task.wait(NARROWER_PERIOD)
	until varNum == 4 and ProjectFolder:FindFirstChildOfClass("Model")
end

local function conveyDrops(state : boolean)
	local tween1 : Tween, tween2 : Tween

	local function transparency()
		if tween1 and tween1.PlaybackState == Enum.PlaybackState.Playing then
			tween1:Cancel()
		end

		if tween2 and tween2.PlaybackState == Enum.PlaybackState.Playing then
			tween2:Cancel()
		end

		tween1 = TweenService:Create(conveyor1texture, TInfo_Conveyor, {Transparency = if state then 0 else 1})
		tween2 = TweenService:Create(conveyor2texture, TInfo_Conveyor, {Transparency = if state then 0 else 1})
		registerTween(tween1)
		registerTween(tween2)

		tween1:Play()
		tween2:Play()
	end

	local tween_Conveyor1, tween_Conveyor2

	if state == nil then
		error("Please specify a state for conveying drops.")
	elseif state then
		tween_Conveyor1 = TweenService:Create(conveyor1texture, TInfo_Conveyor, {OffsetStudsV = conveyor1texture.OffsetStudsV - conveyor1texture.StudsPerTileV})
		tween_Conveyor2 = TweenService:Create(conveyor2texture, TInfo_Conveyor, {OffsetStudsV = conveyor2texture.OffsetStudsV - conveyor1texture.StudsPerTileV})
		registerTween(tween_Conveyor1)
		registerTween(tween_Conveyor2)

		repeatTween(tween_Conveyor1, function()
			conveyor1texture.OffsetStudsV = 0
		end)

		repeatTween(tween_Conveyor2, function()
			conveyor2texture.OffsetStudsV = 0
		end)

		transparency()
		arrangeDrops(true)
	else
		if tween_Conveyor1 and tween_Conveyor1.PlaybackState == Enum.PlaybackState.Playing then
			tween_Conveyor1:Cancel()
		end

		if tween_Conveyor2 and tween_Conveyor2.PlaybackState == Enum.PlaybackState.Playing then
			tween_Conveyor2:Cancel()
		end

		conveyor1texture.OffsetStudsV = 0
		conveyor2texture.OffsetStudsV = 0

		transparency()
		arrangeDrops(false)
	end
end

local function changeTransparency(namesOfPlaces : {string}, transparencyValue : number)
	for _, v in pairs(ProjectModel:GetChildren()) do
		if table.find(namesOfPlaces, v.Name) then
			for _, BasePart : BasePart in v:GetDescendants() do
				if BasePart:IsA("BasePart") then
					if transparencyValue ~= -1 then
						TweenService:Create(BasePart, TInfo_transparency, {Transparency = transparencyValue}):Play()
					else
						TweenService:Create(BasePart, TInfo_transparency, {Transparency = BasePart:GetAttribute("OriginalTransparency")}):Play()
					end
				end
			end
		end
	end
end

function SetRainDrops()
	local subject2 : BasePart = CameraSubjects:FindFirstChild("S2") :: BasePart
	local cont, f = true, 0.001

	--coroutine.wrap(function()
	--	while cont and ProjectFolder:FindFirstChildOfClass("Model") and script.Parent do
	--		subject2.Position = subject2.Position + Vector3.new(0, 0, f)
	--		f = -f
	--		task.wait()
	--	end
	--end)()

	internalCamera.CameraSubject = subject2

	conveyDrops(true)

	for i, v in WaterContainers:GetChildren() do
		if v:IsA("Model") then
			local waterMass = v:FindFirstChild("WaterMass")
			
			local tween = TweenService:Create(waterMass :: BasePart, TweenInfo.new(
				20,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut,
				0,
				false,
				0), 
				{Transparency = 0.2})
			
			registerTween(tween)

			tween:Play()
		end
	end

	task.wait(20)

	conveyDrops(false)

	task.wait(3)
	cont = false
end

function SetRoofState(state : boolean) : boolean
	internalCamera.CameraSubject = Narrower

	local _1 = MobileRoofConstraints:FindFirstChild("1") :: BasePart

	if state == nil then
		error("Please specify a state for the roof system.")
	end

	disableConstraints()

	if not state then
		local tween = TweenService:Create(Narrower, TInfo_Narrower, {Position = Vector3.new(Narrower.Position.X, Narrower.Position.Y + ROOF_DESCENT_DISTANCE, Narrower.Position.Z)})
		registerTween(tween)

		tween:Play()

		local tween2 = TweenService:Create(_1, TInfo_Narrower, {Position = Vector3.new(_1.Position.X, _1.Position.Y + ROOF_DESCENT_DISTANCE, _1.Position.Z)})
		registerTween(tween2)

		tween2:Play()

		tween.Completed:Wait()
	end

	moveRoof(state)

	local tween2

	if state then
		local tween = TweenService:Create(Narrower, TInfo_Narrower, {Position = Vector3.new(Narrower.Position.X, Narrower.Position.Y - ROOF_DESCENT_DISTANCE, Narrower.Position.Z)})
		registerTween(tween)

		tween:Play()

		tween2 = TweenService:Create(_1, TInfo_Narrower, {Position = Vector3.new(_1.Position.X, _1.Position.Y - ROOF_DESCENT_DISTANCE, _1.Position.Z)})
		registerTween(tween2)

		tween2:Play()
	end

	disableConstraints()

	if tween2 then
		tween2.Completed:Wait()
	end

	return true
end

function DispenseWater()
	changeTransparency({
		"CameraSubjects",
		"Conveyors",
		"external",
		"MobileRoofConstraints",
		"RainDrops",
		"Wedges"
	}, 0.95)
	
	internalCamera.CameraSubject = WaterContainers:WaitForChild("Soil", WAITFORCHILD_TIMEOUT)
	
	task.wait(20)
	
	changeTransparency({
		"CameraSubjects",
		"Conveyors",
		"external",
		"MobileRoofConstraints",
		"RainDrops",
		"Wedges"
	}, -1)
end

local functionsToApply : {[number] : (...any) -> (...any)} = {
	[1] = SetRoofState,
	[2] = SetRainDrops,
	[3] = DispenseWater
}

local steps = {}
local call

setmetatable(steps, {
	__newindex = function(self, index, value)
		if index == "simulationStep" then
			coroutine.wrap(function()
				call(value)
			end)()
		else
			rawset(self, index, value)
		end
	end,
	
	__index = function(self, key)
		if key == "SimulationStepChanged" then
			local customRBXConnection = {}
			
			function customRBXConnection:Connect(func)
				coroutine.wrap(function()
					call = func

					local disconnectRBXConnection = {
						Disconnect = function()
							coroutine.wrap(function()
								call = nil :: never
							end)()
						end,
					}

					return disconnectRBXConnection
				end)()
			end
			
			return customRBXConnection
		else
			return rawget(self, key)
		end
	end,
})

function steps:GetSimulationStep()
	return rawget(self, "simulationStep")
end


function steps:RetrieveStepInfoModule()
	return stepInfo
end

function steps:ExertAllFromTheBeginning(dimension : string)
	steps.simulationStep = 0

	repeat
		task.wait()
	until MiddleText.TextTransparency == 1 and ProjectFolder:FindFirstChildOfClass("Model")

	if dimension == "2D" then
		--handle2D()
	end

	coroutine.wrap(function()	
		circulateMiddleText()
	end)()
	
	steps.simulationStep = 1
	functionsToApply[1](false)
	steps.simulationStep = 2
	functionsToApply[2]()
	steps.simulationStep = 3
	functionsToApply[1](true)
	steps.simulationStep = 4
	functionsToApply[3]()
	steps.simulationStep = 5
	task.wait(20)
	internalCamera.CameraSubject = ProjectFolder
	steps.simulationStep = 0

	return true
end

function steps:Stop()
	forceFinishAllTweens()
	
	WAITFORCHILD_TIMEOUT = 100

	NARROWER_MAXIMUM_WIDTH =  nil :: never
	NARROWER_PERIOD =  nil :: never
	ROOF_DESCENT_DISTANCE = nil :: never

	middleTexts = nil :: never

	middleTextsUsed = nil :: never
	activeTweens = nil :: never

	Step2CFrame =  nil :: never
	wedgeAngle = nil :: never
	horizontalDisplacement = nil :: never
	verticalDisplacement = nil :: never

	ReplicatedStorage = nil :: never
	TweenService =  nil :: never
	Players = nil :: never
	UserInputService = nil :: never
	ContextActionService = nil :: never

	internalCamera = nil :: never
	localPlayer = nil :: never

	SimulationModels = nil :: never
	ProjectFolder = nil :: never

	mainFrame = nil :: never

	viewportFrame = nil :: never

	_2DModelDisplayArea = nil :: never
	MiddleText = nil :: never

	ProjectModel = nil :: never

	Narrower = nil :: never

	ProjectModel = nil :: never

	CameraSubjects = nil :: never
	MobileRoofConstraints = nil :: never
	Conveyors = nil :: never
	RainDrops = nil :: never
	WaterContainers = nil :: never

	Narrower = nil :: never
	conveyor1texture, conveyor2texture = nil :: never, nil :: never
	DropEmitter = nil :: never
	Eaves = nil :: never

	isCreatingDropsPermitted = false

	mergeTablesMetatable = nil :: never

	TInfo_Narrower = nil :: never
	TInfo_LimitsEnabledRestricted = nil :: never

	TInfo_Conveyor = nil :: never

	TInfo_Eaves = nil :: never

	TInfo_MiddleText = nil :: never

	TInfo_Camera = nil :: never
	registerTween = nil :: never
	forceFinishAllTweens = nil :: never
	circulateMiddleText = nil :: never
	calculateRandomXYZPosition = nil :: never
	repeatTween = nil :: never
	arrangeDrops = nil :: never
	disableConstraints = nil :: never
	moveRoof = nil :: never
	conveyDrops = nil :: never
	
	return
end

return steps
