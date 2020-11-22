bool screenCheatActive = false;

new screenCheatEntities[MAXPLAYERS + 1];

new screenCheating[MAXPLAYERS + 1];

new screenCheatEntityMap[MAXPLAYERS + 1];

public ConfigureScreenCheat() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			int entity = CreateViewEntity();
			screenCheatEntities[client] = entity;
			screenCheating[client] = false;

			SDKHook(client, SDKHook_SetTransmit, ScreenCheatSetTransmitHook);
		}
	}

	AddCommandListener(ScreenCheatLookAtWeaponListener, "+lookatweapon");

	screenCheatActive = true;
}

public ResetScreenCheat() {
	screenCheatActive = false;

	RemoveCommandListener(ScreenCheatLookAtWeaponListener, "+lookatweapon");

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			// Reset view
			SetClientViewEntity(i, i);

			SDKUnhook(i, SDKHook_SetTransmit, ScreenCheatSetTransmitHook);
		}
	}
}

public Action:ScreenCheatSetTransmitHook(int entity, int client) {
	if (screenCheating[client]) {
		// If the view entity belonging to this entity is the same as
		// the entity the client we are sending to is viewing
		// prevent sending it
		if (screenCheatEntities[entity] == screenCheatEntityMap[client]) {
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:ScreenCheatLookAtWeaponListener(int client, const char[] command, int args) {
	if (IsWiped()) {
		return Plugin_Continue;
	}

	if (screenCheating[client]) {
		SetClientViewEntity(client, client);
		screenCheating[client] = false;
		return Plugin_Stop;
	}

	int clientTeam = GetClientTeam(client);

	int randomEnemy = -1;

	if (clientTeam == CS_TEAM_CT) {
		randomEnemy = GetRandomPlayerFromTeam(CS_TEAM_T);
	} else {
		randomEnemy = GetRandomPlayerFromTeam(CS_TEAM_CT);
	}

	if (randomEnemy == -1 || !IsClientInGame(randomEnemy) || !IsPlayerAlive(randomEnemy)) {
		return Plugin_Continue;
	}

	SetClientViewEntity(client, screenCheatEntities[randomEnemy]);

	screenCheatEntityMap[client] = screenCheatEntities[randomEnemy];

	screenCheating[client] = true;

	return Plugin_Stop;
}

public Action:ScreenCheatOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!screenCheatActive || !IsPlayerAlive(client)) {
		return Plugin_Continue;
	}

	new entity = screenCheatEntities[client];
	if (entity != -1) {
		if (IsValidEntity(entity)) {
			float position[3];
			GetClientEyePosition(client, position);

			float eyeAngles[3];
			GetClientEyeAngles(client, eyeAngles);

			TeleportEntity(entity, position, eyeAngles, NULL_VECTOR);
		}
	}

	return Plugin_Continue;
}
