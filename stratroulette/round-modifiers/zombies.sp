public ConfigureZombies() {
	SetConVarInt(mp_death_drop_gun, 0, true, false);
	SetConVarInt(mp_death_drop_defuser, 0, true, false);
	SetConVarInt(mp_death_drop_grenade, 0, true, false);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				SetEntityHealth(client, 100);
			} else {
				RemoveWeaponsClient(client);
			}
		}
	}

	AddCommandListener(DenyDropListener, "drop");
}

public ResetZombies() {
	SetConVarInt(mp_death_drop_gun, 1, true, false);
	SetConVarInt(mp_death_drop_defuser, 1, true, false);
	SetConVarInt(mp_death_drop_grenade, 1, true, false);

	RemoveCommandListener(DenyDropListener, "drop");
}
