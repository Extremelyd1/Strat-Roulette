bool helmetEnabled = false;

public ConfigureHelmet() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 1);
		}
	}

	helmetEnabled = true;
}

public ResetHelmet() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 0);
		}
	}

	helmetEnabled = false;
}
