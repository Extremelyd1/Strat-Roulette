new firePlayers[MAXPLAYERS + 1];

Handle fireTimer;

public ConfigureFire() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, FireOnTakeDamageHook);
			firePlayers[client] = false;
		}
	}

	fireTimer = CreateTimer(1.0, FireUpdateTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetFire() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, FireOnTakeDamageHook);
		}
	}

	SafeKillTimer(fireTimer);
}

public Action:FireOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker)) {
		return Plugin_Continue;
	}

	if (GetClientTeam(victim) == GetClientTeam(attacker)) {
		firePlayers[victim] = false;
	} else {
		firePlayers[victim] = true;
	}

	return Plugin_Handled;
}

public Action:FireUpdateTimer(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (firePlayers[client]) {
				IgniteEntity(client, 1.0);
			}
		}
	}
}
