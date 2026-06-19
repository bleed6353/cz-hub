local MainWindow = Rayfield:CreateWindow({
   Name = " Saint.cc| Tb3 | pieereu",
   Icon = 72133851562563,
   LoadingTitle = "Introducing Saint.cc ",
   LoadingSubtitle = "By Pieereu",
   ShowText = "pieereu on discord", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Green", -- Check https://[Log in to view URL]

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "saint hub"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Saint.cc | Key",
      Subtitle = "Key System",
      Note = "August", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"August"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local MainTab = MainWindow:CreateTab("Main")
local MoneyTab = MainWindow:CreateTab("Money")
local CombatTab = MainWindow:CreateTab("Combat", nil)
local BypassesTab = MainWindow:CreateTab("Bypasses", nil) -- Title, Image
local CreditsTab = MainWindow:CreateTab("Credits", nil) -- Title, Image
local SettingsTab = MainWindow:CreateTab("Settings")


local Section = MainTab:CreateSection("Teleportation Places")

-- ESP setup (same as before)
local NameESP_Enabled = false
local Tracer_Enabled = false
local HoldingESP_Enabled = false
local ESPData = {}
local HoldingLabels = {}

local function removeESPForPlayer(player)
	if ESPData[player] then
		if ESPData[player].NameESP then ESPData[player].NameESP:Destroy() end
		if ESPData[player].Tracer then ESPData[player].Tracer:Destroy() end
		ESPData[player] = nil
	end
end

local function createNameESP(player)
	if not player.Character then return end
	local head = player.Character:FindFirstChild("Head")
	if not head then return end
	if ESPData[player] and ESPData[player].NameESP then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameESP"
	billboard.Adornee = head
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 200, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 11
	label.Text = player.Name
	label.Parent = billboard

	ESPData[player] = ESPData[player] or {}
	ESPData[player].NameESP = billboard
end

local function createTracer(player)
	if not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not localHrp then return end
	if ESPData[player] and ESPData[player].Tracer then return end

	local line = Instance.new("Part")
	line.Name = "TracerLine"
	line.Anchored = true
	line.CanCollide = false
	line.Transparency = 0
	line.Material = Enum.Material.Neon
	line.Color = Color3.new(1,1,1)
	line.Size = Vector3.new(0.05, 0.05, 1)
	line.Parent = workspace

	ESPData[player] = ESPData[player] or {}
	ESPData[player].Tracer = line
end

local function updateTracer(player)
	local data = ESPData[player]
	if not data or not data.Tracer then return end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not localHrp then
		data.Tracer.Transparency = 1
		return
	end

	local startPos = localHrp.Position
	local endPos = hrp.Position
	local distance = (endPos - startPos).Magnitude
	local midPoint = (startPos + endPos) / 2

	data.Tracer.Size = Vector3.new(0.05, 0.05, distance)
	data.Tracer.CFrame = CFrame.new(midPoint, endPos)
	data.Tracer.Transparency = 0
end

local function updateHoldingLabel(player)
	if not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local label = HoldingLabels[player]
	if not label then
		label = Instance.new("BillboardGui")
		label.Name = "HoldingLabel"
		label.Adornee = hrp
		label.AlwaysOnTop = true
		label.Size = UDim2.new(0, 100, 0, 20)
		label.StudsOffset = Vector3.new(0, -3, 0)
		label.Parent = hrp

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextSize = 9
		textLabel.Text = ""
		textLabel.Parent = label

		HoldingLabels[player] = label
	end

	local holdingName = "Fists"
	for _, item in pairs(player.Character:GetChildren()) do
		if item:IsA("Tool") then
			holdingName = item.Name
			break
		end
	end

	label.TextLabel.Text = holdingName
end

local function removeHoldingLabel(player)
	if HoldingLabels[player] then
		HoldingLabels[player]:Destroy()
		HoldingLabels[player] = nil
	end
end

local function setupPlayer(player)
	if player.Character then
		if NameESP_Enabled then createNameESP(player) end
		if Tracer_Enabled then createTracer(player) end
		if HoldingESP_Enabled then updateHoldingLabel(player) end
	end
	player.CharacterAdded:Connect(function()
		task.wait(0.1)
		if NameESP_Enabled then createNameESP(player) end
		if Tracer_Enabled then createTracer(player) end
		if HoldingESP_Enabled then updateHoldingLabel(player) end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in pairs(Players:GetPlayers()) do setupPlayer(player) end

RunService.Heartbeat:Connect(function()
	for player, _ in pairs(ESPData) do
		if player ~= LocalPlayer then
			if Tracer_Enabled then
				updateTracer(player)
			elseif ESPData[player] and ESPData[player].Tracer then
				ESPData[player].Tracer.Transparency = 1
			end
		end
	end

	if HoldingESP_Enabled then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				updateHoldingLabel(player)
			end
		end
	else
		for _, label in pairs(HoldingLabels) do
			label.TextLabel.Text = ""
		end
	end
end)

local Section = CombatTab:CreateSection("ESP")

CombatTab:CreateToggle({
	Name = "Name ESP",
	CurrentValue = false,
	Callback = function(val)
		NameESP_Enabled = val
		for _, player in pairs(Players:GetPlayers()) do
			if val then createNameESP(player)
			else removeESPForPlayer(player) end
		end
	end,
})

CombatTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = false,
	Callback = function(val)
		Tracer_Enabled = val
		for _, player in pairs(Players:GetPlayers()) do
			if val then createTracer(player)
			else removeESPForPlayer(player) end
		end
	end,
})

CombatTab:CreateToggle({
	Name = "Holding",
	CurrentValue = false,
	Callback = function(val)
		HoldingESP_Enabled = val
		for _, player in pairs(Players:GetPlayers()) do
			if val then updateHoldingLabel(player)
			else removeHoldingLabel(player) end
		end
	end,
})

local Toggle = CombatTab:CreateToggle({
   Name = "Box",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        
	end,
})

local Section = MoneyTab:CreateSection("Infinite Money")

local Paragraph = MoneyTab:CreateParagraph({
    Title = "Instructions:",
    Content =
    "Buy Ice Fruit Items, Then Cook As Usual. When Done Click Teleport To Seller Then Click Infinite Money While Holding The Cup Out"
})

local Button = MoneyTab:CreateButton({
   Name = "Infinite Money",
   Callback = function()
        task.wait(1.5)
for i = 1, 1000 do
fireproximityprompt(workspace["IceFruit Sell"].ProximityPrompt)
end
   end,
})

MoneyTab:CreateButton({
	Name = "Tp To Seller",
	Callback = function()
		local Character = LocalPlayer.Character
		local Humanoid = Character and Character:WaitForChild("Humanoid")
		local RootPart = Character and Character:WaitForChild("HumanoidRootPart")
		Humanoid:ChangeState(0)
		repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
		RootPart.CFrame = CFrame.new(-48.13759231567383, 287.0636291503906, -320.6361389160156)
		Humanoid:ChangeState(2)
	end,
})

MoneyTab:CreateButton({
   Name = "Buy Inf Money Items",
   Callback = function()
        game.ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer("Ice-Fruit Cupz")
		game.ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer("FijiWater")
		game.ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer("FreshWater")
		game.ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer("Ice-Fruit Bag")
   end,
})

MoneyTab:CreateButton({
	Name = "Tp To Penthouse",
	Callback = function()
		local Character = LocalPlayer.Character
		local Humanoid = Character and Character:WaitForChild("Humanoid")
		local RootPart = Character and Character:WaitForChild("HumanoidRootPart")
		Humanoid:ChangeState(0)
		repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
		RootPart.CFrame = CFrame.new(-137.7384033203125, 397.1383056640625, -566.6077880859375)
		Humanoid:ChangeState(2)
	end,
})

local Section = MoneyTab:CreateSection("AutoFarms")

local Paragraph = MoneyTab:CreateParagraph({
    Title = "Instructions",
    Content =
    "Enable Instant interact Before Trigerring The Autofarm Of Your Choice"
})

MoneyTab:CreateToggle({
	Name = "Instant Interact",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
		local ProximityPromptService = game:GetService("ProximityPromptService")
		ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			if Value then
				fireproximityprompt(prompt)
			end
		end)
	end,
})

local Button = MoneyTab:CreateButton({
   Name = "Studio AutoFarm",
   Callback = function()
        		local Positions = {
			Vector3.new(93418.5625, 14486.2060546875, 565.1326293945312),
			Vector3.new(93435.015625, 14486.5556640625, 563.5263671875),
			Vector3.new(93427.2734376, 14487.2158203125, 577.9862670898438),
		}

		local function SafeTeleport(pos)
			local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local Humanoid = Character:WaitForChild("Humanoid")
			local RootPart = Character:WaitForChild("HumanoidRootPart")
			Humanoid:ChangeState(0)
			repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
			RootPart.CFrame = CFrame.new(pos)
			Humanoid:ChangeState(2)
		end

		local function PressE(times)
			for i = 1, times do
				VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
				task.wait(0.04)
				VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				task.wait(0.04)
			end
		end

		for _, pos in ipairs(Positions) do
			SafeTeleport(pos)
			task.wait(0.3)
			PressE(8)
			task.wait(0.2)
		end
	end,
})


local Button = MoneyTab:CreateButton({
   Name = "Construction AutoFarm",
   Callback = function()
                 getgenv().cfg = {
    ["switch_servers_when_no_wood"] = false, -- change to false to autofarm in 1 server MUST HAVE SCRIPT IN AUTOEXEC TO WORK
    ["serverhop_timeout"] = 80 -- timeout to serverhop if sum breaks, change to 999999 to make it never serverhop
}
 
pcall(function()
repeat task.wait(3) until game:IsLoaded()
repeat task.wait(3) until game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen
end)
pcall(function()
repeat firesignal(game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen.Frame.play.MouseButton1Click) until not game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen
end)
pcall(function()
repeat task.wait(1) until not game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen
end)
 
start = tick()
 
local jobnigga = workspace.ConstructionStuff["Start Job"].CFrame
 
-- made in 30 mins b4 som1 complains about messy code
 
local function startjob()
if not game.Players.LocalPlayer:GetAttribute("WorkingJob") or game.Players.LocalPlayer:GetAttribute("WorkingJob") == false then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = jobnigga
fireproximityprompt(workspace.ConstructionStuff["Start Job"].Prompt)
end
end
 
local function autoequipwood()
if game:GetService("Players").LocalPlayer.Backpack.PlyWood then
game:GetService("Players").LocalPlayer.Backpack.PlyWood.Parent = game:GetService("Players").LocalPlayer.Character
end
end
 
local function wood()
for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
if v:IsA("ProximityPrompt") and v.ActionText == "Wall" then
fireproximityprompt(v)
end
end
end
 
local function grabwood()
for i, v in pairs(workspace.ConstructionStuff["Grab Wood"]:GetChildren()) do
if v:IsA("ProximityPrompt") and v.ActionText == "Wood" then
fireproximityprompt(v)
end
end
end
 
local function mainautofarm()
for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
if v:IsA("Part") and string.find(v.Name, "Prompt") then
local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
if not string.find(text, "RESETS") then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
end
end
end
if not (game.Players.LocalPlayer.Backpack:FindFirstChild("PlyWood") or game.Players.LocalPlayer.Character:FindFirstChild("PlyWood")) then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1728, 371, -1177)
end
end
 
task.spawn(function()
while task.wait(1/4) do
xpcall(startjob, debug.traceback)
end
end)
 
task.spawn(function()
while task.wait(1/6) do
xpcall(wood, debug.traceback)
xpcall(grabwood, debug.traceback)
xpcall(autoequipwood, debug.traceback)
xpcall(mainautofarm, debug.traceback)
end
end)
 
-- tp script below forked from https://[Log in to view URL]
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://[Log in to view URL]' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://[Log in to view URL]' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

            
function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end
-- end of fork
 
local function checkfornowood()
if not cfg["switch_servers_when_no_wood"] then return end
local x = true
for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
if v:IsA("Part") and string.find(v.Name, "Prompt") then
local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
if not string.find(text, "RESETS") then
x = false
break
end
end
end
if x then Teleport() end
end
 
local function timeout()
while true do
task.wait(1)
local currenttime = tick() - start
if currenttime >= cfg["serverhop_timeout"] then
Teleport()
end
end
end
 
task.spawn(function()
timeout()
end)
 
while task.wait(4) do
    xpcall(checkfornowood, debug.traceback)
end
   end,
})

local locations = {
    ["Bank"] = Vector3.new(-204, 284, -1223),
    ["Bank Tools"] = Vector3.new(-387.900, 340.341, -565.482),
    ["Safe"] = Vector3.new(-1016.682, 266.106, -907.611),
    ["Gunshop 1"] = Vector3.new(92967.672, 122098.055, 17023.986),
    ["Gunshop 2"] = Vector3.new(66199.828, 123615.711, 5749.527),
    ["Exotic Gun"] = Vector3.new(60820.309, 87609.141, -351.475),
    ["Studio Gun"] = Vector3.new(72423.023, 128855.641, -1085.557),
    ["Car Dealer"] = Vector3.new(-384.950, 253.231, -1240.637),
    ["Penthouse"] = Vector3.new(-137.7384033203125, 397.1383056640625, -566.6077880859375),
    ["Penthouse 2"] = Vector3.new(-614.738, 356.311, -687.077),
    ["Money Wash"] = Vector3.new(-989.245, 253.722, -689.821),
    ["Jewerly Rob"] = Vector3.new(-210.618, 283.492, -1256.966),
    ["Watch Store"] = Vector3.new(-205.227, 283.849, -1170.066),
    ["Clothing Store"] = Vector3.new(67462.695, 10489.032, 549.589),
    ["Construction"] = Vector3.new(-1731.831, 370.812, -1176.839),
    ["Backpack Shop"] = Vector3.new(-670, 254, -681),
    ["Lemonade"] = Vector3.new(-1518.791, 271.244, -983.778)
}

-- Get Players service
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Teleport function
local function SafeTeleport(pos)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")

    Humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    RootPart.CFrame = CFrame.new(pos)
    Humanoid:ChangeState(2)
end

-- Convert dictionary keys to array for dropdown
local locationNames = {}
for name in pairs(locations) do
    table.insert(locationNames, name)
end

-- Selected location
local selectedLocation = nil

-- Create dropdown
local Dropdown = MainTab:CreateDropdown({
    Name = "Select Location",
    Options = locationNames,
    CurrentOption = {"Bank"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        selectedLocation = Options[1]
    end,
})

-- Create button
MainTab:CreateButton({
    Name = "Teleport to Selected",
    Callback = function()
        if selectedLocation and locations[selectedLocation] then
            SafeTeleport(locations[selectedLocation])
        else
            Rayfield:Notify({
                Title = "Teleport Error",
                Content = "Please select a valid location!",
                Duration = 3
            })
        end
    end,
})


local Section = MoneyTab:CreateSection("Dupe Item")

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local Paragraph = MoneyTab:CreateParagraph({
    Title = "Instructions",
    Content =
    "Hold The Item That You Want To Dupe Out Then Click Dupe Item If Doesnt work On The First Try, Try Again And It Should Work"
})

local Button = MoneyTab:CreateButton({
   Name = "Dupe Item",
   Callback = function()
            local Player = Players.LocalPlayer
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Backpack = Player:WaitForChild("Backpack")
		local Tool = Character:FindFirstChildOfClass("Tool")
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

		if not Tool then return end

		local function getEquippedToolName()
			local tool = Character:FindFirstChildOfClass("Tool")
			return tool and tool.Name or "Nothing"
		end

		local equippedName = getEquippedToolName()

		Rayfield:Notify({
			Title = "Market Dupe",
			Content = "Duping " .. equippedName,
			Duration = 5,
			Image = "rbxassetid://"
		})

		Tool.Parent = Backpack
		task.wait(0.5)

		local ToolName = Tool.Name
		local ToolId = nil

		local function getPing()
			if typeof(Player.GetNetworkPing) == "function" then
				local success, result = pcall(function()
					return tonumber(string.match(Player:GetNetworkPing(), "%d+"))
				end)
				if success and result then return result end
			end

			local success2, pingStat = pcall(function()
				return Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Ping") or
					   Players.LocalPlayer:FindFirstChild("PlayerScripts"):FindFirstChild("Ping")
			end)

			if success2 and pingStat and pingStat:IsA("TextLabel") then
				local num = tonumber(string.match(pingStat.Text, "%d+"))
				if num then return num end
			end

			local t0 = tick()
			local temp = Instance.new("BoolValue", ReplicatedStorage)
			temp.Name = "PingTest_" .. tostring(math.random(10000, 99999))
			task.wait(0.1)
			local t1 = tick()
			temp:Destroy()

			return math.clamp((t1 - t0) * 1000, 50, 300)
		end

		local ping = getPing()
		local delay = 0.25 + ((math.clamp(ping, 0, 300) / 300) * 0.03)

		local marketconnection = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
			if item.Name == ToolName then
				local owner = item:WaitForChild("owner", 2)
				if owner and owner.Value == Player.Name then
					ToolId = item:GetAttribute("SpecialId")
				end
			end
		end)

		task.spawn(function()
			ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999)
		end)

		task.wait(delay)

		task.spawn(function()
			ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName)
		end)

		task.wait(2.5)

		if ToolId then
			task.spawn(function()
				ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", ToolId)
			end)
		end

		task.spawn(function()
			ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName)
		end)

		Rayfield:Notify({
			Title = "Successfully Duped!",
			Content = "Item has been successfully duplicated.",
			Duration = 10,
			Image = "rbxassetid://"
		})

		task.wait(1)
		marketconnection:Disconnect()
	end
})

local Paragraph = CreditsTab:CreateParagraph({Title = "Credit", Content = "Dev: jgunzz1212 Special Thanks: .xzx"})

local Section = CombatTab:CreateSection("Aimbot")

local Button = CombatTab:CreateButton({
   Name = "Aimbot",
   Callback = function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = game.Players.LocalPlayer:GetMouse()
local CamlockState = false
local Prediction = 0.1768521
local HorizontalPrediction = 0.111076110
local VerticalPrediction = 0.11034856
local XPrediction = 20
local YPrediction = 20

local Players = game:GetService("Players")	
local LP = Players.LocalPlayer	
local Mouse = LP:GetMouse()	

local Locked = true

getgenv().Key = "v"

function FindNearestEnemy()
    local ClosestDistance, ClosestPlayer = math.huge, nil
    local CenterPosition =
        Vector2.new(
        game:GetService("GuiService"):GetScreenResolution().X / 2,
        game:GetService("GuiService"):GetScreenResolution().Y / 2
    )

    for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") and Character.Humanoid.Health > 0 then
                local Position, IsVisibleOnViewport =
                    game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(Character.HumanoidRootPart.Position)

                if IsVisibleOnViewport then
                    local Distance = (CenterPosition - Vector2.new(Position.X, Position.Y)).Magnitude
                    if Distance < ClosestDistance then
                        ClosestPlayer = Character.HumanoidRootPart
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

local enemy = nil
-- Function to aim the camera at the nearest enemy's HumanoidRootPart
RunService.Heartbeat:Connect(
    function()
        if CamlockState == true then
            if enemy then
                local camera = workspace.CurrentCamera
                camera.CFrame = CFrame.new(camera.CFrame.p, enemy.Position + enemy.Velocity * Prediction)
            end
        end
    end
)

Mouse.KeyDown:Connect(function(k)	
    if k == getgenv().Key then	
            Locked = not Locked	
            if Locked then	
                enemy = FindNearestEnemy()
                CamlockState = true
             else	
                if enemy ~= nil then	
                    enemy = nil	
                    CamlockState = false
                end	
            end	
    end	
end)

local Rushex = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Logo = Instance.new("ImageLabel")
local TextButton = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")

--Properties:

Rushex.Name = "Aimbot"
Rushex.Parent = game.CoreGui
Rushex.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = Rushex
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Background set to white
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.133798108, 0, 0.20107238, 0)
Frame.Size = UDim2.new(0, 195, 0, 60)
Frame.Active = true
Frame.Draggable = true

local function TopContainer()
	Frame.Position = UDim2.new(0.5, -Frame.AbsoluteSize.X / 2, 0, -Frame.AbsoluteSize.Y / 2)
end

TopContainer()
Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(TopContainer)

UICorner.Parent = Frame

Logo.Name = "Logo"
Logo.Parent = Frame
Logo.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
Logo.BackgroundTransparency = 3.000
Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0.326732665, 0, 0, 0)
Logo.Size = UDim2.new(0, 70, 0, 70)
Logo.Image = "rbxassetid://"
Logo.ImageTransparency = 0.300

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(75, 80, 255)
TextButton.BackgroundTransparency = 5.000
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.0792079195, 0, 0.18571429, 0)
TextButton.Size = UDim2.new(0, 170, 0, 44)
TextButton.Font = Enum.Font.SourceSansSemibold
TextButton.Text = "Toggle Aimbot"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)  -- Text color changed to black
TextButton.TextScaled = true
TextButton.TextSize = 18.000
TextButton.TextWrapped = true
local state = true
TextButton.MouseButton1Click:Connect(
    function()
        state = not state
        if not state then
            TextButton.Text = "Aimbot ON"
            CamlockState = true
            enemy = FindNearestEnemy()
        else
            TextButton.Text = "Aimbot OFF"
            CamlockState = false
            enemy = nil
        end
    end
)

-- Function to hide the loading screen after a certain duration
local function HideLoadingScreen()
    LoadingScreen:Destroy()
end
   end,
})

local Section = BypassesTab:CreateSection("Bypasses")

local Toggle = BypassesTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
--Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true
	
	--Notifies readiness
	game.StarterGui:SetCore("SendNotification", {Title="Infinite Jump Activated"; Text="Use Wisely!"; Duration=5;})

	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if _G.infinjump then
			if k:byte() == 32 then
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			wait()
			humanoid:ChangeState('Seated')
			end
		end
	end)
end
   end,
})

local Paragraph = BypassesTab:CreateParagraph({
    Title = "Notice",
    Content =
    "Do Not Spam Infinite Jump Too Much Or You Might Get Kicked Use Wisely"
})

local AntiStaminaEnabled = false

BypassesTab:CreateToggle({
    Name = "Inf Stamina",
    CurrentValue = false,
    Callback = function(Value)
        AntiStaminaEnabled = Value
        if Value then
            task.spawn(function()
                while AntiStaminaEnabled do
                    task.wait(1)
                    local player = game.Players.LocalPlayer
                    if player and player:FindFirstChild("PlayerGui") then
                        local staminaScript =
                            player.PlayerGui:FindFirstChild("Run") and
                            player.PlayerGui.Run:FindFirstChild("Frame") and
                            player.PlayerGui.Run.Frame:FindFirstChild("Frame") and
                            player.PlayerGui.Run.Frame.Frame:FindFirstChild("Frame") and
                            player.PlayerGui.Run.Frame.Frame.Frame:FindFirstChild("StaminaBarScript")
                        
                        if staminaScript then
                            staminaScript.Disabled = true
                        end
                    end
                end
            end)
        end
    end
})

local AntiHungerEnabled = false
BypassesTab:CreateToggle({
    Name = "Inf Hunger",
    CurrentValue = false,
    Callback = function(Value)
        AntiHungerEnabled = Value
        if Value then
            task.spawn(function()
                while AntiHungerEnabled do
                    task.wait(1)
                    local player = game.Players.LocalPlayer
                    if player and player:FindFirstChild("PlayerGui") then
                        local hungerGui = player.PlayerGui:FindFirstChild("Hunger")
                        if hungerGui then
                            local hungerScript = hungerGui:FindFirstChild("Frame")
                                and hungerGui.Frame:FindFirstChild("Frame")
                                and hungerGui.Frame.Frame:FindFirstChild("Frame")
                                and hungerGui.Frame.Frame.Frame:FindFirstChild("HungerBarScript")
                            if hungerScript then
                                hungerScript.Disabled = true
                            end
                        end
                    end
                end
            end)
        end
    end
})

local AntiSleepEnabled = false
BypassesTab:CreateToggle({
    Name = "Anti Sleep",
    CurrentValue = false,
    Callback = function(Value)
        AntiSleepEnabled = Value
        if Value then
            task.spawn(function()
                while AntiSleepEnabled do
                    task.wait(1)
                    local player = game.Players.LocalPlayer
                    if player and player:FindFirstChild("PlayerGui") then
                        local sleepGui = player.PlayerGui:FindFirstChild("SleepGui")
                        if sleepGui then
                            local sleepScript = sleepGui:FindFirstChild("Frame")
                                and sleepGui.Frame:FindFirstChild("sleep")
                                and sleepGui.Frame.sleep:FindFirstChild("SleepBar")
                                and sleepGui.Frame.sleep.SleepBar:FindFirstChild("sleepScript")
                            if sleepScript then
                                sleepScript.Disabled = true
                            end
                        end
                    end
                end
            end)
        end
    end
})

local AntiFallEnabled = false
local AntiFallToggle = BypassesTab:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Callback = function(Value)
        AntiFallEnabled = Value
        if Value then
            task.spawn(function()
                while AntiFallEnabled do
                    task.wait(1)
                    local player = game.Players.LocalPlayer
                    if player and player.Character then
                        local fallDamage = player.Character:FindFirstChild("FallDamageRagdoll")
                        if fallDamage then
                            fallDamage.Disabled = true
                        end
                    end
                end
            end)
        end
    end
})

BypassesTab:CreateToggle({
    Name = "No Jump Cooldown",
    CurrentValue = false,
    Flag = "AntiJumpCooldown",
    Callback = function(Value)
        getgenv().noJumpCooldown = Value

        if Value then
            task.spawn(function()
                while getgenv().noJumpCooldown do
                    task.wait(0.2)
                    pcall(function()
                        local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            local debounce = playerGui:FindFirstChild("JumpDebounce")
                            if debounce then
                                debounce:Destroy()
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

local AntiRentPayEnabled = false
BypassesTab:CreateToggle({
    Name = "No Rent Pay",
    CurrentValue = false,
    Callback = function(Value)
        AntiRentPayEnabled = Value
        if Value then
            task.spawn(function()
                while AntiRentPayEnabled do
                    task.wait(1)
                    local player = game.Players.LocalPlayer
                    local rentGui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("RentGui")
                    if rentGui then
                        local rentScript = rentGui:FindFirstChild("LocalScript")
                        if rentScript then
                            rentScript.Disabled = true
                            rentScript:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

BypassesTab:CreateToggle({
	Name = "Instant Interact",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
		local ProximityPromptService = game:GetService("ProximityPromptService")
		ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			if Value then
				fireproximityprompt(prompt)
			end
		end)
	end,
})

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function getCharacter()
    return localPlayer.Character or localPlayer.CharacterAdded:Wait()
end

local function safeTeleport(x, y, z)
    local character = getCharacter()
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    humanoid:ChangeState(0)
    repeat task.wait() until not localPlayer:GetAttribute("LastACPos")
    hrp.CFrame = CFrame.new(x, y, z)
    humanoid.PlatformStand = false
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local selectedPlayer = nil

MainTab:CreateSection("Player")

local Dropdown = MainTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerNames(),
    CurrentOption = { "None" },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Options)
        selectedPlayer = Players:FindFirstChild(Options[1])
    end,
})

MainTab:CreateToggle({
    Name = "Spectate Selected Player",
    CurrentValue = false,
    Flag = "SpectateToggle",
    Callback = function(Value)
        if Value then
            if selectedPlayer and selectedPlayer.Character then
                workspace.CurrentCamera.CameraSubject = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
        else
            local character = getCharacter()
            if character and character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
            end
        end
    end,
})

MainTab:CreateButton({
    Name = "Teleport To Selected Player",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = selectedPlayer.Character.HumanoidRootPart.Position
            safeTeleport(pos.X, pos.Y, pos.Z)
        end
    end,
})

Players.PlayerAdded:Connect(function()
    Dropdown:Refresh(getPlayerNames())
end)

Players.PlayerRemoving:Connect(function()
    Dropdown:Refresh(getPlayerNames())
end)

MainTab:CreateToggle({
    Name = "Kill Bring",
    CurrentValue = false,
    Flag = "LoopBringToggle",
    Callback = function(Value)
        loopBring = Value
        if loopBring then
            bringLoop = task.spawn(function()
                while loopBring do
                    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local character = getCharacter()
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local myPos = character.HumanoidRootPart.Position
                            selectedPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPos)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

local loopAttack = false
local attackLoop

MainTab:CreateToggle({
    Name = "Kill player / Fist",
    CurrentValue = false,
    Flag = "LoopAttackToggle",
    Callback = function(Value)
        loopAttack = Value

        if loopAttack then
            attackLoop = task.spawn(function()
                while loopAttack do
                    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = selectedPlayer.Character.HumanoidRootPart.Position
                        safeTeleport(pos.X, pos.Y, pos.Z)

                        local character = getCharacter()
                        local backpack = localPlayer:FindFirstChild("Backpack")
                        local fist = character:FindFirstChild("Fist") or (backpack and backpack:FindFirstChild("Fist"))

                        if fist then
                            if backpack and backpack:FindFirstChild("Fist") then
                                fist.Parent = character
                            end

                            local attackRemote = character:FindFirstChild("Fist"):FindFirstChild("MeleeSystem"):FindFirstChild("AttackEvent")
                            if attackRemote then
                                for _ = 1, 40 do
                                    attackRemote:FireServer()
                                    task.wait()
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end,
})

local Section = MainTab:CreateSection("Troll")

local messageToSend = ""
local spamming = false
local spamDelay = 0

local function sendTweet()
    if messageToSend ~= "" then
        local args = {
            "Tweet",
            {
                "CreateTweet",
                messageToSend
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Resources")
            :WaitForChild("#Phone")
            :WaitForChild("Main")
            :FireServer(unpack(args))
    end
end

MainTab:CreateInput({
    Name = "Tweet Message",
    PlaceholderText = "Type Here",
    RemoveTextAfterFocusLost = false,
    EnterSubmit = true,
    Callback = function(Input)
        messageToSend = Input
        sendTweet()
    end,
})

local Slider = MainTab:CreateSlider({
    Name = "Spam Tweets Delay",
    Range = { 0, 10 },
    Increment = 1,
    Suffix = "s",
    CurrentValue = 10,
    Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        local spamDelay = Value
    end,
})

MainTab:CreateToggle({
    Name = "Spam Tweets",
    CurrentValue = false,
    Flag = "spamToggle",
    Callback = function(value)
        spamming = value
        if spamming then
            spawn(function()
                while spamming do
                    sendTweet()
                    wait(spamDelay)
                end
            end)
        end
    end,
})


CombatTab:CreateSection("Weapon Modifications")

CombatTab:CreateButton({
    Name = "Auto",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).Auto = 9e9
        end
    end
})

CombatTab:CreateButton({
    Name = "No Ammo Limit",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).AmmoPerMag = 1e9
        end
    end
})

CombatTab:CreateButton({
    Name = "Infiite Ammo",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            local setting = require(tool.Setting)
            setting.LimitedAmmoEnabled = false
            setting.MaxAmmo = 1e8
            setting.AmmoPerMag = 1e7
            setting.Ammo = 1e8
        end
    end
})

CombatTab:CreateButton({
    Name = "Quick Reload",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).ReloadTime = 0
        end
    end
})

CombatTab:CreateButton({
    Name = "Accuracy Buff",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Settings") then
            require(tool.Settings).Recoil = 0
        end
    end
})

CombatTab:CreateButton({
    Name = "Infinite Damage",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).BaseDamage = 9e9
        end
    end
})

CombatTab:CreateButton({
    Name = "Range Buff",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).Range = 9e9
        end
    end
})

CombatTab:CreateButton({
        Name = "No Jam",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).JamChance = 0
        end
    end
})

CombatTab:CreateButton({
    Name = "Increase Fire Rate",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).FireRate = 0
        end
    end
})

CombatTab:CreateButton({
        Name = "Quick Equip",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).EquippedAnimationSpeed = 0
        end
    end
})

CombatTab:CreateButton({
    Name = "Sniper",
    Callback = function()
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Setting") then
            require(tool.Setting).SniperEnabled = true
        end
    end
})

local Divider = MainTab:CreateDivider()

getgenv().notify = true
getgenv().highlightdestroy = true
getgenv().damage = math.huge

function checkgun()
    local tool = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    return tool
end

function getpaint(car)
    return car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
end

function DamageAllVehicles()
    local gunTool = checkgun()
    if not gunTool then
        game.StarterGui:SetCore("SendNotification", {
            Title = "MurdaX¸",
            Text = "You need to equip a gun!"
        })
        return
    end

    for _, car in ipairs(workspace:WaitForChild("CivCars"):GetChildren()) do
        if getgenv().notify then
            Rayfield:Notify({
                Title = "Damaged All Cars.",
                Content = car.Name .. " was damaged!",
                Duration = 3,
                Image = "rewind",
            })
        end

        if getgenv().highlightdestroy then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = car
            game.Debris:AddItem(highlight, 2)
        end

        local targetPart = getpaint(car)
        if targetPart then
            game:GetService("ReplicatedStorage").InflictCar:InvokeServer(
                gunTool,
                car,
                targetPart,
                getgenv().damage
            )
        end
    end
end

MainTab:CreateSection("Vehicle Mods")

MainTab:CreateButton({
    Name = "Destroy Vehicles",
    Callback = function()
        DamageAllVehicles()
    end,
})

local player = game.Players.LocalPlayer

local function unlockAllCars()
    local civCarsFolder = workspace:FindFirstChild("CivCars")
    if not civCarsFolder then
        warn("CivCars folder not found in workspace.")
        return
    end

    local unlockedCount = 0

    for _, car in ipairs(civCarsFolder:GetChildren()) do
        local driveSeat = car:FindFirstChildWhichIsA("VehicleSeat", true)
        if driveSeat then
            driveSeat.Disabled = false
            unlockedCount = unlockedCount + 1
        end
    end

    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Car Unlocker",
            Text = "MurdaX Unlocked " .. unlockedCount .. " cars!",
            Duration = 5
        })
    end)
end


MainTab:CreateButton({
    Name = "Unlock All Cars",
    Callback = function()
        unlockAllCars()
    end
})

MainTab:CreateButton({
    Name = "Steal Nearest Car",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        local function getNearestCarWithSeat()
            local civCarsFolder = workspace:FindFirstChild("CivCars")
            if not civCarsFolder then return nil end

            local closestSeat = nil
            local shortestDistance = math.huge

            for _, car in ipairs(civCarsFolder:GetChildren()) do
                local seat = car:FindFirstChildWhichIsA("VehicleSeat", true)
                if seat and seat.Occupant == nil then
                    local distance = (seat.Position - hrp.Position).Magnitude
                    if distance < shortestDistance then
                        closestSeat = seat
                        shortestDistance = distance
                    end
                end
            end

            return closestSeat
        end

        local function teleportSafely(targetCFrame)
            humanoid:ChangeState(0)
            repeat task.wait() until not player:GetAttribute("LastACPos")
            hrp.CFrame = targetCFrame
        end

        local function stealNearestCar()
            local seat = getNearestCarWithSeat()
            if seat then
                teleportSafely(seat.CFrame + Vector3.new(0, 3, 0))
            else
                warn("No available car seat found.")
            end
        end

        stealNearestCar()
    end,
})

SettingsTab:CreateSection("Servers")

SettingsTab:CreateButton({
    Name = "Hop server",
    Callback = function()
        local PlaceID = game.PlaceId
        local AllIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local Deleted = false
        local File = pcall(function()
            AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
        end)
        if not File then
            table.insert(AllIDs, actualHour)
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
        end
        function TPReturner()
            local Site
            if foundAnything == "" then
                Site = game.HttpService:JSONDecode(game:HttpGet('https://[Log in to view URL]' ..
                PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
            else
                Site = game.HttpService:JSONDecode(game:HttpGet('https://[Log in to view URL]' ..
                PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
            end
            local ID = ""
            if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                foundAnything = Site.nextPageCursor
            end
            local num = 0
            for i, v in pairs(Site.data) do
                local Possible = true
                ID = tostring(v.id)
                if tonumber(v.maxPlayers) > tonumber(v.playing) then
                    for _, Existing in pairs(AllIDs) do
                        if num ~= 0 then
                            if ID == tostring(Existing) then
                                Possible = false
                            end
                        else
                            if tonumber(actualHour) ~= tonumber(Existing) then
                                local delFile = pcall(function()
                                    delfile("NotSameServers.json")
                                    AllIDs = {}
                                    table.insert(AllIDs, actualHour)
                                end)
                            end
                        end
                        num = num + 1
                    end
                    if Possible == true then
                        table.insert(AllIDs, ID)
                        wait()
                        pcall(function()
                            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                            wait()
                            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID,
                                game.Players.LocalPlayer)
                        end)
                        wait(4)
                    end
                end
            end
        end

        function Teleport()
            while wait() do
                pcall(function()
                    TPReturner()
                    if foundAnything ~= "" then
                        TPReturner()
                    end
                end)
            end
        end

        Teleport()
    end
})

SettingsTab:CreateButton({
    Name = "Join server with lowest players",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://[Log in to view URL]"
        local _place = game.PlaceId
        local _servers = Api .. _place .. "/servers/Public?sortOrder=Asc&limit=100"
        function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor=" .. cursor) or ""))
            return Http:JSONDecode(Raw)
        end

        local Server, Next
        repeat
            local Servers = ListServers(Next)
            Server = Servers.data[1]
            Next = Servers.nextPageCursor
        until Server
        TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)
    end
})

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

SettingsTab:CreateButton({
    Name = "Join VC Server",
    Callback = function()
        TeleportService:Teleport(13453616108, player)
    end,
})

SettingsTab:CreateSection("Menu")

SettingsTab:CreateButton({
    Name = "Kill Script",
    Callback = function()
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateButton({
    Name = "Quick Leave",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        localPlayer:Kick("#1 Panic Button")
    end,
})

SettingsTab:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("https://[Log in to view URL]")
    end,
})

MainTab:CreateSection("Toggle GUI's")

local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local guiMap = {
    ["Megaphone List"] = { "Bronx MessageList", "Holder", "Visible" },
    ["Bronx Pawning"] = { "Bronx PAWNING", nil, "Enabled" },
    ["Bronx Clothing"] = { "Bronx CLOTHING", nil, "Enabled" },
    ["Animations"] = { "Animations", "Frame", "Visible" },
    ["Bronx Market"] = { "Bronx Market 2", nil, "Enabled" },
    ["Bronx Tattoos"] = { "Bronx TATTOOS", nil, "Enabled" },
    ["Crafting"] = { "CraftGUI", "Main", "Visible" },
    ["Bronx Clothing"] = { "Bronx CLOTHING", nil, "Enabled" },
    ["Trunk Storage"] = { "TRUNK STORAGE", nil, "Enabled" },
}

local options = {}
for name in pairs(guiMap) do
    table.insert(options, name)
end

local selected = {}

MainTab:CreateDropdown({
    Name            = "Select GUIs",
    CurrentOption   = {},
    MultipleOptions = true,
    Options         = options,
    Flag            = "hiih",
    Callback        = function(Value)
        selected = Value
    end
})

MainTab:CreateToggle({
    Name = "Open GUI",
    CurrentValue = false,
    Flag = "DKhi",
    Callback = function(state)
        for _, name in ipairs(selected) do
            local path = guiMap[name]
            local gui = PlayerGui:FindFirstChild(path[1])
            if gui then
                local target = path[2] and gui:FindFirstChild(path[2]) or gui
                if target then
                    target[path[3]] = state
                end
            end
        end
    end
})
