Handle hardcoreTimer;

public ConfigureHardcore() {
	int freezeTime = GetConVarInt(mp_freezetime);
	hardcoreTimer = CreateTimer(freezeTime - 1.0, StartHardcore);
}

public ResetHardcore() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			SetEntProp(client, Prop_Send, "m_iHideHUD", 2050);
		}
	}

	SafeKillTimer(hardcoreTimer);
}

public Action:StartHardcore(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			SetEntProp(client, Prop_Send, "m_iHideHUD", 1<<2);

			// Make sure that the player is not holding the C4,
			// otherwise they can't switch to their gun anymore
			char weaponname[128];
			Client_GetActiveWeaponName(client, weaponname, sizeof(weaponname));

			if (StrEqual(weaponname, "weapon_c4")) {
				new primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
				SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", primary);
				ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
			}
		}
	}
}
