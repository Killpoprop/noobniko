-- ⚙️ Создание GUI для отладки
local function showDebugMessage(text, color)
	local screenGui = game.Players.LocalPlayer:FindFirstChild("DebugGui") or Instance.new("ScreenGui")
	screenGui.Name = "DebugGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	local msgLabel = screenGui:FindFirstChild("Message") or Instance.new("TextLabel")
	msgLabel.Name = "Message"
	msgLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
	msgLabel.Position = UDim2.new(0.25, 0, 0.9, 0)
	msgLabel.BackgroundTransparency = 0.3
	msgLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	msgLabel.BorderSizePixel = 0
	msgLabel.TextColor3 = color or Color3.new(1, 1, 1)
	msgLabel.Font = Enum.Font.SourceSansBold
	msgLabel.TextScaled = true
	msgLabel.Text = text
	msgLabel.Parent = screenGui

	task.delay(5, function()
		if msgLabel then msgLabel:Destroy() end
	end)
end

-- 👤 Получение игрока и персонажа
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- 🚛 Загрузка модели
local model
local success, result = pcall(function()
	return game:GetObjects("rbxassetid://104923566455281")[1]
end)

if not success or not result then
	showDebugMessage("❌ Не удалось загрузить модель: " .. tostring(result), Color3.fromRGB(255, 100, 100))
	return
end

model = result:Clone()
model.Name = "NoliModel"

-- 📌 Назначение PrimaryPart вручную
local function assignPrimaryPart(m)
	for _, part in ipairs(m:GetDescendants()) do
		if part:IsA("BasePart") then
			m.PrimaryPart = part
			return true
		end
	end
	return false
end

if not assignPrimaryPart(model) then
	showDebugMessage("⚠️ У модели нет PrimaryPart", Color3.fromRGB(255, 200, 0))
	return
end

-- 🧍 Настройка отображения частей
local bm = {
	Head = "Head",
	Torso = "Torso",
	["Left Arm"] = "Left Arm",
	["Right Arm"] = "Right Arm",
	["Left Leg"] = "Left Leg",
	["Right Leg"] = "Right Leg"
}

for _, child in ipairs(character:GetChildren()) do
	local isBodyPart = bm[child.Name] ~= nil
	if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Accessory") then
		if not isBodyPart then
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

-- 📦 Скрытие дублируемых частей в модели
for _, part in ipairs(model:GetDescendants()) do
	if part:IsA("BasePart") and bm[part.Name] then
		part.Transparency = 1
		if part:IsA("MeshPart") then
			part.TextureID = ""
		end
		for _, dec in ipairs(part:GetDescendants()) do
			if dec:IsA("Decal") then
				dec.Transparency = 1
			end
		end
	end
end

-- 🔩 Установка модели
model.Parent = character
model:SetPrimaryPartCFrame(hrp.CFrame)

-- 🔗 Привязка модели к персонажу
local rootMotor = Instance.new("Motor6D")
rootMotor.Name = "RootJoint"
rootMotor.Part0 = hrp
rootMotor.Part1 = model.PrimaryPart
rootMotor.C0 = CFrame.new()
rootMotor.C1 = CFrame.new()
rootMotor.Parent = hrp

-- 🧱 Настройка свойств частей модели
for _, part in ipairs(model:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
	end
end

-- ❌ Удаление Humanoid в модели
local existingHumanoid = model:FindFirstChildOfClass("Humanoid")
if existingHumanoid then existingHumanoid:Destroy() end

-- ✅ Финальное сообщение
showDebugMessage("✅ Модель успешно установлена!", Color3.fromRGB(100, 255, 100))
