Handle axeTimer;

public ConfigureAxe() {
	axeTimer = CreateTimer(1.0, CheckAxeTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetAxe() {
	SafeKillTimer(axeTimer);
}

public Action:CheckAxeTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			new meleeSlot = GetPlayerWeaponSlot(i, 2);

			if (meleeSlot < 0) {
				new axe = GivePlayerItem(i, "weapon_axe");
				EquipPlayerWeapon(i, axe);
			}
		}
	}

	return Plugin_Continue;
}
