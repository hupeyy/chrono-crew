local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("Player Name: " .. player.Name)

-- Wait for the RemoteEvent
local gridClickEvent = ReplicatedStorage:WaitForChild("GridClickEvent")

-- Function to create the grid GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GridGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Grid dimensions are 8x8
    local gridSize = 8
    local cellSize = 50
    local cellPadding = 2

    local gridWidth = cellSize * gridSize + cellPadding * (gridSize - 1)
    local gridHeight = gridWidth

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, gridWidth, 0, gridHeight)
    frame.Position = UDim2.new(0.5, -gridWidth / 2, 0.5, -gridHeight / 2)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

    -- Create UIGridLayout
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, cellSize, 0, cellSize)
    gridLayout.CellPadding = UDim2.new(0, cellPadding, 0, cellPadding)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = frame

    -- Create a grid of cells
    local cells = {}
    for row = 1, gridSize do
        cells[row] = {}
        for col = 1, gridSize do
            local cell = Instance.new("TextButton")
            cell.Name = "Cell_" .. row .. "_" .. col
            cell.Parent = frame
            cell.Text = ""
            cell.BackgroundColor3 = (row + col) % 2 == 0 
                and Color3.fromRGB(200, 200, 200)
                or Color3.fromRGB(150, 150, 150)
            cell.BorderSizePixel = 0
            
            -- Invert the row order to make bottom left the origin
            -- This makes row 1 at the bottom and row 8 at the top
            local invertedRow = gridSize - row + 1
            cell.LayoutOrder = (invertedRow - 1) * gridSize + col
            
            -- Store grid coordinates as attributes
            -- We store the original row (not inverted) for world position calculation
            cell:SetAttribute("GridRow", row)
            cell:SetAttribute("GridCol", col)
            
            -- Add hover effect
            local hoverEffect = Instance.new("UIStroke")
            hoverEffect.Thickness = 3
            hoverEffect.Color = Color3.fromRGB(255, 255, 0)
            hoverEffect.Transparency = 1
            hoverEffect.Parent = cell
            
            -- Add hover effect
            cell.MouseEnter:Connect(function()
                hoverEffect.Transparency = 0
            end)
            
            cell.MouseLeave:Connect(function()
                hoverEffect.Transparency = 1
            end)
            
            -- Handle click
            cell.MouseButton1Click:Connect(function()
                local gridRow = cell:GetAttribute("GridRow")
                local gridCol = cell:GetAttribute("GridCol")
                
                -- Convert GUI grid position to game world position
                local gameBoard = workspace:FindFirstChild("game_board")
                if gameBoard then
                    local GRID_SIZE = gameBoard:GetChildren()[1].Size.X
                    local worldPos = Vector3.new(
                        (gridRow- 1) * GRID_SIZE,
                        0,
                        (gridCol- 1) * GRID_SIZE
                    )
                    
                    -- Highlight the selected cell
                    highlightCell(cells, row, col)
                    
                    -- Fire the RemoteEvent to the server
                    gridClickEvent:FireServer(worldPos, gridRow, gridCol)
                end
            end)
            
            cells[row][col] = cell
        end
    end
    
    -- Add a toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 100, 0, 30)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.Text = "Toggle Grid"
    toggleButton.Parent = screenGui
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    toggleButton.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
    
    return cells
end

-- Function to highlight a selected cell
function highlightCell(cells, row, col)
    -- Clear previous highlights
    for r = 1, #cells do
        for c = 1, #cells[r] do
            cells[r][c].BackgroundColor3 = (r + c) % 2 == 0 
                and Color3.fromRGB(200, 200, 200) 
                or Color3.fromRGB(150, 150, 150)
        end
    end
    
    -- Highlight the selected cell
    cells[row][col].BackgroundColor3 = Color3.fromRGB(100, 200, 255)
end

-- Create the GUI when the character is added
player.CharacterAdded:Connect(function()
    createGUI()
end)

-- If the character already exists, create the GUI now
if player.Character then
    createGUI()
end
