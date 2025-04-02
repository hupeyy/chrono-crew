local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPC = ReplicatedStorage:WaitForChild("NPC")


local function spawnNPCAtCell(board: Model, row: number, col: number)
    local cellName = string.format("Cell_%d_%d", col, row)
    local cellPart = board:FindFirstChild(cellName)
    if cellPart and cellPart:IsA("BasePart") then
        local npcClone = NPC:Clone()
        npcClone.Parent = board 
        npcClone:SetPrimaryPartCFrame(cellPart.CFrame + Vector3.new(0, 1, 0)) -- Position slightly above the cell
        -- Turn npc to the right
        local rightTurn = CFrame.Angles(0, math.rad(-90), 0) -- 90 degrees to the right
        npcClone:SetPrimaryPartCFrame(npcClone.PrimaryPart.CFrame * rightTurn)
    end
end



