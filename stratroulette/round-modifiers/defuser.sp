bool defuserEnabled = false;

public ConfigureDefuser() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT) {
			SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
		}
	}

	defuserEnabled = true;
}

public ResetDefuser() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT) {
			SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
		}
	}

	defuserEnabled = false;
}
