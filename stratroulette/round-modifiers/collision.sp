public ConfigureCollision(char collisionType[500]) {
	if (StrEqual(collisionType, "team")) {
		SetConVarInt(mp_solid_teammates, 0, true, false);
	} else if (StrEqual(collisionType, "none")) {
		for (int client = 1; client <= MaxClients; client++) {
			if (IsClientInGame(client) && IsPlayerAlive(client)) {
				SetEntData(client, g_offsCollisionGroup, 2, 4, true);
			}
		}
	}
}

public ResetCollision() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntData(client, g_offsCollisionGroup, 5, 4, true);
		}
	}

	SetConVarInt(mp_solid_teammates, 1, true, false);
}
