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

		FitPlayerUp(client, hitLocation, 3.0, 500);
	}

	CloseHandle(lookTrace);

	return Plugin_Continue;
}
