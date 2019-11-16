new switcherooPrimary[MAXPLAYERS + 1];

public ConfigureSwitcheroo() {
	SetConVarInt(mp_death_drop_gun, 0, true, false);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			switcherooPrimary[client] = true;

			int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

			SetClipAmmo(primary, 1);
			SetReserveAmmo(primary, 0);

			int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

			SetClipAmmo(secondary, 0);
			SetReserveAmmo(secondary, 0);
		}
	}

	HookEvent("weapon_fire", SwitcherooWeaponFireEvent);

	AddCommandListener(DenyDropListener, "drop");
}

public ResetSwitcheroo() {
	SetConVarInt(mp_death_drop_gun, 1, true, false);

	UnhookEvent("weapon_fire", SwitcherooWeaponFireEvent);

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:SwitcherooWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (switcherooPrimary[client]) {
		switcherooPrimary[client] = false;

		int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

		SetClipAmmo(secondary, 1);
	} else {
		switcherooPrimary[client] = true;

		int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

		SetClipAmmo(primary, 1);
	}
}
