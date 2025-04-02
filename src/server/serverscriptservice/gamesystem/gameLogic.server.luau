local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bot = Workspace:WaitForChild("NPC")
local humanoid = bot:WaitForChild("Humanoid")
local rootPart = humanoid.RootPart

local grid = Workspace:WaitForChild("GameBoard")
local cellSize = grid:GetAttribute("CellSize") or 4


local gridClickEvent = ReplicatedStorage:WaitForChild("GridClickEvent")

function moveToGridPosition(position: Vector3)
    local gridPosition = Vector3.new(
        math.floor(position.X / cellSize + 0.5) * cellSize, -- Added +0.5 for proper rounding
        position.Y,
        math.floor(position.Z / cellSize + 0.5) * cellSize  -- Added +0.5 for proper rounding
    )
    return gridPosition
end

function walkPath(path: {Vector3})
    for _, point in ipairs(path) do
        local targetPosition = moveToGridPosition(point)
        
        -- For debugging
        -- print("Moving to grid position: " .. tostring(targetPosition))
        
        -- Create a proximity check
        local proximityThreshold = cellSize * 0.1 -- 10% of grid size
        local reachedDestination = false
        
        -- Use both MoveTo and MoveToFinished for more reliable movement
        local connection = humanoid.MoveToFinished:Connect(
            function(reached)
                if reached then
                    reachedDestination = true
                end
            end
        )
        
        humanoid:MoveTo(targetPosition)
        
        -- Wait for either proximity or MoveToFinished
        repeat 
            task.wait()
            -- Check if we're close enough to the target
            local distance = (rootPart.Position - targetPosition).Magnitude
            if distance < proximityThreshold then
                reachedDestination = true
                -- Force position correction for precise grid alignment
                rootPart.CFrame = CFrame.new(targetPosition.X, rootPart.Position.Y, targetPosition.Z)
            end
        until reachedDestination or not bot:IsDescendantOf(workspace)
        
        connection:Disconnect()
        
        -- For debugging
        -- print("Reached position: " .. tostring(rootPart.Position))

        task.wait(0.5) -- Optional delay between moves
    end
    return true
end

gridClickEvent.OnServerEvent:Connect(function(player, worldPos, gridRow, gridCol)
    -- For debugging
    -- print("Received grid click event from player: " .. player.Name)
    -- print("World position: " .. tostring(worldPos) .. ", Grid coordinates: (" .. gridRow .. ", " .. gridCol .. ")")
    
    -- Move the bot to the clicked position
    local path = {worldPos}
    local success = walkPath(path)

    if success then
        -- For debugging
        print("Bot successfully moved to grid position: " .. tostring(worldPos))
    else
        -- For debugging
        print("Failed to move bot to grid position: " .. tostring(worldPos))
    end
end)

print("Grid movement script loaded and listening successfully.")
