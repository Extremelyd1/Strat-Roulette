public ConfigureHeadshotOnly() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, HeadshotOnlyOnTakeDamageHook);
		}
	}
}

public ResetHeadshotOnly() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, HeadshotOnlyOnTakeDamageHook);
		}
	}
}

public Action:HeadshotOnlyOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (damagetype == DMG_FALL
		|| damagetype == DMG_GENERIC
		|| damagetype == DMG_CRUSH
		|| damagetype == DMG_SLASH
		|| damagetype == DMG_BURN
		|| damagetype == DMG_VEHICLE
		|| damagetype == DMG_FALL
		|| damagetype == DMG_BLAST
		|| damagetype == DMG_SHOCK
		|| damagetype == DMG_SONIC
		|| damagetype == DMG_ENERGYBEAM
		|| damagetype == DMG_DROWN
		|| damagetype == DMG_PARALYZE
		|| damagetype == DMG_NERVEGAS
		|| damagetype == DMG_POISON
		|| damagetype == DMG_ACID
		|| damagetype == DMG_AIRBOAT
		|| damagetype == DMG_PLASMA
		|| damagetype == DMG_RADIATION
		|| damagetype == DMG_SLOWBURN
		|| attacker == 0
	) {
		return Plugin_Continue;
	}
	if (!(damagetype & CS_DMG_HEADSHOT)) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
