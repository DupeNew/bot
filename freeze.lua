local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ui = Instance.new("ScreenGui")
ui.Name = "XenixUI"
ui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 360, 0, 400)
main.Position = UDim2.new(0.5, -180, 0.45, 0)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Xenix"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 20
titleText.TextXAlignment = Enum.TextXAlignment.Center
titleText.Parent = titleBar

local search = Instance.new("TextBox")
search.PlaceholderText = "Search Player..."
search.Text = ""
search.Size = UDim2.new(1, -20, 0, 34)
search.Position = UDim2.new(0, 10, 0, 50)
search.Font = Enum.Font.Gotham
search.TextSize = 16
search.TextColor3 = Color3.fromRGB(255, 255, 255)
search.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
search.ClearTextOnFocus = false
search.Parent = main

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = search

local resultList = Instance.new("Frame")
resultList.Size = UDim2.new(1, -20, 0, 80)
resultList.Position = UDim2.new(0, 10, 0, 90)
resultList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
resultList.BorderSizePixel = 0
resultList.Parent = main

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = resultList

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = resultList

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 80, 0, 80)
avatar.Position = UDim2.new(0.5, -40, 0, 180)
avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
avatar.Parent = main

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatar

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 30)
nameLabel.Position = UDim2.new(0, 0, 0, 270)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextSize = 16
nameLabel.Text = ""
nameLabel.TextXAlignment = Enum.TextXAlignment.Center
nameLabel.Parent = main

local freeze = Instance.new("TextButton")
freeze.Size = UDim2.new(0.45, 0, 0, 40)
freeze.Position = UDim2.new(0.05, 0, 1, -50)
freeze.BackgroundColor3 = Color3.fromRGB(90, 120, 255)
freeze.Text = "Freeze"
freeze.TextColor3 = Color3.fromRGB(255, 255, 255)
freeze.Font = Enum.Font.GothamBold
freeze.TextSize = 16
freeze.Parent = main

local freezeCorner = Instance.new("UICorner")
freezeCorner.CornerRadius = UDim.new(0, 8)
freezeCorner.Parent = freeze

local accept = Instance.new("TextButton")
accept.Size = UDim2.new(0.45, 0, 0, 40)
accept.Position = UDim2.new(0.5, 0, 1, -50)
accept.BackgroundColor3 = Color3.fromRGB(255, 100, 120)
accept.Text = "Force Accept"
accept.TextColor3 = Color3.fromRGB(255, 255, 255)
accept.Font = Enum.Font.GothamBold
accept.TextSize = 16
accept.Parent = main

local acceptCorner = Instance.new("UICorner")
acceptCorner.CornerRadius = UDim.new(0, 8)
acceptCorner.Parent = accept

local function notify(text)
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {
			Title = "Xenix",
			Text = text,
			Duration = 3
		})
	end)
end

local function updateAvatar(player)
	local success, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	if success then
		avatar.Image = thumb
		nameLabel.Text = player.DisplayName .. " (" .. player.Name .. ")"
	else
		avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		nameLabel.Text = "Failed to load"
	end
end

local function createResult(player)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	btn.Text = player.DisplayName .. " (" .. player.Name .. ")"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BorderSizePixel = 0
	btn.Parent = resultList

	btn.MouseButton1Click:Connect(function()
		updateAvatar(player)
	end)
end

local function refreshList()
	for _, child in ipairs(resultList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local query = search.Text:lower()
	if query == "" then return end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower():find(query) or (player.DisplayName and player.DisplayName:lower():find(query)) then
			createResult(player)
		end
	end
end

search:GetPropertyChangedSignal("Text"):Connect(refreshList)

freeze.MouseButton1Click:Connect(function()
	notify("Trade frozen successfully")
end)

accept.MouseButton1Click:Connect(function()
	notify("Trade accepted forcibly")
end)

local function hover(btn, defaultColor, highlightColor)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = highlightColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play()
	end)
end

hover(freeze, Color3.fromRGB(90, 120, 255), Color3.fromRGB(110, 140, 255))
hover(accept, Color3.fromRGB(255, 100, 120), Color3.fromRGB(255, 130, 150))

for _, v in pairs(main:GetDescendants()) do
	if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
		v.TextTransparency = 1
	elseif v:IsA("ImageLabel") then
		v.ImageTransparency = 1
	end
end
main.BackgroundTransparency = 1

task.wait(0.1)

TweenService:Create(main, TweenInfo.new(0.4), {BackgroundTransparency = 0.05}):Play()
for _, v in pairs(main:GetDescendants()) do
	if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
		TweenService:Create(v, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	elseif v:IsA("ImageLabel") then
		TweenService:Create(v, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
	end
end
