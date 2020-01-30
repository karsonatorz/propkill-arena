local function CalculateProbability(rating1, rating2)
	return 1.0 * 1.0 / (1 + 1.0 * math.pow(10, 1.0 * (rating1 - rating2) / 1200))
end

function CalculateEloRating(winner, loser, K)
	Pb = CalculateProbability(winner, loser)
	Pa = CalculateProbability(loser, winner)

	winner = winner + K * (1 - Pa)
	loser = loser + K * (0 - Pb)
	difference = K * (1 - Pa)
	return math.Round(winner, 0), math.Round(loser, 0), math.Round(difference, 0)
end

hook.Add("PlayerDeath", "PK_ELO", function(ply, inflictor, attacker)
	if attacker:IsPlayer() and ply != attacker then
		local K = 30
		attNewElo, deadNewElo, diff = CalculateEloRating(attacker:GetNWInt("Elo"), ply:GetNWInt("Elo"), K)
		PK.API:ChangeInt(attacker, "Elo", diff)
		PK.API:ChangeInt(ply, "Elo", -diff)

		attacker:SetNWInt("Elo", attNewElo)
		ply:SetNWInt("Elo", deadNewElo)

		ply:ChatPrint("-" .. diff .. " ELO")
		attacker:ChatPrint("+" .. diff .. " ELO")
		attacker.Elo = attNewElo
		ply.Elo = deadNewElo
	end
end)

/*
//hook.Remove("PlayerDeath", "PK_ELO")

Ra = 1200
Rb = 1000
K = 30
d = 1
CalculateEloRating(Ra, Rb, K, d)
*/
