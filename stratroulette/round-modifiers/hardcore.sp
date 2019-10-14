Handle hardcoreTimer;

public ConfigureHardcore() {
	int freezeTime = GetConVarInt(mp_freezetime);
	hardcoreTimer = CreateTimer(freezeTime - 1.0, StartHardcore);
}

public ResetHardcore() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			Client_SetHideHud(client, 2050);
		}
	}

	SafeKillTimer(hardcoreTimer);
}

public Action:StartHardcore(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			Client_SetHideHud(client, HIDEHUD_ALL);

			// Make sure that the player is not holding the C4,
			// otherwise they can't switch to their gun anymore
			char weaponname[128];
			Client_GetActiveWeaponName(client, weaponname, sizeof(weaponname));

			if (StrEqual(weaponname, "weapon_c4")) {
				Client_ChangeToLastWeapon(client);
			}
		}
	}
}
