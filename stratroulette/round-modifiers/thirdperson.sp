public ConfigureThirdPerson() {
	SetConVarInt(sv_allow_thirdperson, 1, true, false);
	CreateTimer(0.1, EnableThirdPerson);
}

public ResetThirdPerson() {
	SetConVarInt(sv_allow_thirdperson, 0, true, false);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client)) {
			ClientCommand(client, "firstperson");
		}
	}
}

public Action:EnableThirdPerson(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			ClientCommand(i, "thirdperson");
		}
	}
}
