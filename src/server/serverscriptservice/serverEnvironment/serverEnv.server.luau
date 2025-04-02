local function createServerSpawn()
    local spawn = Instance.new("SpawnLocation")
    local spawnSize = 4
    local spawnHeight = 0.5
    spawn.Size = Vector3.new(spawnSize, spawnHeight, spawnSize)
    spawn.Position = Vector3.new(-16, 0, -10)
    spawn.Anchored = true
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.CFrame = spawn.CFrame * CFrame.Angles(0, math.rad(180), 0) 
    spawn.BrickColor = BrickColor.new("Bright blue")
    spawn.Name = "ServerSpawn"
    spawn.Parent = workspace
end

local serverSpawn = createServerSpawn()