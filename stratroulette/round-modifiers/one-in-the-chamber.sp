public ConfigureOneInTheChamber() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (primary > 0) {
				SetClipAmmo(primary, 1);
				SetReserveAmmo(primary, 0);
			}

			int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			if (secondary > 0) {
				SetClipAmmo(secondary, 1);
				SetReserveAmmo(secondary, 0);
			}
		}
	}

	HookEvent("player_death", OneInTheChamberPlayerDeathEvent);
}

public ResetOneInTheChamber() {
	UnhookEvent("player_death", OneInTheChamberPlayerDeathEvent);
}

public Action:OneInTheChamberPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	char weapon[128];
	GetEventString(event, "weapon", weapon, sizeof(weapon), "none");

	if (IsClientInGame(killer) && IsPlayerAlive(killer)) {
		if (StrContains(weapon, "knife") == -1) {
			// Not killed with knife
			SetActiveWeaponClipAmmo(killer, GetActiveWeaponClipAmmo(killer) + 1);
		} else {
			// Killed with knife, find weapon to award ammo
			int weaponInSlot = GetPlayerWeaponSlot(killer, CS_SLOT_PRIMARY);
			if (weaponInSlot <= 0) {
				// Primary does not exist, pick secondary
				weaponInSlot = GetPlayerWeaponSlot(killer, CS_SLOT_SECONDARY);
				if (weaponInSlot <= 0) {
					// No primary, nor secondary, can't award ammo
					return Plugin_Continue;
				}
			}
			SetClipAmmo(weaponInSlot, GetClipAmmo(weaponInSlot) + 1);
		}
	}

	return Plugin_Continue;
}
