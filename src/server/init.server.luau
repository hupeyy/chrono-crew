local players = game:GetService("Players")
local ServerSpawn = workspace:WaitForChild("ServerSpawn")

-- Set up each players spawn point to be server spawn
for _, player in ipairs(players:GetPlayers()) do
    player.RespawnLocation = ServerSpawn
end