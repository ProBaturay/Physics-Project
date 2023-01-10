--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 8/12/2022 21:40
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local SECURITY_KEY = "  ᠎‍ 	​    	  ​ ‌    　 ⁠    ⁠     ​ ⁠⁠　           ‌ ‌​ ​  　  ‌	          　 ᠎​           ᠎   	 ​⁠ ‍   ​​  ‍  　     ⁠ ‍  	   ​   ​  ‍    ⁠   ᠎   ᠎    ᠎​  ‌​  ‍     ​  ᠎    ᠎     　      ‌	​​     ‍  ‌‌ 	 ⁠ 　    	  	᠎ ‌‍　 	 ⁠  ‌ ​    ‌　      ᠎‌‍  ‍   	  ᠎‌᠎　‍      ‌᠎ ​   ⁠       	    　 ‌ ‍ 		    　        ‍       ᠎  ‌　᠎  	  ⁠‌   ᠎ ​　   ⁠    	    ᠎  　   ‍           ᠎ ‍ ‌         　 ‍    　    ​     ‍   ​     ⁠ 	          ⁠ ​  ⁠		      ⁠ ‍ ᠎    ⁠	  　    ‌​ ⁠     	     ᠎‌ 　        ᠎ 	  ‌   	‌ ‍ ‍‌     　  ‌        ‍  ​   ​      ​‌    ‌    	  ⁠   ⁠᠎  ‍  ᠎    ᠎ 	᠎     	       ‍  	 ‍⁠   ‍ 　​ 	   ⁠᠎  ‌ ​   　 ​ ᠎​　 	 ⁠  ​  ‍  　 ​        　  ​  　⁠     　    ‌        　​        	⁠‌᠎  ‍     ‍ ‍᠎    ​      ‌   ‍  ‌‌	 ‌​  ​​᠎᠎᠎    ⁠⁠   　               ‍  ​ ​    ​ ‍     ᠎‌　   ‍ ⁠⁠   ‌ ⁠    	  ‍ 	  	​      ⁠       ⁠⁠ ​ 　  ‍          ​ 	        ‍	 ‍  ​  	   ​     	  　     	       	  ᠎         　	  	  	    ‌  ‍  ᠎᠎  ⁠	 	         ᠎⁠ ​  ⁠    ‍　  　              ​      	　 ‍⁠  ⁠ ⁠ "

local useCoroutine = false

local WAITFORCHILD_TIMEOUT = 100

local MAX_LOADING_TIME = 3
local MAX_DETECTED_WAIT_TIME = 3

local THROTTLING = 0
local LOWEST_THROTTLING_TO_APPLY = 0.00

local TInfo_Progress = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out,
	0, 
	false,
	0
)

local TInfo_TransparentProgress = TweenInfo.new(
	2,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local TInfo_Fade : TweenInfo = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TInfo_Start : TweenInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Bounce,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TInfo_ImageCycle : TweenInfo = TweenInfo.new(
	4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local TInfo_ImageCycle2 : TweenInfo = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local cFrame = CFrame.new(170.672882, 84.8195114, -140.995117, 0.910811901, -0.237433538, 0.337708682, 1.4901163e-08, 0.818049669, 0.575147688, -0.412821829, -0.523851335, 0.745089233)

local placesToSearch = {
	workspace,
	game:GetService("StarterPlayer"),
	game:GetService("StarterGui"),
	game:GetService("ReplicatedStorage"),
}

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local PlayerGui = script.Parent.Parent.Parent:WaitForChild("PlayerGui", WAITFORCHILD_TIMEOUT)
local BlackoutFrame = PlayerGui:WaitForChild("Blackout", WAITFORCHILD_TIMEOUT):WaitForChild("Blackout", WAITFORCHILD_TIMEOUT)

coroutine.wrap(function()
	BlackoutFrame.Visible = true
end)()

local StartFolder = BlackoutFrame:WaitForChild("Start", WAITFORCHILD_TIMEOUT)

local CompetitionName = StartFolder:WaitForChild("CompetitionName", WAITFORCHILD_TIMEOUT)
local blackoutProgress = StartFolder:WaitForChild("Frame", WAITFORCHILD_TIMEOUT)
local backgroundImage = StartFolder:WaitForChild("ImageLabel", WAITFORCHILD_TIMEOUT)
local viewportFrame = StartFolder:WaitForChild("ViewportFrame", WAITFORCHILD_TIMEOUT)

local infoText = blackoutProgress:WaitForChild("TextLabel", WAITFORCHILD_TIMEOUT)
local MainCanvasGroup = blackoutProgress:WaitForChild("CanvasGroup", WAITFORCHILD_TIMEOUT)
local ProgressFrame = MainCanvasGroup:WaitForChild("ProgressFrame", WAITFORCHILD_TIMEOUT)
local transparentProgressFrame = MainCanvasGroup:WaitForChild("Frame", WAITFORCHILD_TIMEOUT)
local ProgressLabel = MainCanvasGroup:WaitForChild("ProgressLabel", WAITFORCHILD_TIMEOUT)

local RemoteControls = ReplicatedStorage:WaitForChild("RemoteControls", WAITFORCHILD_TIMEOUT)
local TraceData : RemoteEvent = RemoteControls:WaitForChild("TraceData", WAITFORCHILD_TIMEOUT) :: RemoteEvent

local Cameras = workspace:WaitForChild("Cameras", WAITFORCHILD_TIMEOUT)
local newCam = Instance.new("Camera")
newCam.CFrame = cFrame
newCam.Parent = Cameras
viewportFrame.CurrentCamera = newCam

local SampleProjectModel = ReplicatedStorage:WaitForChild("SimulationModels", WAITFORCHILD_TIMEOUT):WaitForChild("S1", WAITFORCHILD_TIMEOUT)
local clone = SampleProjectModel:Clone()
clone.Parent = viewportFrame

local contentLoading = {
	contentLoadingFinished = false,
	processFinished = false
}

local imageIds = {
	"11781481670",
	"11788351527"
}

local selectedImages = {}

local function imageCycle()
	coroutine.wrap(function()
		while not contentLoading.contentLoadingFinished do
			backgroundImage.Size = UDim2.new(1.2, 0, 1.2, 0)
			
			local randomImage = imageIds[math.random(1, table.getn(imageIds))]
			table.insert(selectedImages, randomImage)
			table.remove(imageIds, table.find(imageIds, randomImage))
			
			backgroundImage.Image = "rbxassetid://" .. randomImage
			
			while not backgroundImage.IsLoaded do
				task.wait()
			end
			
			local tween2_1 = TweenService:Create(backgroundImage, TInfo_ImageCycle, {Size = UDim2.new(1, 0, 1, 0)})
			local tween2_2 = TweenService:Create(backgroundImage, TInfo_ImageCycle2, {ImageTransparency = 1})
			
			tween2_1:Play()
			TweenService:Create(backgroundImage, TInfo_ImageCycle2, {ImageTransparency = 0}):Play()
			
			task.wait(2.5)
			
			tween2_2:Play()
			
			if tween2_1.PlaybackState == Enum.PlaybackState.Playing then
				tween2_1.Completed:Wait()
			end
			
			if table.getn(imageIds) == 0 then
				imageIds = table.clone(selectedImages)
				table.clear(selectedImages)
			end
		end
	end)()
end

local function detectObjects()
	local timeElapsedSinceLastObject = 0
	local numberOfObjectsFound = 0
	local objectsFound = {}

	timeElapsedSinceLastObject = os.clock()

	coroutine.wrap(function()
		for i, v in placesToSearch do
			for i, object in v:GetDescendants() do
				table.insert(objectsFound, object)
				numberOfObjectsFound += 1
			end
			
			v.DescendantAdded:Connect(function(object)
				table.insert(objectsFound, object)
				timeElapsedSinceLastObject = os.clock()
			end)
		end
	end)()
	
	while timeElapsedSinceLastObject + 3 < os.clock() do
		task.wait()
	end
	
	return objectsFound
end

function contentLoading:StartContentLoading()
	CompetitionName.Position = UDim2.new(0.5, 0, 0, 0)
	blackoutProgress.Position = UDim2.new(0.5, 0, 1, 0)
	
	if BlackoutFrame.BackgroundTransparency ~= 0 then
		BlackoutFrame.BackgroundTransparency = 0 
	end
	
	imageCycle()
	
	local loadedObjects = 0
	local totalObjects = detectObjects()
	
	local transparentTween : Tween
	
	coroutine.wrap(function()
		while not contentLoading.processFinished do
			transparentTween = TweenService:Create(transparentProgressFrame, TInfo_TransparentProgress, {Position = UDim2.new(1.05, 0, 0.5, 0)})
			transparentTween:Play()
			transparentTween.Completed:Wait()
			
			transparentProgressFrame.Position = UDim2.new(-0.12, 0, 0.5, 0)
		end
	end)()
	
	local competitionTween = TweenService:Create(CompetitionName, TInfo_Start, {Position = UDim2.new(0.5, 0, 0.25, 0)})
	local progressTween = TweenService:Create(blackoutProgress, TInfo_Start, {Position = UDim2.new(0.5, 0, 0.7, 0)})
	
	competitionTween:Play()
	progressTween:Play()
	
	local lastTween : Tween
	
	local function preload(object : Instance)
		--TODO: reminder: the situation below shows the differences between commented and the executed area

		local s, e 
			
		s,e = pcall(function()
			local lastTime = os.clock()

			ContentProvider:PreloadAsync({object})

			task.defer(function()
				ProgressLabel.Text = "%" .. string.gsub(string.gsub(string.format("%.1f", (100 * loadedObjects) / table.getn(totalObjects)), "%.", ",", 1), ",0+", "", 1)

				if lastTween then
					lastTween:Cancel()
				end

				local val = loadedObjects / table.getn(totalObjects)
				lastTween = TweenService:Create(ProgressFrame, TInfo_Progress, {Size = UDim2.new(if val < 0.001 then 0.001 else val * (102 / 100), 0, 1, 0)})
				lastTween:Play()
			end)
			
			coroutine.wrap(function()
				while not s and os.clock() - lastTime < MAX_LOADING_TIME do
					task.wait(1)
				end
			end)()
		end)

		loadedObjects += 1

		if s == false then
			TraceData:FireServer(SECURITY_KEY, "ContentLoadingFailed")
		elseif not s or not e then
			TraceData:FireServer(SECURITY_KEY, "ContentLoadingExceededAllowedTime")
		end

		--xpcall(function()
		--	ContentProvider:PreloadAsync(object)
		--end, function(e)
		--	TraceData:FireServer(SECURITY_KEY, "ContentLoadingFailed")
		--end)
		--end)()
	end

	progressTween.Completed:Wait()
	
	for i, object in totalObjects do		
		if THROTTLING > LOWEST_THROTTLING_TO_APPLY then
			task.wait(THROTTLING)
		end
		
		if useCoroutine then
			coroutine.wrap(function()
				preload(object)
			end)()
		else
			preload(object)
		end
	end
	
	while loadedObjects < table.getn(totalObjects) do
		task.wait()
	end
	
	infoText.Text = "Simülasyon hazır!"
	contentLoading.processFinished = true
	
	while not transparentTween do
		task.wait()
	end
	
	CompetitionName.Visible = false
	blackoutProgress.Visible = false
	backgroundImage.Visible = false
	viewportFrame.Visible = false
	
	local lastTween = TweenService:Create(BlackoutFrame, TInfo_Fade, {BackgroundTransparency = 1})
	lastTween:Play()
	lastTween.Completed:Once(function()
		contentLoading.contentLoadingFinished = true
	end)
	
	return contentLoading.contentLoadingFinished
end

return contentLoading
