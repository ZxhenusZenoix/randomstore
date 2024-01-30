local Player = game.Players.LocalPlayer
local Character = Player.Character
local HRM = Character.HumanoidRootPart
local Humanoid = Character.Humanoid

local function safeEquipTool(tool:Tool, waitForEquip:boolean?):Tool
	HRM.Anchored = true
	while tool.Parent ~= Character do
		for _,v in tool:GetDescendants() do
			if v:IsA("BasePart") then
				v.Anchored = false
				v.CFrame = HRM.CFrame
			end
		end
		Humanoid:EquipTool(tool)
		if not waitForEquip then break end
		task.wait()
	end
	HRM.Anchored = false
	return tool
end

for _, v in workspace:GetDescendants() do
	if not v:IsA("Tool") then continue end
	if v.Name == "Glider" or v:FindFirstChild("Glove") then continue end
	
	safeEquipTool(v)
	v.Equipped:Connect(function()
		Humanoid:UnequipTools()
		safeEquipTool(v)
	end)
end
Humanoid:UnequipTools()

task.wait(1)
-- blow up ze bus and use perma
local permaTruePower = true
local usePermaItems = true
local useAllCubes = true
local bombBus = true
local autoHealOnLowHP = true
local lowHP = 30
local safeHP = 70

if true then
	if autoHealOnLowHP then
		Humanoid.HealthChanged:Connect(function()
			if Humanoid.Health > lowHP then return end

			for _, v in Player.Backpack:GetChildren() do
				if v.Name == "Apple" or v.Name == "Bandage" or v.Name == "First Aid Kit" or v.Name == "Healing Potion" or v.Name == "Healing Brew" or v.Name == "Boba" or v.Name == "Forcefield Crystal" then
					safeEquipTool(v):Activate()
					if Humanoid.Health >= safeHP then
						break
					end
					task.wait(0.1)
				end
			end
		end)
	end
	
	for _, v in Player.Backpack:GetChildren() do
		if not bombBus then break end
		if v.Name == "Bomb" then
			safeEquipTool(v, true):Activate()
		end
	end

	local truePowers = {}
	if permaTruePower then
		for _,v in Player.Backpack:GetChildren() do
			if v.Name == "True Power" then
				if #truePowers == 1 then
					safeEquipTool(v, true):Activate()
					safeEquipTool(truePowers[1], true):Activate()
					task.wait(5.5)
					break
				end
				table.insert(truePowers, v)
			end
		end
	end

	for _, v in Player.Backpack:GetChildren() do
		if v.Name == "Glider" or v:FindFirstChild("Glove") then continue end
		if usePermaItems and (v.Name == "Bull's essence" or v.Name == "Potion of Strength" or v.Name == "Boba" or v.Name == "Speed Potion" or v.Name == "Frog Potion" or v.Name == "Strength Brew" or v.Name == "Frog Brew" or v.Name == "Speed Brew") or useAllCubes and v.Name == "Cube of Ice" then
			safeEquipTool(v, true):Activate()
		end
	end
end

task.wait(3)
Humanoid.Landed:Wait()

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHRM = LocalCharacter:WaitForChild("HumanoidRootPart")
local LocalHum = LocalCharacter:WaitForChild("Humanoid")

local function characterSanity(char, checkCanHit:boolean?):boolean
	if LocalHum.Health <= 0 or not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") or not char:FindFirstChild("Humanoid") or char:FindFirstChild("Dead") then 
		return false
	end
	if char.Humanoid.Health <= 0 or char.HumanoidRootPart.Position.Y < -120 or char.HumanoidRootPart.Position.Y > 600 or char.HumanoidRootPart.Position.Magnitude > 3000 or char.Head.Transparency > 0 or not char.inMatch.Value then 
		return false
	end

	if checkCanHit and (char.Ragdolled.Value or not char.Vulnerable.Value) then
		return false
	end

	return true
end

LocalHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
LocalHum.Seated:Connect(function(a)
	if not a then return end
	LocalHum:ChangeState(Enum.HumanoidStateType.Jumping)
	LocalHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

for _, v in LocalPlayer.Backpack:GetChildren() do
	if v:FindFirstChild("Glove") then
		task.spawn(function()
			while task.wait() do
				for _,v1 in v:GetDescendants() do
					if not v1:IsA("BasePart") then continue end
					v1.CFrame = LocalHRM.CFrame
				end
			end
		end)
		break
	end
end

for _, v in workspace.Map.AcidAbnormality:GetChildren() do
	if v.Name == "Acid" and v.ClassName ~= "Model" and not v:FindFirstChild("Model") then
		v.CanTouch = false
	end
end
workspace.Map.DragonDepths.Lava.CanTouch = false
workspace.Map.OriginOffice.Antiaccess.CanTouch = false
workspace.Map.AntiUnderMap:ClearAllChildren()

local players = {}
local function updplr()
	players = Players:GetPlayers()
	table.sort(players, function(a, b)
		return (a.Character and b.Character and a.Character:FindFirstChild("HumanoidRootPart") and b.Character:FindFirstChild("HumanoidRootPart") and (LocalHRM.Position-a.Character.HumanoidRootPart.Position).Magnitude < (LocalHRM.Position-b.Character.HumanoidRootPart.Position).Magnitude) or false
	end)
end

task.spawn(function()
	while task.wait() do
		for _, plr in ipairs(players) do
			if characterSanity(plr.Character) and (plr.Character.HumanoidRootPart.Position-LocalHRM.Position).Magnitude < 30 then 
				game.ReplicatedStorage.Events.Slap:FireServer(plr.Character.HumanoidRootPart)
			end
		end
	end
end)

local studsPerSecond = 420
while task.wait() and LocalHum.Health > 0 do
	updplr()
	for _, plr in ipairs(players) do
		if plr == LocalPlayer or not characterSanity(plr.Character, true) then continue end

		local distance = ((plr.Character.HumanoidRootPart.Position-LocalHRM.Position)).Magnitude
		if distance > 2000 then continue end

		local moveToStart = os.clock()
		local mTTick = os.clock()
		
		while characterSanity(plr.Character, true) and os.clock()-moveToStart < 10 do
			distance = ((plr.Character.HumanoidRootPart.Position-LocalHRM.Position)).Magnitude
			LocalHRM.CFrame = LocalHRM.CFrame:lerp(plr.Character.HumanoidRootPart.CFrame - Vector3.new(0,3,0), (moveToStart/os.clock() / distance*studsPerSecond) * (os.clock()-mTTick))
			LocalHRM.AssemblyLinearVelocity = Vector3.zero

			mTTick = os.clock()
			task.wait()
		end

		updplr()
	end
end
