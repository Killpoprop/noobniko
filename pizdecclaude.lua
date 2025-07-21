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
if existingHumanoid then 
	existingHumanoid:Destroy() 
end

model.Name = "CustomVisualRig"

-- Найти главную часть модели вручную
local candidatePrimaryPart = model:FindFirstChild("HumanoidRootPart") or 
							model:FindFirstChild("Torso") or 
							model:FindFirstChildWhichIsA("BasePart")

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

-- Функция для скрытия аксессуаров/одежды
local function hideAccessory(accessory)
	local handle = accessory:FindFirstChild("Handle")
	if handle then
		handle.Transparency = 1
		-- Скрываем все текстуры и декали
		for _, descendant in ipairs(handle:GetDescendants()) do
			if descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("SurfaceGui") then
				descendant.Transparency = 1
			elseif descendant:IsA("SpecialMesh") then
				descendant.TextureId = ""
			end
		end
	end
end

-- ID для кастомной одежды (замените на свои)
local SHIRT_ID = "rbxassetid://16928995378"  -- Замените на ID вашей рубашки
local PANTS_ID = "rbxassetid://16929011359"  -- Замените на ID ваших штанов

-- Скрываем аксессуары и заменяем одежду
for _, child in ipairs(character:GetChildren()) do
	if child:IsA("Accessory") or child:IsA("Hat") then
		hideAccessory(child)
	elseif child:IsA("Shirt") then
		-- Заменяем рубашку на кастомную
		child.ShirtTemplate = SHIRT_ID
	elseif child:IsA("Pants") then
		-- Заменяем штаны на кастомные
		child.PantsTemplate = PANTS_ID
	elseif child:IsA("ShirtGraphic") then
		-- Удаляем ShirtGraphic, так как у нас есть кастомная рубашка
		child:Destroy()
	elseif child:IsA("BasePart") or child:IsA("MeshPart") then
		-- Скрываем части тела (кроме HumanoidRootPart для функциональности)
		if child.Name ~= "HumanoidRootPart" then
			child.Transparency = 1
			if child:IsA("MeshPart") then
				child.TextureID = ""
			end
			-- Скрываем декали на частях тела
			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("Decal") or descendant:IsA("Texture") then
					descendant.Transparency = 1
				end
			end
		end
	end
end

-- Если у персонажа нет рубашки или штанов, создаем их
if not character:FindFirstChildOfClass("Shirt") then
	local shirt = Instance.new("Shirt")
	shirt.Name = "Shirt"
	shirt.ShirtTemplate = SHIRT_ID
	shirt.Parent = character
end

if not character:FindFirstChildOfClass("Pants") then
	local pants = Instance.new("Pants")
	pants.Name = "Pants"
	pants.PantsTemplate = PANTS_ID
	pants.Parent = character
end

-- Присоединяем модель к HumanoidRootPart
model.Parent = character
model:SetPrimaryPartCFrame(hrp.CFrame)

-- Основное соединение модели с персонажем
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
