for i, v in pairs(game.workspace.Bases:GetDescendants()) do 
    if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part")) then
        v.Transparency = 0.65
    end
end
