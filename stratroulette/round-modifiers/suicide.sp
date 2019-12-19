bool suicideActive = false;

public ConfigureSuicide() {
	SetConVarInt(mp_friendlyfire, 0, true, false);
	SetConVarInt(mp_ignore_round_win_conditions, 1, true, false);

	HookEvent("player_death", SuicidePlayerDeathEvent, EventHookMode_Pre);

	AddCommandListener(DenyDropListener, "kill");
	AddCommandListener(DenyDropListener, "explode");

	suicideActive = true;
}

public ResetSuicide() {
	suicideActive = false;

	SetConVarInt(mp_friendlyfire, 1, true, false);
	SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
	SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
	SetConVarInt(mp_respawn_on_death_t, 0, true, false);

	RemoveCommandListener(DenyDropListener, "kill");
	RemoveCommandListener(DenyDropListener, "explode");

	UnhookEvent("player_death", SuicidePlayerDeathEvent, EventHookMode_Pre);
}

public Action:SuicidePlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!suicideActive) {
		return Plugin_Continue;
	}

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	int clientTeam = GetClientTeam(client);

	if (IsWiped(client)) {
		suicideActive = false;

		if (clientTeam == CS_TEAM_CT) {
			SetConVarInt(mp_respawn_on_death_ct, 1, true, false);
		} else if (clientTeam == CS_TEAM_T) {
			SetConVarInt(mp_respawn_on_death_t, 1, true, false);
		}
		SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);

		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && IsPlayerAlive(i)) {
				if (GetClientTeam(i) != clientTeam) {
					SDKHooks_TakeDamage(i, client, client, GetTrueDamage(i, float(health)), DMG_GENERIC);
				}
			}
		}
	}

	return Plugin_Continue;
}
