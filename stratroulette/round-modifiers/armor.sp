int armorInt = 0;

public ConfigureArmor(char armor[500]) {
	if (!StrEqual(armor, "0")) {
		armorInt = StringToInt(armor);
	}
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (!StrEqual(armor, "0")) {
				Client_SetArmor(client, armorInt);
			}
		}
	}
}

public ResetArmor() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			Client_SetArmor(client, 0);
		}
	}

	armorInt = 0;
}
