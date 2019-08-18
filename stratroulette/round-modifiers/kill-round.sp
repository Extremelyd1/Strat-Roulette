bool killRoundActive = false;

public ConfigureKillRound() {
	killRoundActive = true;

	SetConVarInt(mp_ignore_round_win_conditions, 1, true, false);

	HookEvent("player_death", KillRoundPlayerDeathEvent, EventHookMode_Pre);
}

public ResetKillRound() {
	SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);

	killRoundActive = false;
}

public Action:KillRoundPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	if (IsWiped()) {
		SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
	}
}
