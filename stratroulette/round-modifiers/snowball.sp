Handle snowballTimer;

public ConfigureSnowball() {
	SetConVarInt(mp_death_drop_gun, 0, true, false);
	SetConVarInt(mp_death_drop_grenade, 0, true, false);

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			GivePlayerItem(i, "weapon_snowball");
		}
	}

	snowballTimer = CreateTimer(0.5, CheckSnowballTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetSnowball() {
	SetConVarInt(mp_death_drop_gun, 1, true, false);
	SetConVarInt(mp_death_drop_grenade, 1, true, false);

	SafeKillTimer(snowballTimer);
}

public Action:CheckSnowballTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			char weaponName[128];
			Client_GetActiveWeaponName(i, weaponName, sizeof(weaponName));

			if (StrEqual(weaponName, "weapon_knife")) {
				SetEntPropFloat(i, Prop_Data, "m_flNextAttack", GetGameTime() + 2.0);
			}
		}
	}

	return Plugin_Continue;
}
