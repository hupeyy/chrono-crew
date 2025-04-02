-- Server Script (in ServerScriptService)
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- Create a RemoteEvent for cell clicks
local cellClickEvent = Instance.new("RemoteEvent")
cellClickEvent.Name = "CellClickEvent"
cellClickEvent.Parent = ReplicatedStorage

local function createBoard(rows, cols, cellSize)
    local board = Instance.new("Model")
    board.Name = "GameBoard"
    board.Parent = Workspace

    for row = 1, rows do
        for col = 1, cols do
            local cell = Instance.new("Part")
            cell.Size = Vector3.new(cellSize, .5, cellSize)
            cell.Position = Vector3.new((col - 1) * cellSize, .5, (row - 1) * cellSize)
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

    return board
end

-- Spawn point creation
local function createSpawnPoint(board: Model, cellSize: number)
    local spawnPoint = Instance.new("SpawnLocation")
    spawnPoint.Size = Vector3.new(cellSize, 1, cellSize)
    spawnPoint.Position = board:WaitForChild("Cell_1_1").Position + Vector3.new(0, 2, 0) -- Adjust Y position as needed
    spawnPoint.Anchored = true
    spawnPoint.Transparency = 1 -- Make it invisible
    spawnPoint.CanCollide = false -- Prevent collisions
    spawnPoint.Parent = board
    spawnPoint.CFrame = CFrame.new(spawnPoint.Position) * CFrame.Angles(0, math.rad(-90), 0) -- Rotate spawn point
    spawnPoint.Name = "SpawnPoint"
end

-- Lobby entry point creation
local function createLobbyEntryPoint(board: Model, rows: number, cols: number, cellSize: number)
    local lobbyEntry = Instance.new("Part")
    lobbyEntry.Size = Vector3.new(2, .5, 4)
    lobbyEntry.Position = board:GetPivot().Position + Vector3.new(-1 * cols, 0, 0) -- Adjust Y position as needed
    lobbyEntry.Anchored = true
    lobbyEntry.Material = Enum.Material.SmoothPlastic
    lobbyEntry.BrickColor = BrickColor.new("Bright red")
    lobbyEntry.Parent = board
    lobbyEntry.Name = "LobbyEntryPoint"

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

-- Create the environment
local gameBoard = createBoard(rows, cols, cellSize)
local spawnPoint = createSpawnPoint(gameBoard, cellSize)
local lobbyEntryPoint = createLobbyEntryPoint(gameBoard, rows, cols, cellSize)

-- Set attributes for the game board
gameBoard.Parent = Workspace
gameBoard:SetAttribute("Rows", rows)
gameBoard:SetAttribute("Cols", cols)
gameBoard:SetAttribute("CellSize", cellSize)
print("Game board created with " .. rows .. " rows and " .. cols .. " columns.")