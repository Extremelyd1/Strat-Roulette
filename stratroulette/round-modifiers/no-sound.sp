public ConfigureNoSound() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			// Absurdly long timer to account for long round times
			FadeClientVolume(client, 100.0, 0.0, 10000.0, 0.0);
		}
	}
}

public ResetNoSound() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			FadeClientVolume(client, 100.0, 0.0, 0.0, 0.0);
		}
	}
}
