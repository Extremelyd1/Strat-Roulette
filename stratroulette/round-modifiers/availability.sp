bool availabilityActive = false;

new availabilityPlayers[MAXPLAYERS + 1];
Handle availabilityTimer[MAXPLAYERS + 1];

public ConfigureAvailability() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			availabilityPlayers[client] = false;
			availabilityTimer[client] = INVALID_HANDLE;

			SetEntityRenderColor(client, 255, 255, 255, 120);

			SDKHook(client, SDKHook_OnTakeDamage, AvailabilityOnTakeDamageHook);

			CreateNewAvailabilityTimer(client);
		}
	}

	availabilityActive = true;
}

public ResetAvailability() {
	availabilityActive = false;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SetEntityRenderColor(client, 255, 255, 255, 255);

			SDKUnhook(client, SDKHook_OnTakeDamage, AvailabilityOnTakeDamageHook);

			SafeKillTimer(availabilityTimer[client]);
		}
	}
}

public Action:AvailabilityOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (availabilityPlayers[victim]) {
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

public CreateNewAvailabilityTimer(client) {
	float randomFloat;

	if (availabilityPlayers[client]) {
		randomFloat = GetRandomFloat(4.0, 6.0);
	} else {
		randomFloat = GetRandomFloat(6.0, 10.0);
	}
	availabilityTimer[client] = CreateTimer(randomFloat, AvailabilityTimer, client);
}

public Action:AvailabilityTimer(Handle timer, int client) {
	if (!availabilityActive || client == -1 || !IsPlayerAlive(client)) {
		availabilityTimer[client] = INVALID_HANDLE;

		return Plugin_Stop;
	}

	if (availabilityPlayers[client]) {
		SetEntityRenderColor(client, 255, 255, 255, 120);
	} else {
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}

	availabilityPlayers[client] = !availabilityPlayers[client];

	CreateNewAvailabilityTimer(client);

	return Plugin_Stop;
}
