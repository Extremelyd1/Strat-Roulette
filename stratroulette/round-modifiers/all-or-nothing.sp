bool allOrNothingActive = false;

float allOrNothingLastHit[MAXPLAYERS + 1];

public ConfigureAllOrNothing() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			allOrNothingLastHit[client] = GetGameTime();

			int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (weapon < 1) {
				weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			}

			SDKHook(weapon, SDKHook_Reload, AllOrNothingOnWeaponReloadHook);
		}
	}

	allOrNothingActive = true;
}

public ResetAllOrNothing() {
	allOrNothingActive = false;
}

public Action:AllOrNothingOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!allOrNothingActive || !IsClientInGame(client) || !IsPlayerAlive(client)) {
		return Plugin_Continue;
	}

	new activeWeapon = Client_GetActiveWeapon(client);

	if (activeWeapon < 0) {
		return Plugin_Continue;
	}

	char weaponname[128];

	int iItemDefIndex = GetEntProp(activeWeapon, Prop_Send, "m_iItemDefinitionIndex");
	CS_WeaponIDToAlias(CS_ItemDefIndexToID(iItemDefIndex), weaponname, sizeof(weaponname));
	Format(weaponname, sizeof(weaponname), "weapon_%s", weaponname);

	if (StrEqual(weaponname, "weapon_c4") || buttons & IN_ATTACK) {
		return Plugin_Continue;
	}

	int clipSize = -1;
	for (int i = 0; i < PRIMARY_LENGTH; i++) {
		if (StrEqual(weaponname, WeaponPrimary[i])) {
			clipSize = PrimaryClipSize[i];
			break;
		}
	}
	if (clipSize == -1) {
		for (int i = 0; i < SECONDARY_LENGTH; i++) {
			if (StrEqual(weaponname, WeaponSecondary[i])) {
				clipSize = SecondaryClipSize[i];
				break;
			}
		}
	}

	int isReloading = GetEntProp(activeWeapon, Prop_Data, "m_bInReload");
	int clipAmmo = GetClipAmmo(activeWeapon);

	if (clipAmmo != clipSize && clipAmmo != 0 && isReloading == 0) {
		if (GetGameTime() - allOrNothingLastHit[client] > 1.0) {
			SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, 10.0), DMG_GENERIC);

			SendMessage(client, "%t", "KeepFiringAllOrNothing");

			allOrNothingLastHit[client] = GetGameTime();
		}
	}

	return Plugin_Continue;
}

public Action:AllOrNothingOnWeaponReloadHook(int weapon) {
	int clipAmmo = GetClipAmmo(weapon);
	if (clipAmmo != 0) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
