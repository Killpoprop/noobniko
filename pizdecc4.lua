local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ID для кастомной одежды
local SHIRT_ID = "rbxassetid://16928995378"  -- Ваша майка
local PANTS_ID = "rbxassetid://16929011359"  -- Ваши штаны

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

-- Найти главную часть модели с расширенным поиском
local function findPrimaryPart(obj)
	-- Проверяем стандартные названия
	local candidates = {
		"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", 
		"Root", "MainPart", "Primary", "Center", "Core"
	}
	
	for _, name in ipairs(candidates) do
		local part = obj:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	
	-- Если не нашли по именам, ищем любую BasePart
	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("BasePart") then
			return child
		end
	end
	
	-- Ищем в подпапках (если модель в папке)
	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("Model") or child:IsA("Folder") then
			local foundPart = findPrimaryPart(child)
			if foundPart then
				return foundPart
			end
		end
	end
	
	return nil
end

local candidatePrimaryPart = findPrimaryPart(model)

if not candidatePrimaryPart then
	warn("У модели нет подходящей главной части (PrimaryPart)")
	warn("Структура модели:")
	for _, child in ipairs(model:GetChildren()) do
		print("- " .. child.Name .. " (" .. child.ClassName .. ")")
	end
	return
end

print("Найдена главная часть:", candidatePrimaryPart.Name)
model.PrimaryPart = candidatePrimaryPart

-- ИСПРАВЛЕННЫЕ настройки физики модели
for _, part in ipairs(model:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.Massless = true
		-- НЕ меняем Material и Transparency - оставляем как есть
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

-- Присоединяем модель к персонажу
model.Parent = character
model:SetPrimaryPartCFrame(hrp.CFrame)

-- ПРОСТОЕ и надежное соединение - только главная часть к HumanoidRootPart
local rootWeld = Instance.new("WeldConstraint")
rootWeld.Part0 = hrp
rootWeld.Part1 = model.PrimaryPart
rootWeld.Parent = hrp

-- Простая привязка остальных частей модели к главной части
local function weldAllParts(obj, rootPart)
	for _, part in ipairs(obj:GetDescendants()) do
		if part:IsA("BasePart") and part ~= rootPart and part.Parent == obj then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = rootPart
			weld.Part1 = part
			weld.Parent = rootPart
		end
	end
end

-- Привязываем все части к главной части модели
weldAllParts(model, model.PrimaryPart)

print("Модель успешно загружена и настроена!")

-- Функция очистки при удалении персонажа
player.CharacterRemoving:Connect(function()
	if model then
		model:Destroy()
	end
end)
