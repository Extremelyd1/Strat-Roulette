int winnerTeam = CS_TEAM_CT;

public ConfigureWinner(char winnerString[500]) {
	if (StrEqual(winnerString, "t")) {
		winnerTeam = CS_TEAM_T;
		SetConVarInt(mp_default_team_winner_no_objective, 2, true, false);
	} else if (StrEqual(winnerString, "draw")) {
		winnerTeam = -1;
		SetConVarInt(mp_default_team_winner_no_objective, 1, true, false);
	}
}

public ResetWinner() {
	SetConVarInt(mp_default_team_winner_no_objective, -1, true, false);

	winnerTeam = CS_TEAM_CT;
}
