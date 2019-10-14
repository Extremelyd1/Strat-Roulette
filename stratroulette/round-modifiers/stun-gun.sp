new isStunned[MAXPLAYERS + 1];

bool stunGunActive = false;

public ConfigureStunGun() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamageAlive, StunGunPlayerOnTakeDamageHook);
			isStunned[client] = false;
		}
	}

	stunGunActive = true;
}

public ResetStunGun() {
	stunGunActive = false;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, StunGunPlayerOnTakeDamageHook);
		}
	}
}

public Action:StunGunPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	new weapon = GetEntPropEnt(inflictor, Prop_Data, "m_hActiveWeapon");
	if (weapon > 0) {
		char className[128];
		GetEdictClassname(weapon, className, sizeof(className));
		if (!StrEqual(className, "weapon_usp_silencer") && !StrEqual(className, "weapon_hkp2000")) {
			return Plugin_Continue;
		}
	}
	// Weapon is silenced usp

	// Don't allow team stunning, nor damaging with usp
	if (GetClientTeam(victim) == GetClientTeam(inflictor)) {
		return Plugin_Handled;
	}

	if (!isStunned[victim]) {
		SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.0);
		RemoveWeaponsClient(victim);
		isStunned[victim] = true;
		CreateTimer(2.0, StunGunResetPlayer, victim);
	}

	return Plugin_Handled;
}

public Action:StunGunResetPlayer(Handle timer, int client) {
	if (stunGunActive) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		GivePlayerItem(client, primaryWeapon);
		GivePlayerItem(client, "weapon_usp_silencer");

		// Give player some extra recovery time before being able to get stunned again
		CreateTimer(1.0, StunGunResetStunned, client);
	}

	return Plugin_Stop;
}

public Action:StunGunResetStunned(Handle timer, int client) {
	if (stunGunActive) {
		isStunned[client] = false;
	}

	return Plugin_Stop;
}
