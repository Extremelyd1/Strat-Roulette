public ConfigureNightVision() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntProp(client, Prop_Send, "m_bNightVisionOn", 1);
		}
	}
}

public ResetNightVision() {
}
