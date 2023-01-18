--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 14/12/2022 22:06
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local WAITFORCHILD_TIMEOUT = 100
local BLACKOUT_WAITTIME = 0.7

local simulationStarted = false
local simulationEnded = false
local simulationEndingCall = false
local allTweensFinished = false

local startButtonText = "Bu düğmeye basarak ortadaki model ile simülasyonu en başından başlatıp en sonuna kadar bitirmiş olursunuz. Her bir simülasyon adımı için bilgiler verilecektir. Hava durumu, topraktaki nem oranı gibi özellikler..."
local lastCoverText = ""

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local ProjectFolder = workspace:WaitForChild("Project", WAITFORCHILD_TIMEOUT)

local internalCamera : Camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local PlayerGui : PlayerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local BeginningScreenGUI : ScreenGui = PlayerGui:WaitForChild("Beginning", WAITFORCHILD_TIMEOUT) :: ScreenGui
local BlackoutScreenGUI : ScreenGui = PlayerGui:WaitForChild("Blackout", WAITFORCHILD_TIMEOUT) :: ScreenGui
local BlackoutFrame : Frame = BlackoutScreenGUI:WaitForChild("Blackout", WAITFORCHILD_TIMEOUT) :: Frame

local Modules = ReplicatedStorage:WaitForChild("Modules", WAITFORCHILD_TIMEOUT)
local SimulateModelModule = Modules:WaitForChild("SimulateModel", WAITFORCHILD_TIMEOUT)

local simulateModelCloned, simulateModel
local lightingModule = require(Modules:WaitForChild("Lighting", WAITFORCHILD_TIMEOUT))
local RefreshModel = require(script:WaitForChild("RefreshModel", WAITFORCHILD_TIMEOUT))

local mainFrame = localPlayer:WaitForChild("PlayerGui", WAITFORCHILD_TIMEOUT):WaitForChild("2D", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT) :: Frame
local viewportFrame = mainFrame:WaitForChild("ViewportFrame", WAITFORCHILD_TIMEOUT) :: ViewportFrame

local leftFrame = mainFrame:WaitForChild("LeftFrame", WAITFORCHILD_TIMEOUT) :: ViewportFrame
local rightFrame = mainFrame:WaitForChild("RightFrame", WAITFORCHILD_TIMEOUT) :: ViewportFrame

local leftSubFrame = leftFrame:WaitForChild("Frame", WAITFORCHILD_TIMEOUT)
local rightSubFrame = rightFrame:WaitForChild("Frame", WAITFORCHILD_TIMEOUT)

local IndependentMovementZone = leftSubFrame:WaitForChild("IndependentMovementZone", WAITFORCHILD_TIMEOUT) :: Frame
local StartButton = leftSubFrame:WaitForChild("Start", WAITFORCHILD_TIMEOUT) :: TextButton

local properties = leftSubFrame:WaitForChild("Properties") :: Frame
local properties_Awning = properties:WaitForChild("Awning") :: Frame
local properties_Weather = properties:WaitForChild("Weather") :: Frame
local properties_SoilMoisture = properties:WaitForChild("SoilMoisture") :: Frame
local properties_Fullness = properties:WaitForChild("Fullness") :: Frame

local Awning_Desc = properties_Awning:WaitForChild("Description") :: TextLabel
local Weather_Desc = properties_Weather:WaitForChild("Description") :: TextLabel
local SoilMoisture_Desc = properties_SoilMoisture:WaitForChild("Description") :: TextLabel
local Fullness_Desc = properties_Fullness:WaitForChild("Description") :: TextLabel

local rightScrollingFrame = rightSubFrame:WaitForChild("ScrollingFrame", WAITFORCHILD_TIMEOUT) :: ScrollingFrame

local Possibilities = rightScrollingFrame:WaitForChild("Possibilities", WAITFORCHILD_TIMEOUT) :: Frame
local Reality = rightScrollingFrame:WaitForChild("Reality", WAITFORCHILD_TIMEOUT) :: Frame
local State = rightScrollingFrame:WaitForChild("State", WAITFORCHILD_TIMEOUT) :: Frame

local State_Desc = State:WaitForChild("Description", WAITFORCHILD_TIMEOUT) :: TextLabel
local Possibilities_Desc = Possibilities:WaitForChild("Description", WAITFORCHILD_TIMEOUT) :: TextLabel

local realityCanvasGroup = Reality:WaitForChild("CanvasGroup", WAITFORCHILD_TIMEOUT) :: CanvasGroup
local reality_actualizable = realityCanvasGroup:WaitForChild("Actualizable", WAITFORCHILD_TIMEOUT) :: TextLabel
local reality_cost = realityCanvasGroup:WaitForChild("Cost", WAITFORCHILD_TIMEOUT) :: TextLabel
local reality_speedUp = realityCanvasGroup:WaitForChild("SpeedUp", WAITFORCHILD_TIMEOUT) :: TextLabel
local reality_suitable = realityCanvasGroup:WaitForChild("Suitable", WAITFORCHILD_TIMEOUT) :: TextLabel

local ReturnToMainMenuButton : TextButton = rightSubFrame:WaitForChild("ReturnToMainMenu", WAITFORCHILD_TIMEOUT) :: TextButton

local CoverText = rightSubFrame:WaitForChild("CoverText", WAITFORCHILD_TIMEOUT) :: TextLabel

local camStartCFrame = CFrame.new(-6.83833981, 66.4214401, -135.935471, 0.709502637, 0.0701519921, -0.701202393, 3.7252903e-09, 0.995032787, 0.0995483398, 0.704702795, -0.0706298128, 0.705978394)

local TInfo_Fade : TweenInfo = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TInfo_Environment : TweenInfo = TweenInfo.new(
	20,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local perform = {
	CurrentSimulationSession = {
		Started = os.clock(),
		Active = false,
		Finished = os.clock(),
	}
}

local _2DWaived = false
local boundAction = false

local function confirm(check, button)
	local confirmTime = os.clock() + 3

	while confirmTime > os.clock() and check do
		button.Text = "   Emin misiniz? (" .. math.floor(confirmTime - os.clock()) + 1 .. ")   "
		task.wait()
	end
end

local function mouseInIndependentMovementZone() -- This doesn't apply if the GuiObject has a UICorner class
	local v2 = UserInputService:GetMouseLocation()

	local Px, Py = IndependentMovementZone.AbsolutePosition.X, IndependentMovementZone.AbsolutePosition.Y
	local Sx, Sy = IndependentMovementZone.AbsoluteSize.X, IndependentMovementZone.AbsoluteSize.Y
	local Mostx, Leastx, Mosty, Leasty = Px + Sx, Px, Py + Sy + 36, Py + 36

	if Mostx > v2.X and Leastx < v2.X and Mosty > v2.Y and Leasty < v2.Y then
		if boundAction then
			boundAction = false
			ContextActionService:UnbindAction("MouseMovement2D")
		end
	else
		if not boundAction then
			ContextActionService:BindAction("MouseMovement2D", function()
				return false
			end, false, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseWheel)

			boundAction = true
		end
	end
end

local function mouseMovementIn2D()
	coroutine.wrap(function()
		while not simulationEndingCall do
			task.wait()
			mouseInIndependentMovementZone()
		end
	end)()
end

local function on2DReset()
	internalCamera.CameraType = Enum.CameraType.Custom
	internalCamera.CameraSubject = ProjectFolder:FindFirstChildOfClass("Model")

	ReturnToMainMenuButton.Text = "   Ana Menüye Dön   "
	
	rightScrollingFrame.Visible = false
	properties.Visible = false
	StartButton.Visible = true
	CoverText.Visible = true
end

local function onSetup(conn1)
	local c1_1 = StartButton.Activated:Connect(function()		
		StartButton.Visible = false
		CoverText.Visible = false
		properties.Visible = true
		
		simulationStarted = true
		rightScrollingFrame.Visible = true
		simulateModel:ExertAllFromTheBeginning("2D")
	end)

	local playerToConfirm_1, playerToConfirm_2 = false, false

	local c2_1 = ReturnToMainMenuButton.Activated:Connect(function()
		if not playerToConfirm_1 then	
			playerToConfirm_1 = true

			local conn : RBXScriptConnection
			
			conn = ReturnToMainMenuButton.Activated:Connect(function()
				_2DWaived = true
				conn:Disconnect()
			end)

			local confirmTime = os.clock() + 3

			while confirmTime > os.clock() and playerToConfirm_1 do
				ReturnToMainMenuButton.Text = "   Emin misiniz? (" .. math.floor(confirmTime - os.clock()) + 1 .. ")   "
				task.wait()
			end

			conn:Disconnect()

			if not playerToConfirm_1 then
				coroutine.wrap(function()
					playerToConfirm_1 = false

					ReturnToMainMenuButton.Text = "   Dönülüyor   "
				end)()

				perform:EndEntireSimulation()
				perform:ToMainMenu()
			else
				ReturnToMainMenuButton.Text = "   Ana Menüye Dön   "
			end
		end
		
		playerToConfirm_1 = false
	end)
	
	local c1_2 = StartButton.MouseEnter:Connect(function()
		CoverText.Text = startButtonText
	end)

	local c1_3 = StartButton.MouseLeave:Connect(function()
		CoverText.Text = ""
	end)

	while not simulationEndingCall do
		task.wait()
	end

	c1_1:Disconnect()
	c1_2:Disconnect()
	c1_3:Disconnect()
	c2_1:Disconnect()
	
	--conn1:Disconnect()
end

function perform:Setup2D(dimension)
	simulationEnded = false
	simulationStarted = false
	simulationEndingCall = false
	
	mainFrame.BackgroundTransparency = 0
	viewportFrame.Visible = true
	
	on2DReset()
	
	local isRefreshed, _2DModel, _3DModel = RefreshModel:RefreshModel("Both", 1)
	
	simulateModelCloned = SimulateModelModule:Clone()
	simulateModelCloned.Parent = script
	simulateModel = require(simulateModelCloned) :: never
	
	local stepInfoModule = simulateModel:RetrieveStepInfoModule() :: {}

	local conn1 = simulateModel.SimulationStepChanged:Connect(function(step)
		if step ~= 0 then
			State_Desc.Text = stepInfoModule[step].State
			Possibilities_Desc.Text = stepInfoModule[step].Possibilities
		
			reality_cost.Text = stepInfoModule[step].Reality["Cost"]
			reality_actualizable.Text = stepInfoModule[step].Reality["Actualizable"]
			reality_speedUp.Text = stepInfoModule[step].Reality["SpeedUp"]
			reality_suitable.Text = stepInfoModule[step].Reality["Suitable"]
			
			Awning_Desc.Text = stepInfoModule[step].Properties["Awning"]
			Weather_Desc.Text = stepInfoModule[step].Properties["Weather"]
			Fullness_Desc.Text = stepInfoModule[step].Properties["Fullness"]
			SoilMoisture_Desc.Text = stepInfoModule[step].Properties["SoilMoisture"]
			
			if dimension == "3D" then
				local clouds = workspace:WaitForChild("Terrain", WAITFORCHILD_TIMEOUT):WaitForChild("Clouds", WAITFORCHILD_TIMEOUT)
				local atmosphere = Lighting:WaitForChild("Atmosphere", WAITFORCHILD_TIMEOUT)
				
				local tween1 = TweenService:Create(atmosphere, TInfo_Environment, {Density = stepInfoModule[step].Environment["Atmosphere"].Density[2]})
				local tween2 = TweenService:Create(clouds, TInfo_Environment, {Density = stepInfoModule[step].Environment["Clouds"].Density[2], Cover = stepInfoModule[step].Environment["Clouds"].Cover[2]})
				
				tween1:Play()
				tween2:Play()
				
				while not simulationEndingCall and not (tween1.PlaybackState == Enum.PlaybackState.Completed and tween2.PlaybackState == Enum.PlaybackState.Completed) do
					task.wait()
				end
				
				if tween1.PlaybackState == Enum.PlaybackState.Playing or tween2.PlaybackState == Enum.PlaybackState.Playing then
					tween1:Cancel()
					tween2:Cancel()
					
					task.wait(2)
					
					atmosphere.Density = 0.3
					clouds.Cover = 0.7
					clouds.Density = 0.8
				elseif tween1.PlaybackState == Enum.PlaybackState.Completed or tween2.PlaybackState == Enum.PlaybackState.Completed then
					task.wait(2)

					atmosphere.Density = 0.3
					clouds.Cover = 0.7
					clouds.Density = 0.8
				end
			end
		end
	end)
	
	local AttributedObjects = {}

	local function renderConstantly(instance : BasePart | Texture)
		coroutine.wrap(function()
			local s, e = pcall(function()
				while (not _2DWaived or not simulationEndingCall) and (instance:GetAttribute("BasePartAssigned") or instance:GetAttribute("TextureAssigned")) do
					if instance:IsA("BasePart") then
						AttributedObjects[instance:GetAttribute("BasePartAssigned")].CFrame = instance.CFrame
						if simulationStarted then
							AttributedObjects[instance:GetAttribute("BasePartAssigned")].Transparency = instance.Transparency
						end
					elseif instance:IsA("Texture") then
						AttributedObjects[instance:GetAttribute("TextureAssigned")].Transparency = instance.Transparency :: number
						AttributedObjects[instance:GetAttribute("TextureAssigned")].OffsetStudsV = instance.OffsetStudsV :: number
						AttributedObjects[instance:GetAttribute("TextureAssigned")].OffsetStudsU = instance.OffsetStudsU :: number
					end
					
					task.wait()
				end
			end)
		end)()
	end

	for i, _2DObject in _2DModel:GetDescendants() do
		if _2DObject:IsA("BasePart") then
			AttributedObjects[_2DObject:GetAttribute("BasePartAssigned")] = _2DObject
		elseif _2DObject:IsA("Texture") then
			AttributedObjects[_2DObject:GetAttribute("TextureAssigned")] = _2DObject
		end
	end

	coroutine.wrap(function()
		local connection : RBXScriptConnection

		connection = _3DModel.DescendantAdded:Connect(function(descendant)
			local descendantClone = descendant:Clone()
			descendantClone.Parent = _2DModel

			if descendant:IsA("BasePart") then
				descendant:SetAttribute("BasePartAssigned", #AttributedObjects + 1)
				AttributedObjects[descendant:GetAttribute("BasePartAssigned")] = descendantClone :: BasePart & Texture
			elseif descendant:IsA("Texture") then
				descendant:SetAttribute("TextureAssigned", #AttributedObjects + 1)
				AttributedObjects[descendant:GetAttribute("TextureAssigned")] = descendantClone :: BasePart & Texture
			end

			renderConstantly(descendant :: BasePart | Texture)
		end)

		_3DModel.Destroying:Connect(function()
			table.clear(AttributedObjects)
		end)

		for i, _3DObject in _3DModel:GetDescendants() do
			renderConstantly(_3DObject)
		end

		while not simulationEndingCall do
			task.wait()
		end

		connection:Disconnect()
	end)()
	
	mouseMovementIn2D()
	
	viewportFrame.CurrentCamera = internalCamera
	
	coroutine.wrap(function()
		onSetup(conn1)
	end)()
end

function perform:Setup3D()
	mainFrame.BackgroundTransparency = 1
	viewportFrame.Visible = false
	
	for i, v in pairs(ProjectFolder:GetDescendants()) do
		if v:IsA("BasePart") then
			v:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
				v.LocalTransparencyModifier = 0
			end)
		end
	end
end

function perform:StartEntireSimulation(dimension : "3D" | "2D")
	simulationEndingCall = false
	
	local currentSession = perform.CurrentSimulationSession
	
	if currentSession.Active then
		return warn("There's already a simulation being performed.")
	end
	
	perform:Setup2D(dimension)
	
	if dimension == "3D" then
		lightingModule:SetGraphicsStatus(true)
		perform:Setup3D()
	else
		lightingModule:SetGraphicsStatus(false)
	end
end

function perform:EndEntireSimulation()
	if simulationEndingCall or simulationEnded then
		return warn("Already finishing the simulation.")
	end
	
	simulationEndingCall = true
	simulationEnded = false
	simulationStarted = false
	
	ContextActionService:UnbindAction("MouseMovement2D")

	simulateModel:Stop()
	simulateModel = nil :: never
	
	if simulateModelCloned then
		simulateModelCloned:Destroy()
		simulateModelCloned = nil :: never
	end

	perform.CurrentSimulationSession.Finished = os.clock()
	perform.CurrentSimulationSession.Active = false
	
	local timeElapsed = perform.CurrentSimulationSession.Finished - perform.CurrentSimulationSession.Started
	
	simulationEnded = true
	simulationStarted = false
end

function perform:ToMainMenu()	
	lightingModule:SetGraphicsStatus(true)

	local tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 0}) :: Tween
	tween_Blackout:Play()
	tween_Blackout.Completed:Connect(function()
		on2DReset()
		mainFrame.Visible = false

		internalCamera.CameraSubject = localPlayer.Character.Humanoid
		internalCamera.CameraType = Enum.CameraType.Scriptable
		internalCamera.CFrame = camStartCFrame

		BeginningScreenGUI.Enabled = true

		RefreshModel:RefreshModel("3D")
		RefreshModel:DeleteModel("2D")

		task.wait(BLACKOUT_WAITTIME)
		
		while not simulationEnded do
			task.wait()
		end
		
		tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 1}) :: Tween
		tween_Blackout:Play()
		tween_Blackout.Completed:Connect(function()
			simulationEnded = false
			simulationStarted = false
		end)
	end)
end

function perform:GetSimulationStep() : number?
	if perform.CurrentSimulationSession.Active then
		return simulateModel:GetSimulationStep()
	else
		return warn("There's no simulation running at the moment.")
	end
end

return perform
