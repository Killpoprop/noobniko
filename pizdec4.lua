local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Загрузка модели из вставки
local success, model = pcall(function()
	return game:GetObjects("rbxassetid://104923566455281")[1]
end)

if not success or not model then
	warn("Не удалось загрузить модель:", model)
	return
end

-- Удаляем Humanoid из модели (если есть)
local existingHumanoid = model:FindFirstChildOfClass("Humanoid")
if existingHumanoid then existingHumanoid:Destroy() end

model.Name = "CustomVisualRig"

-- Найти главную часть модели вручную
local candidatePrimaryPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
if not candidatePrimaryPart then
	warn("У модели нет подходящей главной части (PrimaryPart)")
	return
end
model.PrimaryPart = candidatePrimaryPart

-- Отключить физику модели
for _, part in ipairs(model:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
	end
end

-- Скрываем оригинальные части персонажа кроме тела
local bodyParts = {
	["Head"] = true,
	["Torso"] = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
}

for _, child in ipairs(character:GetChildren()) do
	if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Accessory") then
		if not bodyParts[child.Name] then
			if child:IsA("Accessory") then
				local handle = child:FindFirstChild("Handle")
				if handle then
					handle.Transparency = 1
					for _, dec in ipairs(handle:GetDescendants()) do
						if dec:IsA("Decal") or dec:IsA("Texture") then
							dec.Transparency = 1
						end
					end
				end
			else
				child.Transparency = 1
				if child:IsA("MeshPart") then
					child.TextureID = ""
				end
				for _, dec in ipairs(child:GetDescendants()) do
					if dec:IsA("Decal") then
						dec.Transparency = 1
					end
				end
			end
		end
	end
end

-- Скрываем тело в кастомной модели (визуал поверх тела)
for _, part in ipairs(model:GetDescendants()) do
	if part:IsA("BasePart") and bodyParts[part.Name] then
		part.Transparency = 1
		if part:IsA("MeshPart") then
			part.TextureID = ""
		end
	end
end

-- Присоединяем модель к HumanoidRootPart
model.Parent = character
model:SetPrimaryPartCFrame(hrp.CFrame)

local weld = Instance.new("Motor6D")
weld.Name = "RootJoint"
weld.Part0 = hrp
weld.Part1 = model.PrimaryPart
weld.C0 = CFrame.new()
weld.C1 = CFrame.new()
weld.Parent = hrp

-- Привязка остальных частей модели к её PrimaryPart
for _, part in ipairs(model:GetChildren()) do
	if part:IsA("BasePart") and part ~= model.PrimaryPart then
		local motor = Instance.new("Motor6D")
		motor.Name = part.Name .. "_Joint"
		motor.Part0 = model.PrimaryPart
		motor.Part1 = part
		motor.C0 = model.PrimaryPart.CFrame:ToObjectSpace(part.CFrame)
		motor.C1 = CFrame.new()
		motor.Parent = model.PrimaryPart
	end
end
