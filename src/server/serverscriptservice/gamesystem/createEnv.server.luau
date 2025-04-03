-- Server Script (in ServerScriptService)
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- Create a RemoteEvent for cell clicks
local cellClickEvent = Instance.new("RemoteEvent")
cellClickEvent.Name = "CellClickEvent"
cellClickEvent.Parent = ReplicatedStorage

local function createBoard(i: number, rows: number, cols: number, cellSize: number, cellHeight: number, offsetX: number, offsetZ: number, rotation: number)
    local board = Instance.new("Model")
    board.Name = string.format("GameBoard_%d", i)
    board.Parent = Workspace

    -- Calculate the center position of the board
    local centerX = offsetX + (cols * cellSize) / 2 - cellSize / 2
    local centerZ = offsetZ + (rows * cellSize) / 2 - cellSize / 2
    local centerY = cellHeight / 2
    
    -- Create a CFrame with the desired rotation
    local boardCFrame = CFrame.new(centerX, centerY, centerZ) * CFrame.Angles(0, math.rad(rotation), 0)

    for row = 1, rows do
        for col = 1, cols do
            local cell = Instance.new("Part")
            cell.Size = Vector3.new(cellSize, cellHeight, cellSize)
            
            -- Calculate the local position relative to the board's center
            local localX = (col - 1) * cellSize - (cols * cellSize) / 2 + cellSize / 2
            local localZ = (row - 1) * cellSize - (rows * cellSize) / 2 + cellSize / 2
            local localPos = Vector3.new(localX, 0, localZ)
            
            -- Transform the local position using the board's CFrame
            local worldPos = boardCFrame * localPos
            cell.Position = worldPos
            
            -- Set the cell's orientation to match the board
            cell.CFrame = CFrame.new(worldPos) * CFrame.Angles(0, math.rad(rotation), 0)
            
            cell.Anchored = true
            cell.Material = Enum.Material.SmoothPlastic
            cell.Parent = board
            
            if (row + col) % 2 == 0 then
                cell.BrickColor = BrickColor.White()
            else
                cell.BrickColor = BrickColor.Black()
            end

            local cellName = string.format("Cell_%d_%d", col, row)
            cell.Name = cellName
            
            -- Store grid coordinates as attributes
            cell:SetAttribute("GridRow", row)
            cell:SetAttribute("GridCol", col)
            
            -- Add ClickDetector
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.MaxActivationDistance = 100 -- Increase click distance
            clickDetector.Parent = cell
        end
    end

    -- Store the board's CFrame as an attribute for later reference
    board:SetAttribute("BoardCFrame", boardCFrame)

    return board
end


-- Spawn point creation
local function createUserSpawnPoint(board: Model, cellSize: number, row: number, col: number)
    local spawnPoint = Instance.new("SpawnLocation")
    spawnPoint.Size = Vector3.new(cellSize, 1, cellSize)
    spawnPoint.Position = board:WaitForChild("Cell_" .. row .. "_" .. col).Position + Vector3.new(0, 2, 0)
    spawnPoint.Anchored = true
    spawnPoint.Transparency = 1 -- Make it invisible
    spawnPoint.CanCollide = false -- Prevent collisions
    spawnPoint.CFrame = CFrame.new(spawnPoint.Position) * CFrame.Angles(0, math.rad(-90), 0) -- Rotate spawn point
    spawnPoint.Enabled = false
    spawnPoint.Name = "SpawnPoint"
    spawnPoint.Parent = board
end

-- Lobby entry point creation
local function createLobbyEntryPoint(board: Model, rows: number, cols: number, cellSize: number, height: number)
    local lobbyEntry = Instance.new("Part")
    local cellHeight = .5
    local length = 4
    local width = 2
    lobbyEntry.Size = Vector3.new(width, height, length)
    
    -- Get the board's CFrame
    local boardCFrame = board:GetAttribute("BoardCFrame")
    
    -- Find the first row's center position
    local firstRowCenterCol = (cols + 1) / 2
    local firstRowCell = board:FindFirstChild("Cell_" .. math.floor(firstRowCenterCol) .. "_1")
    
    if firstRowCell then
        -- Position the lobby entry point next to the first row
        -- Calculate the position in local board space
        local localX = -1 * (cols * cellSize / 2) - (width / 2) -- Position it outside the board
        local localZ = 0 -- Center it along the Z axis of the board
        local localY = height / 2 - cellHeight / 2 -- Position it at the right height
        
        -- Transform to world space using the board's CFrame
        lobbyEntry.CFrame = boardCFrame * CFrame.new(localX, localY, localZ)
    else
        -- Fallback if cell not found
        lobbyEntry.Position = board:GetPivot().Position + Vector3.new(-1 * (cols * cellSize / 2 + 3), height/2, 0)
    end
    
    lobbyEntry.Anchored = true
    lobbyEntry.Material = Enum.Material.SmoothPlastic
    lobbyEntry.BrickColor = BrickColor.new("Bright red")
    lobbyEntry.Name = "LobbyEntryPoint"
    lobbyEntry.Parent = board
end



-- Handle cell clicks from clients
cellClickEvent.OnServerEvent:Connect(function(player, cellPart)
    if cellPart and cellPart:IsA("BasePart") and cellPart.Parent.Name == "GameBoard" then
        local row = cellPart:GetAttribute("GridRow")
        local col = cellPart:GetAttribute("GridCol")
        local worldPos = cellPart.Position + Vector3.new(0, 1, 0) -- Position slightly above the cell
        
        print(player.Name .. " clicked on " .. cellPart.Name .. " at grid position: " .. row .. "," .. col)
        
        -- Here you can add code to move NPCs, trigger game events, etc.
        local npc = workspace:FindFirstChild("NPC")
        if npc and npc:FindFirstChild("Humanoid") then
            npc.Humanoid:MoveTo(worldPos)
        end
    end
end)

-- Create the grid when the script runs
local rows = 8 -- Number of rows
local cols = 8 -- Number of columns
local cellSize = 4 -- Size of each cell
local cellHeight = .5 -- Height of each cell

for i = 1, 6 do
    -- Create 3 boards
    local spacingX = 2
    local spacingZ = 20
    local offsetX = 0 -- No offset in X direction
    local offsetZ = (i - 1) * (cols * cellSize + spacingZ) -- Offset for each board
    local rotation = 0 -- No rotation


    if i > 3 then
        offsetZ = (i - 4) * (cols * cellSize + spacingZ) -- Offset for the second set of boards
        offsetX = -spacingX * rows * cellSize -- Offset in X direction for the second set of boards
        rotation = 180 -- Rotate the second set of boards
    end

    local board = createBoard(i, rows, cols, cellSize, cellHeight, offsetX, offsetZ, rotation)
    createUserSpawnPoint(board, cellSize, 1, 1) -- Spawn point at (1, 1)
    createLobbyEntryPoint(board, rows, cols, cellSize, cellHeight) -- Lobby entry point
end