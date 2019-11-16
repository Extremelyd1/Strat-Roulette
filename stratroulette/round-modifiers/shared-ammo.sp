ArrayList allowWeaponReload;

public ConfigureSharedAmmo() {
	allowWeaponReload = new ArrayList();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (weapon < 1) {
				weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			}

			SDKHook(weapon, SDKHook_Reload, SharedAmmoOnWeaponReloadHook);
		}
	}

	HookEvent("weapon_fire", SharedAmmoWeaponFireEvent, EventHookMode_Pre);
}

public ResetSharedAmmo() {
	UnhookEvent("weapon_fire", SharedAmmoWeaponFireEvent, EventHookMode_Pre);

	delete allowWeaponReload;
}

public Action:SharedAmmoWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

	if (weapon == primary || weapon == secondary) {
		int ammoBefore = GetClipAmmo(weapon);

		if (ammoBefore > 0) {
			int clientTeam = GetClientTeam(client);

			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == clientTeam && client != i) {
					int weaponToSetAmmo;
					if (weapon == primary) {
						weaponToSetAmmo = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
					} else if (weapon == secondary) {
						weaponToSetAmmo = GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY);
					}
					SetClipAmmo(weaponToSetAmmo, ammoBefore - 1);
				}
			}
		}
	}
}

public Action:SharedAmmoOnWeaponReloadHook(int weapon) {
	int value = allowWeaponReload.FindValue(weapon);
	if (value != -1) {
		allowWeaponReload.Erase(value);

		return Plugin_Continue;
	}

	int client;

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			int primary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
			int secondary = GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY);
			if (weapon == primary || weapon == secondary) {
				client = i;
				break;
			}
		}
	}

	int clientTeam = GetClientTeam(client);

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == clientTeam && client != i) {
			new clientWeapon = GetEntPropEnt(i, Prop_Data, "m_hActiveWeapon");
			allowWeaponReload.Push(clientWeapon);
			SDKReload(clientWeapon);
		}
	}

	return Plugin_Continue;
}
