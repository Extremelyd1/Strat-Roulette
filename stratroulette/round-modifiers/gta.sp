#define GTA_MAX_DIST 300.0

bool gtaActive = false;

new gtaViewEntities[MAXPLAYERS + 1];

public ConfigureGTA() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			float position[3];
			GetClientEyePosition(client, position);

			float clientAngles[3];
			GetClientEyeAngles(client, clientAngles);

			// Create view entity
			int entity = CreateViewEntity();

			position[2] += 100;

			TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);

			float angle[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angle);

			angle[0] = 90.0;

			TeleportEntity(entity, NULL_VECTOR, angle, NULL_VECTOR);

			SetClientViewEntity(client, entity);

			gtaViewEntities[client] = entity;

			SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		}
	}

	HookEvent("player_death", GTAPlayerDeathEvent, EventHookMode_Pre);

	CreateTimer(1.0, GTATimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	gtaActive = true;
}

public ResetGTA() {
	gtaActive = false;

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			// Reset view
			SetClientViewEntity(i, i);
			SetEntProp(i, Prop_Send, "m_iObserverMode", 0);
		}
	}

	UnhookEvent("player_death", GTAPlayerDeathEvent, EventHookMode_Pre);
}

public Action:GTAPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	gtaViewEntities[client] = -1;
	SetClientViewEntity(client, client);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
}

public Action:GTAOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!gtaActive || !IsPlayerAlive(client) || IsFakeClient(client)) {
		return Plugin_Continue;
	}

	// Get entity that belongs to player
	new entity = gtaViewEntities[client];
	if (entity > 0) {
		if (IsValidEntity(entity)) {
			float position[3];
			GetClientEyePosition(client, position);

			float upAngles[3];
			upAngles[0] = -90.0;
			upAngles[1] = 0.0;
			upAngles[2] = 0.0;

			new Handle:lookTrace = TR_TraceRayFilterEx(position, upAngles, MASK_PLAYERSOLID, RayType_Infinite, PlayerRayFilter, client);
			if (TR_DidHit(lookTrace)) {
				float hitLocation[3];

				TR_GetEndPosition(hitLocation, lookTrace);

				float yDiff = hitLocation[2] - position[2] - 20.0;

				if (yDiff > GTA_MAX_DIST) {
					yDiff = GTA_MAX_DIST;
				}

				position[2] += yDiff;
			} else {
				position[2] += GTA_MAX_DIST;
			}

			CloseHandle(lookTrace);

			float viewEntityAngle[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", viewEntityAngle);

			viewEntityAngle[1] = angles[1];

			TeleportEntity(entity, position, viewEntityAngle, NULL_VECTOR);
		}
	}

	return Plugin_Continue;
}

public Action:GTATimer(Handle timer) {
	if (!gtaActive) {
		return Plugin_Stop;
	}

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			float angles[3];
			GetClientEyeAngles(i, angles);

			angles[0] = 0.0;

			TeleportEntity(i, NULL_VECTOR, angles, NULL_VECTOR);
		}
	}

	return Plugin_Continue;
}
