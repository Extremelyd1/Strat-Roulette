new toBeConfirmedPlayers[MAXPLAYERS + 1];

public ConfigureKillConfirmed() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamageAlive, KillConfirmedPlayerOnTakeDamageHook);
			toBeConfirmedPlayers[client] = false;
		}
	}
}

public ResetKillConfirmed() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, KillConfirmedPlayerOnTakeDamageHook);
			SetEntityRenderColor(client, 255, 255, 255, 0);
		}
	}
}

public Action:KillConfirmedPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	int victimHealth = GetClientHealth(victim);

	bool knifeAttack = false;

	new weapon = GetEntPropEnt(inflictor, Prop_Data, "m_hActiveWeapon");
	if (weapon > 0) {
		char className[128];
		GetEdictClassname(weapon, className, sizeof(className));
		if (StrEqual(className, "weapon_knife")) {
			knifeAttack = true;
		}
	}

	if (toBeConfirmedPlayers[victim]) {
		if (!knifeAttack) {
			return Plugin_Handled;
		}

		// Victim is to be confirmed and was hit with knife
		if (GetClientTeam(victim) == GetClientTeam(inflictor)) {
			// Hit by teammate, thus respawning
			toBeConfirmedPlayers[victim] = false;

			// Give player weapon again
			GivePlayerItem(victim, secondaryWeapon);

			// Give armor if enabled
			if (armorInt != 0) {
				Client_SetArmor(victim, armorInt);
			}

			// Give helmet if enabled
			if (helmetEnabled) {
				SetEntData(victim, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 1);
			}

			// Set health
			SetEntityHealth(victim, health);

			// Give knife
			SetKnifeClient(victim, true);

			SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SetEntityRenderColor(victim, 255, 255, 255, 0);

			return Plugin_Handled;
		} else {
			// Hit be opposite team, thus eliminating
			SetEntityRenderColor(victim, 255, 255, 255, 0);
			return Plugin_Continue;
		}
	}

	// Not a to be confirmed player
	if (damage > victimHealth) {
		toBeConfirmedPlayers[victim] = true;

		int team = GetClientTeam(victim);

		bool wiped = true;
		for (int client = 1; client <= MaxClients; client++) {
			if (IsClientInGame(client) && IsPlayerAlive(client)) {
				if (GetClientTeam(client) == team && !toBeConfirmedPlayers[client]) {
					wiped = false;
				}
			}
		}

		if (wiped) {
			for (int client = 1; client <= MaxClients; client++) {
				if (IsClientInGame(client) && IsPlayerAlive(client) && client != victim) {
					if (GetClientTeam(client) == team) {
						SDKUnhook(client, SDKHook_OnTakeDamageAlive, KillConfirmedPlayerOnTakeDamageHook);
						SDKHooks_TakeDamage(client, attacker, attacker, GetTrueDamage(client, float(health)), DMG_GENERIC);
					}
				}
			}

			return Plugin_Continue;
		}

		SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.0);
		SetEntityHealth(victim, 1);
		SetEntityRenderColor(victim, 255, 0, 0, 0);
		RemoveWeaponsClient(victim, true, true);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}
