public ConfigureHitSwap() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, HitSwapOnTakeDamageHook);
		}
	}
}

public ResetHitSwap() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, HitSwapOnTakeDamageHook);
		}
	}
}

public Action:HitSwapOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (attacker != victim && victim != 0 && attacker != 0) {
		float victimPos[3];
		GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
		float attackerPos[3];
		GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPos);

		TeleportEntity(victim, attackerPos, NULL_VECTOR, NULL_VECTOR);
		TeleportEntity(attacker, victimPos, NULL_VECTOR, NULL_VECTOR);
	}
}
