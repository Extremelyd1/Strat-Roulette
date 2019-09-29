Handle breachTimer;

public ConfigureBreach() {
	breachTimer = CreateTimer(1.0, CheckBreachTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetBreach() {
	SafeKillTimer(breachTimer);
}

public Action:CheckBreachTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			new breachSlot = GetPlayerWeaponSlot(i, 4);

			if (breachSlot < 0) {
				new breach = GivePlayerItem(i, "weapon_breachcharge");
				EquipPlayerWeapon(i, breach);
			}
		}
	}

	return Plugin_Continue;
}
