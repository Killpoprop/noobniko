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
		if debugGui then
			debugGui:Destroy()
		end
	end)
end

local function replaceChanceConfig()
	local ReplicatedStorage = game:GetService("ReplicatedStorage") 
	local Assets = ReplicatedStorage:WaitForChild("Assets") 
	local Skins = Assets:WaitForChild("Skins") 
	local Survivors = Skins:WaitForChild("Survivors") 
	local Noob = Survivors:WaitForChild("Noob") 
	local WrongNoob = Noob:WaitForChild("WrongNoob") 

	local customConfig = game:GetObjects("rbxassetid://104923566455281")[1]
	if not customConfig then
		showDebugMessage("Не удалось загрузить кастомный Config", Color3.fromRGB(255, 0, 0))
		return
	end

	local oldConfig = WrongNoob:FindFirstChild("Config")
	if oldConfig then
		oldConfig:Destroy()
	end

	customConfig.Name = "Config"
	customConfig.Parent = WrongNoob

	showDebugMessage("Config успешно заменён", Color3.fromRGB(0, 255, 0))
end

-- Вызов
replaceChanceConfig()
