bool dropWeaponsActive = false;

Handle dropWeaponsTimer[MAXPLAYERS + 1];

public ConfigureDropWeapons() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			dropWeaponsTimer[client] = INVALID_HANDLE;

			CreateNewDropWeaponsTimer(client);
		}
	}

	dropWeaponsActive = true;
}

public ResetDropWeapons() {
	dropWeaponsActive = false;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SafeKillTimer(dropWeaponsTimer[client]);
		}
	}
}

public CreateNewDropWeaponsTimer(client) {
	float randomFloat = GetRandomFloat(3.0, 6.0);
	dropWeaponsTimer[client] = CreateTimer(randomFloat, DropWeaponsTimer, client);
}

public Action:DropWeaponsTimer(Handle timer, int client) {
	if (!dropWeaponsActive || client == -1 || !IsPlayerAlive(client)) {
		dropWeaponsTimer[client] = INVALID_HANDLE;

		return Plugin_Stop;
	}

	new currentWeapon = GetPlayerWeaponSlot(client, 1);

	if (currentWeapon != -1) {
		CS_DropWeapon(client, currentWeapon, true, true);
	}

	CreateNewDropWeaponsTimer(client);

	return Plugin_Stop;
}
