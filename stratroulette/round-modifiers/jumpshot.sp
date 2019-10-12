bool jumpshotActive = false;

new jumpshotState[MAXPLAYERS + 1];
new lastClipAmmo[MAXPLAYERS + 1];
new lastReserveAmmo[MAXPLAYERS + 1];
new beforeReloadAmmo[MAXPLAYERS + 1];

public ConfigureJumpshot() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			jumpshotState[client] = 1;
			lastClipAmmo[client] = -1;
			lastReserveAmmo[client] = -1;

			int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (primary > 0) {
				SDKHook(primary, SDKHook_ReloadPost, JumpshotReloadPostHook);
			}

			int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			if (secondary > 0) {
				SDKHook(secondary, SDKHook_ReloadPost, JumpshotReloadPostHook);
			}
		}
	}

	jumpshotActive = true;
}

public ResetJumpshot() {
	jumpshotActive = false;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			jumpshotState[client] = 1;
			lastClipAmmo[client] = -1;
			lastReserveAmmo[client] = -1;
		}
	}
}

public void JumpshotOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!jumpshotActive) {
		return;
	}

	int lastJumpshotState = jumpshotState[client];
	int clientInAir = GetEntityFlags(client) & FL_ONGROUND;

	// Client was in the air, now is not in the air
	if (lastJumpshotState == 1 && clientInAir) {
		new weaponInSlot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		if (weaponInSlot < 1) {
			weaponInSlot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			if (weaponInSlot < 1) {
				return;
			}
		}

		lastClipAmmo[client] = GetClipAmmo(weaponInSlot);
		lastReserveAmmo[client] = GetReserveAmmo(weaponInSlot);

		SetClipAmmo(weaponInSlot, 0);
		SetReserveAmmo(weaponInSlot, 0);
	} else if (lastJumpshotState == 0 && !clientInAir) {
		// Client was on the ground, now is in the air
		new weaponInSlot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		if (weaponInSlot < 1) {
			weaponInSlot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			if (weaponInSlot < 1) {
				return;
			}
		}

		SetClipAmmo(weaponInSlot, lastClipAmmo[client]);
		SetReserveAmmo(weaponInSlot, lastReserveAmmo[client]);
	}

	if (GetEntityFlags(client) & FL_ONGROUND) {
		jumpshotState[client] = 0;
	} else {
		jumpshotState[client] = 1;
	}
}

public void JumpshotReloadPostHook(int weapon, bool bSuccessful) {
	if (bSuccessful) {
		int weaponOwner = EntRefToEntIndex(Weapon_GetOwner(weapon));

		beforeReloadAmmo[weaponOwner] = GetClipAmmo(weapon);

		CreateTimer(0.1, JumpshotWaitForReloadTimer, weapon, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:JumpshotWaitForReloadTimer(Handle timer, int weapon) {
	if (!jumpshotActive || !IsValidEntity(weapon)) {
		return Plugin_Stop;
	}

	if (GetEntProp(weapon, Prop_Data, "m_bInReload")) {
		return Plugin_Continue;
	}

	int weaponOwner = EntRefToEntIndex(Weapon_GetOwner(weapon));

	if (weaponOwner < 0) {
		return Plugin_Stop;
	}

	// Check whether the player is current on the ground, therefore the reload would be cancelled
	if (jumpshotState[weaponOwner] != 0) {
		return Plugin_Stop;
	}

	// Check whether the clip ammo has not changed yet
	if (beforeReloadAmmo[weaponOwner] != lastClipAmmo[weaponOwner]) {
		return Plugin_Stop;
	}

	// Get active weapon of player
	int activeWeapon = GetEntPropEnt(weaponOwner, Prop_Data, "m_hActiveWeapon");

	// Check if the player is still holding that weapon
	if (weapon != activeWeapon) {
		return Plugin_Stop;
	}

	// Get weapon name
	char className[128];
	GetEdictClassname(weapon, className, sizeof(className));

	// Get the clip size for this weapon
	int clipsize = -1;

	for (int i = 0; i < PRIMARY_LENGTH; i++) {
		if (StrEqual(className, WeaponPrimary[i])) {
			clipsize = PrimaryClipSize[i];
		}
	}
	for (int i = 0; i < SECONDARY_LENGTH; i++) {
		if (StrEqual(className, WeaponSecondary[i])) {
			clipsize = SecondaryClipSize[i];
		}
	}

	if (clipsize == -1) {
		return Plugin_Stop;
	}

	// Manually reload the clip and reserve values
	if (GetConVarInt(sv_infinite_ammo) == 2) {
		lastClipAmmo[weaponOwner] = clipsize;
	} else {
		if (clipsize > lastReserveAmmo[weaponOwner]) {
			lastClipAmmo[weaponOwner] = lastReserveAmmo[weaponOwner];
			lastReserveAmmo[weaponOwner] = 0;
		} else {
			lastClipAmmo[weaponOwner] = clipsize;
			lastReserveAmmo[weaponOwner] = lastReserveAmmo[weaponOwner] - clipsize;
		}
	}

	return Plugin_Stop;
}
