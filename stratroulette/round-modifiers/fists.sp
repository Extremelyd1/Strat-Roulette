Handle fistsTimer;

public ConfigureFists() {
	fistsTimer = CreateTimer(1.0, CheckFistsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetFists() {
	SafeKillTimer(fistsTimer);
}

public Action:CheckFistsTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			new meleeSlot = GetPlayerWeaponSlot(i, 2);

			if (meleeSlot < 0) {
				new fists = GivePlayerItem(i, "weapon_fists");
				EquipPlayerWeapon(i, fists);
			}
		}
	}

	return Plugin_Continue;
}
