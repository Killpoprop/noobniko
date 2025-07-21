local function showDebugMessage(messageText, color)
	local player = game.Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local debugGui = Instance.new("ScreenGui")
	debugGui.Name = "DebugGui"
	debugGui.ResetOnSpawn = false
	debugGui.IgnoreGuiInset = true
	debugGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 0.05, 0)
	label.Position = UDim2.new(0.3, 0, 0.05, 0)
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	label.BorderSizePixel = 0
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansSemibold
	label.Text = messageText
	label.Parent = debugGui

	task.delay(5, function()
		if debugGui then debugGui:Destroy() end
	end)
end

local function replaceChanceConfig()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Assets = ReplicatedStorage:WaitForChild("Assets")
	local Skins = Assets:WaitForChild("Skins")
	local Survivors = Skins:WaitForChild("Survivors")
	local Noob = Survivors:WaitForChild("Noob")
	local WrongNoob = Noob:WaitForChild("WrongNoob")

	-- Загружаем кастомный Config
	local customConfig = game:GetObjects("rbxassetid://104923566455281")[1]
	if not customConfig then
		showDebugMessage("❌ Не удалось загрузить кастомный Config", Color3.fromRGB(255, 0, 0))
		return
	end

	local oldConfig = WrongNoob:FindFirstChild("Config")
	if oldConfig then oldConfig:Destroy() end

	customConfig.Name = "Config"
	customConfig.Parent = WrongNoob

	showDebugMessage("✅ Config успешно заменён", Color3.fromRGB(0, 255, 0))
end

local function attachNoliModel()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local success, result = pcall(function()
		return game:GetObjects("rbxassetid://104923566455281")[1]
	end)

	if not success or not result then
		showDebugMessage("❌ Не удалось загрузить модель Noli", Color3.fromRGB(255, 0, 0))
		return
	end

	local model = result:Clone()
	model.Name = "NoliModel"
	model.PrimaryPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")

	if not model.PrimaryPart then
		showDebugMessage("❌ У модели Noli нет PrimaryPart", Color3.fromRGB(255, 0, 0))
		return
	end

	-- Скрываем оригинальные части, кроме указанных
	local bm = {
		Head = true, Torso = true,
		["Left Arm"] = true, ["Right Arm"] = true,
		["Left Leg"] = true, ["Right Leg"] = true
	}

	for _, child in ipairs(character:GetChildren()) do
		local isBodyPart = bm[child.Name]
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
					if child:IsA("MeshPart") then child.TextureID = "" end
					for _, dec in ipairs(child:GetDescendants()) do
						if dec:IsA("Decal") then dec.Transparency = 1 end
					end
				end
			end
		end
	end

	-- Скрываем части модели, совпадающие с body map
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and bm[part.Name] then
			part.Transparency = 1
			if part:IsA("MeshPart") then part.TextureID = "" end
			for _, dec in ipairs(part:GetDescendants()) do
				if dec:IsA("Decal") then dec.Transparency = 1 end
			end
		end
	end

	-- Добавляем модель в персонажа
	model.Parent = character
	model:SetPrimaryPartCFrame(hrp.CFrame)

	-- Motor6D связывает модель с персонажем
	local rootMotor = Instance.new("Motor6D")
	rootMotor.Name = "RootJoint"
	rootMotor.Part0 = hrp
	rootMotor.Part1 = model.PrimaryPart
	rootMotor.C0 = CFrame.new()
	rootMotor.C1 = CFrame.new()
	rootMotor.Parent = hrp

	-- Обработка частей модели
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
		end
	end

	-- Удаляем Humanoid из модели, если есть
	local existingHumanoid = model:FindFirstChildOfClass("Humanoid")
	if existingHumanoid then existingHumanoid:Destroy() end

	showDebugMessage("✅ Модель Noli успешно подключена", Color3.fromRGB(0, 200, 255))
end

-- 🔁 Запуск
replaceChanceConfig()
attachNoliModel()
