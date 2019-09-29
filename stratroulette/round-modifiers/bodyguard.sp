int ctBodyguard;
char ctBodyguardName[128];

int tBodyguard;
char tBodyguardName[128];

public ConfigureBodyguard() {
	SetBodyguard(CS_TEAM_CT);
	SetBodyguard(CS_TEAM_T);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (client != ctBodyguard && client != tBodyguard) {
				GivePlayerItem(client, "weapon_shield");
				SDKHook(client, SDKHook_OnTakeDamage, BodyguardPlayerOnTakeDamageHook);
			} else {
				GivePlayerItem(client, "weapon_fiveseven");
			}
		}
	}

	HookEvent("player_death", BodyguardPlayerDeathEvent);

	AddCommandListener(DenyDropListener, "drop");
}

public ResetBodyguard() {
	UnhookEvent("player_death", BodyguardPlayerDeathEvent);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			if (client != ctBodyguard && client != tBodyguard) {
				SDKUnhook(client, SDKHook_OnTakeDamage, BodyguardPlayerOnTakeDamageHook);
			}
		}
	}

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:BodyguardPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (victim != ctBodyguard && victim != tBodyguard) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:BodyguardPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (client == ctBodyguard || client == tBodyguard) {
		int teamToWipe = GetClientTeam(client);

		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == teamToWipe) {
				SDKHooks_TakeDamage(i, killer, killer, GetTrueDamage(i, float(health)), DMG_GENERIC);
			}
		}
	}
}

public SetBodyguard(team) {
	if (team == CS_TEAM_CT) {
		ctBodyguard = GetRandomPlayerFromTeam(team);
		GetClientName(ctBodyguard, ctBodyguardName, sizeof(ctBodyguardName));
	} else {
		tBodyguard = GetRandomPlayerFromTeam(team);
		GetClientName(tBodyguard, tBodyguardName, sizeof(tBodyguardName));
	}
}
