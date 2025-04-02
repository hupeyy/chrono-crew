local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local cellClickEvent = ReplicatedStorage:WaitForChild("CellClickEvent")

-- Function to set up click detection for all cells
local function setupClickDetection()
    local gameBoard = workspace:WaitForChild("GameBoard")
    
    -- Set up camera to view the board
    local function setupCamera()
        local camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable
        
        local gameBoard = workspace:WaitForChild("GameBoard")
        local rows = gameBoard:GetAttribute("Rows") or 8
        local cols = gameBoard:GetAttribute("Columns") or 8
        local gridSize = gameBoard:GetAttribute("GridSize") or 4
        
        -- Calculate the center position of the board
        local centerX = (cols - 1) * gridSize / 2
        local centerZ = (rows - 1) * gridSize / 2 
        local boardCenter = Vector3.new(centerX, 0, centerZ)
        
        -- Calculate the board's total size
        local boardSize = math.max(rows, cols) * gridSize
        
        -- Calculate the appropriate distance based on board size and FOV
        local distance = 100 -- Starting distance
        local fov = 2 * math.atan((boardSize / 2) / distance)
        camera.FieldOfView = math.deg(fov)
        
        -- Position the camera above the board center
        local cameraPosition = boardCenter + Vector3.new(0, distance, 0)
        camera.CFrame = CFrame.new(cameraPosition, boardCenter)
        camera.Focus = CFrame.new(boardCenter)
        
        print("Camera positioned at center of board:", boardCenter)
        print("Using FOV:", camera.FieldOfView)
    end

    
    setupCamera()
    
    -- Connect to ClickDetector events for all cells
    for _, cell in pairs(gameBoard:GetChildren()) do
        if cell:IsA("BasePart") then
            local clickDetector = cell:FindFirstChild("ClickDetector")
            if clickDetector then
                clickDetector.MouseClick:Connect(function()
                    -- Highlight the clicked cell
                    local originalColor = cell.Color
                    cell.Color = Color3.fromRGB(100, 200, 255) -- Blue highlight
                    
                    -- Fire the remote event to the server
                    cellClickEvent:FireServer(cell)
                    
                    -- Reset the color after a short delay
                    task.delay(0.5, function()
                        cell.Color = originalColor
                    end)
                end)
                
                -- Add hover effect
                clickDetector.MouseHoverEnter:Connect(function()
                    cell.Transparency = 0.5 -- Make it semi-transparent on hover
                end)
                
                clickDetector.MouseHoverLeave:Connect(function()
                    cell.Transparency = 0
                end)
            end
        end
    end
end

-- Set up click detection when the character is added
player.CharacterAdded:Connect(setupClickDetection)

-- If the character already exists, set up click detection now
if player.Character then
    setupClickDetection()
end
