public ConfigureInvisible() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_SetTransmit, InvisibleSetTransmitHook);
		}
	}
}

public ResetInvisible() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_SetTransmit, InvisibleSetTransmitHook);
		}
	}
}

public Action:InvisibleSetTransmitHook(int entity, int client) {
	if (entity != client) {
		if (IsClientInGame(entity)) {
			if (!IsPlayerAlive(client)) {
				if (GetClientTeam(entity) != GetClientTeam(client)) {
					return Plugin_Handled;
				}
			} else {
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
