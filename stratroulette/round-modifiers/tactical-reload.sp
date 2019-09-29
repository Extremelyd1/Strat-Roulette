bool tacticalReloadActive = false;

public ConfigureTacticalReload() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (weapon > 0) {
				SetReserveAmmo(weapon, 0);
			}
		}
	}

	AddCommandListener(TacticalDropListener, "drop");

	tacticalReloadActive = true;
}

public ResetTacticalReload() {
	RemoveCommandListener(TacticalDropListener, "drop");

	tacticalReloadActive = false;
}

public Action:TacticalDropListener(int client, const char[] command, int args) {
	CreateTimer(1.0, TacticalReloadGiveWeapon, client);

	return Plugin_Continue;
}

public Action:TacticalReloadGiveWeapon(Handle timer, int client) {
	if (tacticalReloadActive) {
		int weapon = GivePlayerItem(client, primaryWeapon);

		CreateTimer(0.1, TacticalReloadReserveAmmo, weapon);
	}
}

public Action:TacticalReloadReserveAmmo(Handle timer, int weapon) {
	if (tacticalReloadActive) {
		SetReserveAmmo(weapon, 0);
	}
}
