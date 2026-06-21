local t = {
	["https://api.luarmor.net/files/v3/loaders/6e48c8f146554686e916b4f3a6f4bb39.lua"] = {
		3846592040,
		3104101863,
		1785526629,
		4383934650,
		847722000,
		3772683742,
		4730278139,
		4987467534
	},
}

for loader, value in t do
	for _, val in value do
		if val == game.GameId then
			print("[Loader] Game is supported. Loading script!")
			loadstring(game:HttpGet(loader))()
			return
		end
	end
end

game:GetService("Players").LocalPlayer:Kick("This game is NOT supported by Codexus Hub!")