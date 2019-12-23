new wallbangAllowHit[MAXPLAYERS + 1];

public ConfigureWallbang() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, WallbangPlayerOnTakeDamageHook);
			wallbangAllowHit[client] = 0;
		}
	}

	HookEvent("weapon_fire", WallbangWeaponFireEvent, EventHookMode_Pre);
}

public ResetWallbang() {
	UnhookEvent("weapon_fire", WallbangWeaponFireEvent, EventHookMode_Pre);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, WallbangPlayerOnTakeDamageHook);
		}
	}
}

public Action:WallbangPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (attacker < 1 || attacker > MaxClients || !IsClientInGame(attacker)) {
		return Plugin_Continue;
	}

	if (wallbangAllowHit[attacker] > 0) {
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

public Action:WallbangWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	float position[3];
	GetClientEyePosition(client, position);

	float angle[3];
	GetClientEyeAngles(client, angle);

	new Handle:lookTrace = TR_TraceRayFilterEx(position, angle, MASK_PLAYERSOLID, RayType_Infinite, PlayerRayFilter, client);
	if (TR_DidHit(lookTrace)) {
		// Ray trace hit something, now check whether it was a client
		int entity = TR_GetEntityIndex(lookTrace);
		if (entity < 1 || entity > MaxClients || !IsClientInGame(entity)) {
			// No client entity was hit, so wall hit first
			// Allow a bullet to register
			wallbangAllowHit[client] += 1;

			// Reset as soon as the bullet calculation is done
			// 0.1 is unfortunately the fastests a timer can be
			CreateTimer(0.1, WallbangDisallowHitTimer, client);
		}
	}
}

public Action:WallbangDisallowHitTimer(Handle timer, int client) {
	if (wallbangAllowHit[client] > 0) {
		wallbangAllowHit[client] -= 1;
	}
}
