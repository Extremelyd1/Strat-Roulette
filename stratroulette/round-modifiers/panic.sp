public ConfigurePanic() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, PanicOnTakeDamageHook);
		}
	}
}

public ResetPanic() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, PanicOnTakeDamageHook);
		}
	}
}

public Action:PanicOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	new ent = GetPlayerWeaponSlot(victim, 0);
	if (ent >= 0) {
		CS_DropWeapon(victim, ent, true, true);
	}
}
