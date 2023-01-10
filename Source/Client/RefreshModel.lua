--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 14/12/2022 21:40
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local SECURITY_KEY = "  ᠎‍ 	​    	  ​ ‌    　 ⁠    ⁠     ​ ⁠⁠　           ‌ ‌​ ​  　  ‌	          　 ᠎​           ᠎   	 ​⁠ ‍   ​​  ‍  　     ⁠ ‍  	   ​   ​  ‍    ⁠   ᠎   ᠎    ᠎​  ‌​  ‍     ​  ᠎    ᠎     　      ‌	​​     ‍  ‌‌ 	 ⁠ 　    	  	᠎ ‌‍　 	 ⁠  ‌ ​    ‌　      ᠎‌‍  ‍   	  ᠎‌᠎　‍      ‌᠎ ​   ⁠       	    　 ‌ ‍ 		    　        ‍       ᠎  ‌　᠎  	  ⁠‌   ᠎ ​　   ⁠    	    ᠎  　   ‍           ᠎ ‍ ‌         　 ‍    　    ​     ‍   ​     ⁠ 	          ⁠ ​  ⁠		      ⁠ ‍ ᠎    ⁠	  　    ‌​ ⁠     	     ᠎‌ 　        ᠎ 	  ‌   	‌ ‍ ‍‌     　  ‌        ‍  ​   ​      ​‌    ‌    	  ⁠   ⁠᠎  ‍  ᠎    ᠎ 	᠎     	       ‍  	 ‍⁠   ‍ 　​ 	   ⁠᠎  ‌ ​   　 ​ ᠎​　 	 ⁠  ​  ‍  　 ​        　  ​  　⁠     　    ‌        　​        	⁠‌᠎  ‍     ‍ ‍᠎    ​      ‌   ‍  ‌‌	 ‌​  ​​᠎᠎᠎    ⁠⁠   　               ‍  ​ ​    ​ ‍     ᠎‌　   ‍ ⁠⁠   ‌ ⁠    	  ‍ 	  	​      ⁠       ⁠⁠ ​ 　  ‍          ​ 	        ‍	 ‍  ​  	   ​     	  　     	       	  ᠎         　	  	  	    ‌  ‍  ᠎᠎  ⁠	 	         ᠎⁠ ​  ⁠    ‍　  　              ​      	　 ‍⁠  ⁠ ⁠ "

local WAITFORCHILD_TIMEOUT = 100
local CONTENT_LOADING_ALLOWED_TIME = 5

local TInfo_MiddleText : TweenInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider : ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local internalCamera : Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer :: Player

local mainFrame = localPlayer:WaitForChild("PlayerGui", WAITFORCHILD_TIMEOUT):WaitForChild("2D", WAITFORCHILD_TIMEOUT):WaitForChild("Frame", WAITFORCHILD_TIMEOUT)
local viewportFrame : ViewportFrame = mainFrame:WaitForChild("ViewportFrame", WAITFORCHILD_TIMEOUT) :: ViewportFrame

local _2DModelDisplayArea = viewportFrame:WaitForChild("WorldModel", WAITFORCHILD_TIMEOUT)

local MiddleText = mainFrame:WaitForChild("MiddleText", WAITFORCHILD_TIMEOUT) :: TextLabel

local SimulationModels : Folder = ReplicatedStorage:WaitForChild("SimulationModels", WAITFORCHILD_TIMEOUT) :: Folder

local ProjectFolder = workspace:WaitForChild("Project", WAITFORCHILD_TIMEOUT)

local RemoteControls = ReplicatedStorage:WaitForChild("RemoteControls", WAITFORCHILD_TIMEOUT)
local TraceData : RemoteEvent = RemoteControls:WaitForChild("TraceData", WAITFORCHILD_TIMEOUT) :: RemoteEvent

local refresh = {}

function refresh:RefreshModel(simulationDimension : "2D" | "3D" | "Both", step : number?) : (boolean, Model, Model)
	MiddleText.TextTransparency = 0
	MiddleText.Visible = true
	MiddleText.Text = "Model yükleniyor. Lütfen bekleyin."

	refresh:DeleteModel("Both")
	
	local ProjectModel : Model = if step then SimulationModels:WaitForChild("S" .. step, WAITFORCHILD_TIMEOUT) :: Model else SimulationModels:WaitForChild("S1", WAITFORCHILD_TIMEOUT) :: Model
	local modelPivotCFrame = ProjectModel:GetPivot()

	local cloned2D, cloned3D

	if simulationDimension == "2D" then
		cloned2D = ProjectModel:Clone() -- We parent the model under world model if it's named 2D
		cloned2D:PivotTo(modelPivotCFrame)
	elseif simulationDimension == "3D" then
		cloned3D = ProjectModel:Clone() -- We parent the model under workspace if it's named 3D
		cloned3D:PivotTo(modelPivotCFrame)
		cloned3D.Parent = ProjectFolder
	elseif simulationDimension == "Both" then
		cloned2D = ProjectModel:Clone() -- We parent the model under world model if it's named 2D
		cloned2D:PivotTo(modelPivotCFrame)
		
		cloned3D = ProjectModel:Clone() -- We parent the model under workspace if it's named 3D
		cloned3D:PivotTo(modelPivotCFrame)
		cloned3D.Parent = ProjectFolder
	end
	
	local MiddleTextTween
	
	xpcall(function()
		coroutine.wrap(function()
			if simulationDimension == "2D" then
				MiddleTextTween = TweenService:Create(MiddleText, TInfo_MiddleText, {TextTransparency = 0})
				MiddleTextTween:Play()
			end
		end)()

		local thread = coroutine.create(function()
			ContentProvider:PreloadAsync(if simulationDimension == "2D" then cloned2D:GetDescendants() else ProjectModel:GetDescendants())
			
			return
		end)
		
		coroutine.resume(thread)
		
		local t = os.clock()
		
		repeat
			task.wait()
		until os.clock() - t >= CONTENT_LOADING_ALLOWED_TIME or coroutine.status(thread) == "dead"
		
		if coroutine.status(thread) ~= "dead" then
			TraceData:FireServer(SECURITY_KEY, "ContentLoadingExceededAllowedTime")
		else
			
		end

		coroutine.close(thread)	
	end, function(err)
		TraceData:FireServer(SECURITY_KEY, "ContentLoadingFailed")
	end)
	
	if MiddleTextTween then
		MiddleTextTween:Cancel()
	end
	
	local MiddleTextTween = TweenService:Create(MiddleText, TInfo_MiddleText, {TextTransparency = 1})
	MiddleTextTween:Play()
	MiddleTextTween.Completed:Wait()
	
	if cloned2D then
		cloned2D.Parent = _2DModelDisplayArea
	end
	
	return true, cloned2D, cloned3D
end

function refresh:DeleteModel(dimension : ("2D") | ("3D" | "Both")?)
	local _2Dmodel = _2DModelDisplayArea:FindFirstChildOfClass("Model") :: Model
	local _3Dmodel = ProjectFolder:FindFirstChildOfClass("Model")
	
	if _2Dmodel and (dimension == "2D" or dimension == "Both") then
		_2Dmodel:Destroy()
	end
	
	if _3Dmodel and (dimension == "3D" or dimension == "Both") then
		_3Dmodel:Destroy()
	end
end

return refresh
