public ConfigureVampire() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, VampireOnTakeDamageHook);
		}
	}
}

public ResetVampire() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, VampireOnTakeDamageHook);
		}
	}
}

public Action:VampireOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (attacker == 0) {
		return Plugin_Continue;
	}

	new attackerHealth = GetEntProp(attacker, Prop_Send, "m_iHealth");
	if (IsClientInGame(attacker) && IsPlayerAlive(attacker)) {
		if (GetClientTeam(victim) == GetClientTeam(attacker)) {
			new giveHealth = RoundToNearest(attackerHealth + damage / 4);
			SetEntityHealth(attacker, giveHealth);
		} else {
			new giveHealth = RoundToNearest(attackerHealth + damage);
			SetEntityHealth(attacker, giveHealth);
		}
	}

	return Plugin_Continue;
}
