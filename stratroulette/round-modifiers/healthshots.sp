Handle healthshotTimer;

public ConfigureHealthshots() {
	healthshotTimer = CreateTimer(3.0, CheckHealthshotsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	AddCommandListener(DenyDropListener, "drop");
}

public ResetHealthshots() {
	SafeKillTimer(healthshotTimer);

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:CheckHealthshotsTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			new healthshot = GetPlayerWeaponSlot(i, 11);

			if (healthshot < 0) {
				GivePlayerItem(i, "weapon_healthshot");
			}
		}
	}

	return Plugin_Continue;
}
