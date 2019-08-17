public ConfigureNoFallDamage() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, NoFallDamagePlayerOnTakeDamageHook);
		}
	}
}

public ResetNoFallDamage() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, NoFallDamagePlayerOnTakeDamageHook);
		}
	}
}

public Action:NoFallDamagePlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (damagetype == DMG_FALL) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
