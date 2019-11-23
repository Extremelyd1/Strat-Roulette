bool enderpearlActive = false;

new enderpearlClient[MAXPLAYERS + 1];

public ConfigureEnderpearl() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			enderpearlClient[client] = 0;
		}
	}

	HookEvent("decoy_started", EnderpearlDecoyStartedEvent);

	enderpearlActive = true;
}

public ResetEnderpearl() {
	enderpearlActive = false;

	UnhookEvent("decoy_started", EnderpearlDecoyStartedEvent);
}

public EnderpearlOnEntitySpawn(int entity, const String:className[]) {
	if (enderpearlActive) {
		if (StrContains(className, "_projectile") != -1) {
			SDKHook(entity, SDKHook_SpawnPost, EnderpearlSpawnHook);
		}
	}
}

public EnderpearlSpawnHook(entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	enderpearlClient[client] = entity;
	/* CreateTimer(0.1, EnderpearlTeleportTimer, entity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE); */
}

public Action:EnderpearlOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!enderpearlActive) {
		return Plugin_Continue;
	}

	int entity = enderpearlClient[client];

	if (!IsValidEntity(entity) || entity < 1) {
		return Plugin_Continue;
	}

	float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);

	float absVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", absVelocity);

	TeleportEntity(client, position, NULL_VECTOR, absVelocity);

	return Plugin_Continue;
}

/* public Action:EnderpearlTeleportTimer(Handle timer, int entity) {
	if (!enderpearlActive) {
		return Plugin_Stop;
	}

	if (!IsValidEntity(entity) || entity < 1) {
		return Plugin_Stop;
	}

	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);

	float absVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", absVelocity);

	TeleportEntity(client, position, NULL_VECTOR, absVelocity);

	return Plugin_Continue;
} */

public Action:EnderpearlDecoyStartedEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "entityid");
	if (IsValidEntity(entity)) {
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		float position[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);

		position[2] -= 10.0;

		FitPlayerUp(client, position, 1.0, 1000);

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		enderpearlClient[client] = 0;
		RemoveEntity(entity);

		GivePlayerItem(client, "weapon_decoy");
	}
}
