--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 28/09/2022 13:07
    Yazar / Writer                     : @ProBaturay  
--]]

--!strict

local WAITFORCHILD_TIMEOUT = 100

local ContentLoadingModule
local PerformModule

coroutine.wrap(function()
	PerformModule = require(script:WaitForChild("Perform", WAITFORCHILD_TIMEOUT))
end)()

coroutine.wrap(function()
	ContentLoadingModule = require(script:WaitForChild("ContentLoading", WAITFORCHILD_TIMEOUT))
	ContentLoadingModule:StartContentLoading()
	
	local TopbarModule = require(script:WaitForChild("Topbar", WAITFORCHILD_TIMEOUT))
	TopbarModule:FPS()
	TopbarModule:Ping()
end)()

local BLACKOUT_WAITTIME = 0.7

local SECURITY_KEY = "  ᠎‍ 	​    	  ​ ‌    　 ⁠    ⁠     ​ ⁠⁠　           ‌ ‌​ ​  　  ‌	          　 ᠎​           ᠎   	 ​⁠ ‍   ​​  ‍  　     ⁠ ‍  	   ​   ​  ‍    ⁠   ᠎   ᠎    ᠎​  ‌​  ‍     ​  ᠎    ᠎     　      ‌	​​     ‍  ‌‌ 	 ⁠ 　    	  	᠎ ‌‍　 	 ⁠  ‌ ​    ‌　      ᠎‌‍  ‍   	  ᠎‌᠎　‍      ‌᠎ ​   ⁠       	    　 ‌ ‍ 		    　        ‍       ᠎  ‌　᠎  	  ⁠‌   ᠎ ​　   ⁠    	    ᠎  　   ‍           ᠎ ‍ ‌         　 ‍    　    ​     ‍   ​     ⁠ 	          ⁠ ​  ⁠		      ⁠ ‍ ᠎    ⁠	  　    ‌​ ⁠     	     ᠎‌ 　        ᠎ 	  ‌   	‌ ‍ ‍‌     　  ‌        ‍  ​   ​      ​‌    ‌    	  ⁠   ⁠᠎  ‍  ᠎    ᠎ 	᠎     	       ‍  	 ‍⁠   ‍ 　​ 	   ⁠᠎  ‌ ​   　 ​ ᠎​　 	 ⁠  ​  ‍  　 ​        　  ​  　⁠     　    ‌        　​        	⁠‌᠎  ‍     ‍ ‍᠎    ​      ‌   ‍  ‌‌	 ‌​  ​​᠎᠎᠎    ⁠⁠   　               ‍  ​ ​    ​ ‍     ᠎‌　   ‍ ⁠⁠   ‌ ⁠    	  ‍ 	  	​      ⁠       ⁠⁠ ​ 　  ‍          ​ 	        ‍	 ‍  ​  	   ​     	  　     	       	  ᠎         　	  	  	    ‌  ‍  ᠎᠎  ⁠	 	         ᠎⁠ ​  ⁠    ‍　  　              ​      	　 ‍⁠  ⁠ ⁠ "
local devConsoleMessage = "👋 Hoş geldiniz! Şu anda bu simülasyonun yürütüldüğü sunucunun geliştirici konsolu bölümünü açmış durumundasınız.\n👁️‍🗨️ Aşağıda birtakım yazılar görme ihtimaliniz olursa, oyunun komut dosyalarının hata ayıklamaya dair kayıtlar olduğunu hatırlatalım.\n🔘 Bu konsolu kapatmak için F9 kısayol tuşuna basabilirsiniz ya da sağ üstteki çarpı simgesine tıklayabilirsiniz.\n🕹️ İyi eğlenceler!"
local printDevConsoleMessageInStudio = true
local info_2D = [[2 boyutlu düzlemde inceleme yapılırken bütün görsel efektler devre dışı bırakılmış olur. Konu, yüzeysel bir şekilde ele alınır. <font color="rgb(100, 150, 180)">Düşük performanslı aygıtlar için tavsiye edilir.</font> <font color="rgb(200, 40, 40)">Proje modeli düşük kaliteli olarak gösterilir.</font>]]
local info_3DSimulation = [[Işıklandırma, görsel efektler, grafik tasarım özellikleri 3 boyutlu çalışma alanında dâhil edilir. <font color="rgb(100, 150, 180)">Performansı iyi sayılan aygıtlar için uygundur ve tavsiye edilir.</font>]]

local TInfo_Fade : TweenInfo = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local tween_Button2D : Tween, tween_Button3D : Tween, tween_Info : Tween, tween_Blackout : Tween, tween_BackToMainMenu : Tween, tween_StartSimulation : Tween = nil, nil, nil, nil, nil, nil
local tween_Narrower : Tween = nil

-- Camera CFrames

local camStartCFrame = CFrame.new(-6.83833981, 66.4214401, -135.935471, 0.709502637, 0.0701519921, -0.701202393, 3.7252903e-09, 0.995032787, 0.0995483398, 0.704702795, -0.0706298128, 0.705978394)
local infoCFrame = CFrame.new(152.592819, 51.2373772, -64.1600494, 0.937304497, 0.0218790341, 0.347824216, 1.86264515e-09, 0.998027563, -0.0627784953, -0.348511636, 0.0588425659, 0.93545568)
local cframe_simulationLocationSubject = CFrame.new(142.75914, 88.1704483, -140.677979, 0.999783039, -0.00837374013, 0.0190735292, -4.65661287e-10, 0.915644228, 0.401989907, -0.0208307225, -0.401902705, 0.915445507)

local Players : Players = game:GetService("Players")
local StarterGui : StarterGui = game:GetService("StarterGui")
local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService : TweenService = game:GetService("TweenService")
local RunService : RunService = game:GetService("RunService")
local Lighting : Lighting = game:GetService("Lighting")

local player : Player = Players.LocalPlayer :: Player

coroutine.wrap(function()
	local Values = ReplicatedStorage:WaitForChild("Values", WAITFORCHILD_TIMEOUT)
	local ProjectName : StringValue = Values:WaitForChild("ProjectName", WAITFORCHILD_TIMEOUT) :: StringValue

	player:WaitForChild("PlayerGui", WAITFORCHILD_TIMEOUT):WaitForChild("Beginning", WAITFORCHILD_TIMEOUT):WaitForChild("MainInfo", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("ProjectName", WAITFORCHILD_TIMEOUT).Name = ProjectName.Value
end)()

local RemoteControls = ReplicatedStorage:WaitForChild("RemoteControls", WAITFORCHILD_TIMEOUT)
local TraceData : RemoteEvent = RemoteControls:WaitForChild("TraceData", WAITFORCHILD_TIMEOUT) :: RemoteEvent

local SimulationModels = ReplicatedStorage:WaitForChild("SimulationModels") :: Folder

local Hitboxes : Folder = workspace:WaitForChild("Hitboxes", WAITFORCHILD_TIMEOUT) :: Folder
local Objects : Folder = workspace:WaitForChild("Objects", WAITFORCHILD_TIMEOUT) :: Folder
local Terrain : Terrain = workspace:WaitForChild("Terrain", WAITFORCHILD_TIMEOUT) :: Terrain

local PlayerGui : PlayerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local PlayerScripts = player:WaitForChild("PlayerScripts", WAITFORCHILD_TIMEOUT)
local PlayerModule = PlayerScripts:WaitForChild("PlayerModule", WAITFORCHILD_TIMEOUT)

local ControlModule = require(PlayerModule:WaitForChild("ControlModule", WAITFORCHILD_TIMEOUT)) :: never

local lightingModule = require(ReplicatedStorage:WaitForChild("Modules", WAITFORCHILD_TIMEOUT):WaitForChild("Lighting", WAITFORCHILD_TIMEOUT))

local BeginningScreenGUI : ScreenGui = PlayerGui:WaitForChild("Beginning", WAITFORCHILD_TIMEOUT) :: ScreenGui
local BlackoutScreenGUI : ScreenGui = PlayerGui:WaitForChild("Blackout", WAITFORCHILD_TIMEOUT) :: ScreenGui
local _2DScreenGUI : ScreenGui = PlayerGui:WaitForChild("2D", WAITFORCHILD_TIMEOUT) :: ScreenGui
local SimulationInfoScreenGUI : ScreenGui = PlayerGui:WaitForChild("SimulationInfo", WAITFORCHILD_TIMEOUT) :: ScreenGui

local _2DFrame = _2DScreenGUI:WaitForChild("Frame", WAITFORCHILD_TIMEOUT) :: Frame
local _2DViewportFrame : ViewportFrame = _2DFrame:WaitForChild("ViewportFrame", WAITFORCHILD_TIMEOUT) :: ViewportFrame

local BlackoutFrame : Frame = BlackoutScreenGUI:WaitForChild("Blackout", WAITFORCHILD_TIMEOUT) :: Frame
local Beginning_MainInfo : Frame = BeginningScreenGUI:WaitForChild("MainInfo", WAITFORCHILD_TIMEOUT) :: Frame
local Beginning_SimulationOptions : Frame = BeginningScreenGUI:WaitForChild("SimulationOptions", WAITFORCHILD_TIMEOUT) :: Frame
local DetailedInfo : Frame = BeginningScreenGUI:WaitForChild("DetailedInfo", WAITFORCHILD_TIMEOUT) :: Frame

local BSO_Options = Beginning_SimulationOptions:WaitForChild("Options", WAITFORCHILD_TIMEOUT)
local BSO_Info : CanvasGroup = Beginning_SimulationOptions:WaitForChild("Info", WAITFORCHILD_TIMEOUT) :: CanvasGroup
local Info_Text : TextLabel = BSO_Info:WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Text", WAITFORCHILD_TIMEOUT) :: TextLabel

local SO_Options_Frame = BSO_Options:WaitForChild("Frame", WAITFORCHILD_TIMEOUT)
local SO_Button2D : TextButton = SO_Options_Frame:WaitForChild("2D", WAITFORCHILD_TIMEOUT):WaitForChild("Button", WAITFORCHILD_TIMEOUT) :: TextButton
local SO_Button3D : TextButton = SO_Options_Frame:WaitForChild("3D", WAITFORCHILD_TIMEOUT):WaitForChild("Button", WAITFORCHILD_TIMEOUT) :: TextButton

local SI_BackToMainMenu : Frame = SimulationInfoScreenGUI:WaitForChild("BackToMainMenu", WAITFORCHILD_TIMEOUT) :: Frame
local SI_Info : Frame = SimulationInfoScreenGUI:WaitForChild("Info", WAITFORCHILD_TIMEOUT) :: Frame
local SI_Start : Frame = SimulationInfoScreenGUI:WaitForChild("Start", WAITFORCHILD_TIMEOUT) :: Frame

local SI_BackToMainMenuButton : TextButton = SI_BackToMainMenu:WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Button", WAITFORCHILD_TIMEOUT) :: TextButton
local SI_StartButton : TextButton = SI_Start:WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Button", WAITFORCHILD_TIMEOUT) :: TextButton
local SI_InfoText : TextLabel = SI_Info:WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT):WaitForChild("TextLabel", WAITFORCHILD_TIMEOUT) :: TextLabel

local ProjectFolder : Folder = workspace:WaitForChild("Project", WAITFORCHILD_TIMEOUT)

-- Objects

local houseDoor : Part = Objects:WaitForChild("Door", WAITFORCHILD_TIMEOUT) :: Part
local doorHinge : HingeConstraint = houseDoor:WaitForChild("HingeConstraint", WAITFORCHILD_TIMEOUT) :: HingeConstraint

-- Hitboxes

local HouseDoorHitbox = Hitboxes:WaitForChild("HouseDoor", WAITFORCHILD_TIMEOUT) :: Part
local houseDoorHitboxCooldown = 0

local character : Model = player.Character :: Model
local internalCamera : Camera = workspace.CurrentCamera

if not character then
	coroutine.wrap(function()
		character = player.Character or player.CharacterAdded:Wait()
	end)()
end

local function disableCoreGui() : ()
	local success : boolean, err : string, failureCounter : number = false, "", -1

	coroutine.wrap(function()
		repeat
			failureCounter += 1

			success, err = pcall(function()
				StarterGui:SetCore("ResetButtonCallback", false)
			end)

			task.wait()
		until success

		TraceData:FireServer(SECURITY_KEY, "ResetButtonCallbackUnprompted")
	end)()

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end

local function changeCharacterInvisibility(makeInvisible)
	if not character then
		character = player.Character or player.CharacterAdded:Wait()
	end

	local function doInvisible(charPart : Instance)
		if charPart:IsA("BasePart") then
			charPart.CanCollide = if makeInvisible then false else true
			charPart.Transparency = if makeInvisible then 1 else 0
		elseif charPart:IsA("Decal") then
			charPart.Transparency = if makeInvisible then 1 else 0
		end
	end

	coroutine.wrap(function()
		for i : number, charPart : Instance in character:GetDescendants() do
			doInvisible(charPart)
		end

		character.DescendantAdded:Connect(function(charPart : Instance)
			doInvisible(charPart)
		end)
	end)()
end

local function outputDevConsole()
	print(devConsoleMessage)
end

local function setCameraType()
	local changed = false

	character.DescendantAdded:Connect(function(humanoid)
		if humanoid:IsA("Humanoid") then
			internalCamera.CameraType = Enum.CameraType.Scriptable
			changed = true
		end
	end)

	repeat 
		task.wait()
	until changed
end

local function doesHumanoidExist()
	if not character:FindFirstChild("Humanoid") then
		setCameraType()
	else
		internalCamera.CameraType = Enum.CameraType.Scriptable
	end
end

----------------------------------

BeginningScreenGUI.Enabled = true
_2DFrame.Visible = false

coroutine.wrap(function()
	lightingModule:SaveGraphics()
end)()

coroutine.wrap(function()
	--makeCharacterModelInvisible()
	disableCoreGui()

	if RunService:IsServer() then
		outputDevConsole()
	elseif printDevConsoleMessageInStudio then
		outputDevConsole()
	end
end)()

coroutine.wrap(function()
	local overlapParams = OverlapParams.new()

	while true do
		local parts = workspace:GetPartsInPart(HouseDoorHitbox, overlapParams)
		local found = false

		for i, part in parts do
			if not found and Players:GetPlayerFromCharacter(part:FindFirstAncestor(player.Name) :: Model) == player then
				houseDoorHitboxCooldown = os.clock()
				doorHinge.TargetAngle = -70
				found = true
			end
		end

		task.wait(0.2)
	end
end)()

coroutine.wrap(function()
	while true do	
		while houseDoorHitboxCooldown do
			if os.clock() - houseDoorHitboxCooldown >= 0.01 then
				doorHinge.TargetAngle = 0

				break
			else
				task.wait()
			end 
		end

		task.wait(0.2)
	end
end)()

if character then
	doesHumanoidExist()
else
	repeat 
		task.wait()	
	until character

	doesHumanoidExist()
end

ControlModule:Disable()

internalCamera.CameraType = Enum.CameraType.Scriptable
internalCamera.CFrame = camStartCFrame

local crossCheckTable = {}

local controversy : boolean = false
local simulationDimensionChosen : string = "2D"

local function checkControversy(value : string?) : boolean
	controversy = false

	if not value then
		return false
	end

	local oneBeforeLast = crossCheckTable[#crossCheckTable - 1]

	if (value == "Button2DLeave" and oneBeforeLast == "Button3DEnter") or (value == "Button3DLeave" and oneBeforeLast == "Button2DEnter") then
		TraceData:FireServer(SECURITY_KEY, "MouseLeaveAndMouseEnterCoincide")		
		controversy = true

		if tween_Info and tween_Info:IsA("Tween") then
			tween_Info:Cancel()
		end

		tween_Info = TweenService:Create(BSO_Info, TInfo_Fade, {GroupTransparency = 0})
		tween_Info:Play()

		tween_Info.Completed:Connect(function(playbackState)	
			if playbackState == Enum.PlaybackState.Completed then
				tween_Info = nil :: never
			end
		end)

		if value == "Button2DLeave" then
			Info_Text.Text = "Projenin ortam koşullarına uyumlu olması gösterilir."
		else
			Info_Text.Text = "Sadece simülasyon gösterilir."
		end
	end 

	return controversy
end

local function tweenButtons(button : string, isFadingOut : boolean, event : string?)
	local ButtonTweens = {
		["2D"] = tween_Button2D,
		["3D"] = tween_Button3D,
		["BackToMainMenu"] = tween_BackToMainMenu,
		["StartSimulation"] = tween_StartSimulation
	}

	local buttons = {
		["2D"] = SO_Button2D,
		["3D"] = SO_Button3D,
		["BackToMainMenu"] = SI_BackToMainMenuButton,
		["StartSimulation"] = SI_StartButton
	}

	if isFadingOut or tween_Blackout == nil then
		checkControversy(event)

		local targetButtonTween : Tween = ButtonTweens[button]
		local firstValue : number, secondValue : number

		if isFadingOut then
			firstValue, secondValue = 1, 1
		else
			firstValue, secondValue = 0, 0.5
		end

		if targetButtonTween and targetButtonTween:IsA("Tween") then
			targetButtonTween:Cancel()
		end

		if not controversy then
			if tween_Info and tween_Info:IsA("Tween") then
				tween_Info:Cancel()
			end

			coroutine.wrap(function()
				tween_Info = TweenService:Create(BSO_Info, TInfo_Fade, {GroupTransparency = firstValue})
				tween_Info:Play()
				tween_Info.Completed:Connect(function(playbackState)
					if playbackState == Enum.PlaybackState.Completed then
						tween_Info = nil :: never
					end
				end)
			end)()
		end

		targetButtonTween = TweenService:Create(buttons[button], TInfo_Fade, {BackgroundTransparency = secondValue})
		targetButtonTween:Play()
		targetButtonTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				targetButtonTween = nil :: never
			end
		end)
	end
end

local function onButton2DEnter()
	table.insert(crossCheckTable, "Button2DEnter")
	Info_Text.Text = "Sadece simülasyon gösterilir."

	tweenButtons("2D", false, "Button2DEnter")
end

local function onButton2DLeave()
	table.insert(crossCheckTable, "Button2DLeave")

	tweenButtons("2D", true, "Button2DLeave")
end

local function onButton3DEnter()
	Info_Text.Text = "Projenin ortam koşullarına uyumlu olması gösterilir."
	table.insert(crossCheckTable, "Button3DEnter")

	tweenButtons("3D", false, "Button3DEnter")
end

local function onButton3DLeave()
	table.insert(crossCheckTable, "Button3DLeave")
	
	tweenButtons("3D", true, "Button3DLeave")
end

local function onBackToMainMenuInteraction(state : boolean)
	tweenButtons("BackToMainMenu", state)
end

local function onStartInteraction(state : boolean)
	tweenButtons("StartSimulation", state)
end

SO_Button2D.MouseEnter:Connect(function()
	onButton2DEnter()
end)

SO_Button2D.MouseLeave:Connect(function()
	onButton2DLeave()
end)

SO_Button3D.MouseEnter:Connect(function()
	onButton3DEnter()
end)

SO_Button3D.MouseLeave:Connect(function()
	onButton3DLeave()
end)

local function transititon_MainToInfo()
	onButton2DLeave()
	onButton3DLeave()
	
	SI_InfoText.Text = if simulationDimensionChosen == "2D" then info_2D else info_3DSimulation

	if tween_Blackout == nil and ContentLoadingModule.contentLoadingFinished then -- Typechecking engine halts if the condition is "not tween_Blackout"
		tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 0}) :: Tween
		tween_Blackout:Play()
		tween_Blackout.Completed:Connect(function()
			BeginningScreenGUI.Enabled = false
			SimulationInfoScreenGUI.Enabled = true

			internalCamera.CFrame = infoCFrame

			task.wait(BLACKOUT_WAITTIME)

			tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 1}) :: Tween
			tween_Blackout:Play()

			tween_Blackout.Completed:Connect(function()
				tween_Blackout = nil :: never
			end)
		end)
	end
end

local function transition_InfoToMain()
	onBackToMainMenuInteraction(true)
	onStartInteraction(true)
	
	simulationDimensionChosen = "nil"

	if tween_Blackout == nil then -- Typechecking engine halts if the condition is "not ttween_Blackout"
		tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 0}) :: Tween
		tween_Blackout:Play()
		tween_Blackout.Completed:Connect(function()
			BeginningScreenGUI.Enabled = true
			SimulationInfoScreenGUI.Enabled = false

			internalCamera.CFrame = camStartCFrame

			task.wait(BLACKOUT_WAITTIME)

			tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 1}) :: Tween
			tween_Blackout:Play()

			tween_Blackout.Completed:Connect(function()
				tween_Blackout = nil :: never
			end)
		end)
	end
end

SI_BackToMainMenuButton.MouseEnter:Connect(function()
	-- No need to check for the controversy; assuming FPS is quite sufficient to fire the events accurately

	onBackToMainMenuInteraction(false)
end)

SI_BackToMainMenuButton.MouseLeave:Connect(function()
	-- No need to check for the controversy; assuming FPS is quite sufficient to fire the events accurately

	onBackToMainMenuInteraction(true)
end)

SI_StartButton.MouseEnter:Connect(function()
	-- No need to check for the controversy; assuming FPS is quite sufficient to fire the events accurately

	onStartInteraction(false)
end)

SI_StartButton.MouseLeave:Connect(function()
	-- No need to check for the controversy; assuming FPS is quite sufficient to fire the events accurately

	onStartInteraction(true)
end)

SO_Button2D.Activated:Connect(function()
	simulationDimensionChosen = "2D"

	transititon_MainToInfo()
end)

SO_Button3D.Activated:Connect(function()
	simulationDimensionChosen = "3D"

	transititon_MainToInfo()
end)

SI_BackToMainMenuButton.Activated:Connect(function()
	transition_InfoToMain()
end)

local function start()
	coroutine.wrap(function()
		changeCharacterInvisibility(true)
	end)()

	if tween_Blackout == nil then
		tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 0})
		tween_Blackout:Play()
		tween_Blackout.Completed:Connect(function()			
			SimulationInfoScreenGUI.Enabled = false
		end)

		task.wait(BLACKOUT_WAITTIME)
		
		_2DScreenGUI.Enabled = true
		_2DFrame.Visible = true

		--InvisicamModule:SetMode(1)
		internalCamera.CFrame = cframe_simulationLocationSubject
		_2DViewportFrame.CurrentCamera = internalCamera
		
		player.CameraMinZoomDistance = 1
		
		task.delay(2, function()
			tween_Blackout = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 1})
			tween_Blackout:Play()
			tween_Blackout.Completed:Connect(function()
				tween_Blackout = nil :: never
			end)
		end)
		
		PerformModule:StartEntireSimulation(simulationDimensionChosen :: "2D" | "3D")
	end
end

SI_StartButton.Activated:Connect(function()
	onButton2DLeave()
	onButton3DLeave()

	onBackToMainMenuInteraction(true)
	onStartInteraction(true)

	start()
end)
