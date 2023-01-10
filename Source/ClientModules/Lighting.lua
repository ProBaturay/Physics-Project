--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 12/11/2022 18:39
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local WAITFORCHILD_TIMEOUT = 100

local graphicsMetatable = {
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
}

local disabledEnvironmentalVisuals = setmetatable({}, graphicsMetatable) :: never
local disabledTerrainVisuals = setmetatable({}, graphicsMetatable) :: never

local Lighting : Lighting = game:GetService("Lighting")
local ReplicatedStorage : ReplicatedStorage = game:GetService("ReplicatedStorage")

local Terrain : Terrain = workspace:WaitForChild("Terrain", WAITFORCHILD_TIMEOUT) :: Terrain

local Atmosphere : Atmosphere = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local Sky : Sky = Lighting:WaitForChild("Sky") :: Sky
local Bloom : BloomEffect = Lighting:WaitForChild("Bloom") :: BloomEffect
local DepthOfField : DepthOfFieldEffect = Lighting:WaitForChild("DepthOfField") :: DepthOfFieldEffect
local SunRays : SunRaysEffect = Lighting:WaitForChild("SunRays") :: SunRaysEffect
local Clouds : Clouds = Terrain:WaitForChild("Clouds", WAITFORCHILD_TIMEOUT) :: Clouds

local lightingModule = {}

function lightingModule:SetGraphicsStatus(state : boolean)
	Sky.Parent = if state then Lighting :: never else ReplicatedStorage
	Atmosphere.Parent = if state then Lighting :: never else ReplicatedStorage

	Clouds.Enabled = state
	Bloom.Enabled = state
	DepthOfField.Enabled = state
	SunRays.Enabled = state

	Lighting.ShadowSoftness = if state then disabledEnvironmentalVisuals.ShadowSoftness else 0.2
	Lighting.ExposureCompensation = if state then disabledEnvironmentalVisuals.ExposureCompensation else 0
	Lighting.EnvironmentDiffuseScale = if state then disabledEnvironmentalVisuals.EnvironmentDiffuseScale else 0
	Lighting.EnvironmentSpecularScale = if state then disabledEnvironmentalVisuals.EnvironmentSpecularScale else 0
	Lighting.GlobalShadows = state

	Terrain.Transparency = if state then disabledTerrainVisuals["Transparency"] else 1
	Terrain.WaterReflectance = if state then disabledTerrainVisuals["WaterReflectance"] else 0
	Terrain.WaterTransparency = if state then disabledTerrainVisuals["WaterTransparency"] else 1
	Terrain.WaterWaveSize = if state then disabledTerrainVisuals["WaterWaveSize"]  else 0
	Terrain.WaterWaveSpeed = if state then disabledTerrainVisuals["WaterWaveSpeed"] else 0
end

function lightingModule:SaveGraphics()
	disabledEnvironmentalVisuals["ShadowSoftness"] = Lighting.ShadowSoftness
	disabledEnvironmentalVisuals["GlobalShadows"] = Lighting.GlobalShadows
	disabledEnvironmentalVisuals["EnvironmentDiffuseScale"] = Lighting.EnvironmentDiffuseScale
	disabledEnvironmentalVisuals["EnvironmentSpecularScale"] = Lighting.EnvironmentSpecularScale
	disabledEnvironmentalVisuals["ExposureCompensation"] = Lighting.ExposureCompensation
	
	disabledTerrainVisuals["Transparency"] = Terrain.Transparency
	disabledTerrainVisuals["WaterReflectance"] = Terrain.WaterReflectance
	disabledTerrainVisuals["WaterTransparency"] = Terrain.WaterTransparency
	disabledTerrainVisuals["WaterWaveSize"] = Terrain.WaterWaveSize
	disabledTerrainVisuals["WaterWaveSpeed"] = Terrain.WaterWaveSpeed
end

return lightingModule
