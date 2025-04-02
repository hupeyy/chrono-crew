local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPC = ReplicatedStorage:WaitForChild("NPC")
local GameBoard = workspace:WaitForChild("GameBoard")


local function spawnNPCAtCell(cellPart: Part)
    if cellPart and cellPart:IsA("BasePart") then
        local npcClone = NPC:Clone()
        npcClone.Parent = workspace
        npcClone:SetPrimaryPartCFrame(cellPart.CFrame + Vector3.new(0, 1, 0)) -- Position slightly above the cell
        -- Turn npc to the right
        local rightTurn = CFrame.Angles(0, math.rad(-90), 0) -- 90 degrees to the right
        npcClone:SetPrimaryPartCFrame(npcClone.PrimaryPart.CFrame * rightTurn)
    end
end

spawnNPCAtCell(GameBoard:FindFirstChild("Cell_1_2")) -- Example: spawn at Cell_1_1
