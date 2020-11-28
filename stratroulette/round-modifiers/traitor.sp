public ConfigureTraitor() {
	/* char playerModel[128];
	bool playerModelChosen = false; */

	int numberOfPlayers = 0;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			/* if (playerModelChosen) {
				GetClientModel(client, playerModel, sizeof(playerModel));
				playerModelChosen = true;
			} else {
			} */

			SetEntityModel(client, DEFAULT_CHARACTER_MODEL);

			SetEntProp(client, Prop_Send, "m_iHideHUD", 1<<8 | 1<<12);

			numberOfPlayers++;
		}
	}

	for (int i = 0; i < numberOfPlayers / 2; i++) {
		int ctPlayer = GetRandomPlayerFromTeam(CS_TEAM_CT);
		int tPlayer = GetRandomPlayerFromTeam(CS_TEAM_T);

		float ctPos[3];
		GetEntPropVector(ctPlayer, Prop_Send, "m_vecOrigin", ctPos);

		float tPos[3];
		GetEntPropVector(tPlayer, Prop_Send, "m_vecOrigin", tPos);

		TeleportEntity(ctPlayer, tPos, NULL_VECTOR, NULL_VECTOR);
		TeleportEntity(tPlayer, ctPos, NULL_VECTOR, NULL_VECTOR);
	}
}

public ResetTraitor() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			SetEntProp(client, Prop_Send, "m_iHideHUD", 2050);
		}
	}
}
