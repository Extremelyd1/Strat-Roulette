public ConfigureNoC4() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			new c4Slot = GetPlayerWeaponSlot(client, 4);
			if (c4Slot != -1) {
				char className[128];
				GetEdictClassname(c4Slot, className, sizeof(className));

				if (StrEqual(className, "weapon_c4")) {
					RemovePlayerItem(client, c4Slot);
					RemoveEdict(c4Slot);
				}
			}
		}
	}
}

public ResetNoC4() {

}
