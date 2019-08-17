bool zeusOITCActive = false;

public ConfigureZeusOITC() {
	HookEvent("player_death", ZeusOITCPlayerDeathEvent);

	zeusOITCActive = true;
}

public ResetZeusOITC() {
	zeusOITCActive = false;

	UnhookEvent("player_death", ZeusOITCPlayerDeathEvent);
}

public Action:ZeusOITCPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (IsClientInGame(killer) && !IsFakeClient(killer) && IsPlayerAlive(killer)) {
		CreateTimer(1.2, AwardZeusTimer, killer);
	}
}

public Action:AwardZeusTimer(Handle timer, int client) {
	if (zeusOITCActive) {
		GivePlayerItem(client, "weapon_taser");
	}

	return Plugin_Continue;
}
