int health = 100;

public ConfigureHealth(char healthValue[500]) {
	health = StringToInt(healthValue);
	if (health != 100) {
		for (int client = 1; client <= MaxClients; client++) {
			if (IsClientInGame(client) && IsPlayerAlive(client)) {
				SetEntityHealth(client, health);
			}
		}
	}
}

public ResetHealth() {
	health = 100;
}
