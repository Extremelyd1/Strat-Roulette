Handle bumpmineTimer;

public ConfigureBumpmine() {
	bumpmineTimer = CreateTimer(1.0, CheckBumpmineTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetBumpmine() {
	SafeKillTimer(bumpmineTimer);
}

public Action:CheckBumpmineTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			new mineSlot = GetPlayerWeaponSlot(i, 4);

			if (mineSlot < 0) {
				new mine = GivePlayerItem(i, "weapon_bumpmine");
				EquipPlayerWeapon(i, mine);
			}

			float playerAbsVelocity[3];
			Entity_GetAbsVelocity(i, playerAbsVelocity);

			if (playerAbsVelocity[0] > 500 || playerAbsVelocity[1] > 500 || playerAbsVelocity[2] > 500) {
				SDKHooks_TakeDamage(i, i, i, GetTrueDamage(i, 25.0), DMG_GENERIC);
			}
		}
	}

	return Plugin_Continue;
}
