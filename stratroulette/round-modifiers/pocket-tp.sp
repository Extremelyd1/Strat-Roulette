public ConfigurePocketTP() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		}
	}

	HookEvent("weapon_fire", PocketTPWeaponFireEvent);
}

public ResetPocketTP() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}

	UnhookEvent("weapon_fire", PocketTPWeaponFireEvent);
}

public Action:PocketTPWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	char weapon[128];
	GetEventString(event, "weapon", weapon, sizeof(weapon));

	if (!StrEqual(weapon, "weapon_usp_silencer")) {
		return Plugin_Continue;
	}

	float origin[3];
	float angles[3];

	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);

	new Handle:lookTrace = TR_TraceRayFilterEx(origin, angles, MASK_PLAYERSOLID, RayType_Infinite, PlayerRayFilter, client);
	if (TR_DidHit(lookTrace)) {
		float hitLocation[3];

		TR_GetEndPosition(hitLocation, lookTrace);

		int tries = 300;
		bool success = false;

		hitLocation[2] = hitLocation[2] - 5.0;

		float mins[3];
		mins[0] = -CLIENTWIDTH / 2;
		mins[1] = -CLIENTWIDTH / 2;
		mins[2] = 0.0;

		float maxs[3];
		maxs[0] = CLIENTWIDTH / 2;
		maxs[1] = CLIENTWIDTH / 2;
		maxs[2] = CLIENTHEIGHT;

		while (!success && tries > 0) {
			hitLocation[2] = hitLocation[2] + 5.0;

			new Handle:hitboxTrace = TR_TraceHullEx(hitLocation, hitLocation, mins, maxs, MASK_PLAYERSOLID);

			if (!TR_DidHit(hitboxTrace)) {
				TeleportEntity(client, hitLocation, NULL_VECTOR, NULL_VECTOR);
				success = true;
			} else {
				tries--;
			}

			CloseHandle(hitboxTrace);
		}
	}

	CloseHandle(lookTrace);

	return Plugin_Continue;
}
