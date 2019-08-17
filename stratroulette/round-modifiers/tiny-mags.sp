bool tinyMagsActive = false;

int magazineSize;

public ConfigureTinyMags(char magazineSizeString[500]) {
	tinyMagsActive = true;

	magazineSize = StringToInt(magazineSizeString);
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (primary > 0) {
				SetClipAmmo(primary, magazineSize);
				SetReserveAmmo(primary, magazineSize);

				SDKHook(primary, SDKHook_Reload, TinyMagsOnWeaponReloadHook);
				SDKHook(primary, SDKHook_ReloadPost, TinyMagsOnWeaponReloadPostHook);
			}

			int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
			if (secondary > 0) {
				SetClipAmmo(secondary, magazineSize);
				SetReserveAmmo(secondary, magazineSize);

				SDKHook(secondary, SDKHook_Reload, TinyMagsOnWeaponReloadHook);
				SDKHook(secondary, SDKHook_ReloadPost, TinyMagsOnWeaponReloadPostHook);
			}
		}
	}

	HookEvent("round_end", TinyMagsRoundEnd);
}

public ResetTinyMags() {
	tinyMagsActive = false;
}

public Action:TinyMagsRoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	tinyMagsActive = false;
}

public TinyMagsOnEntitySpawn(int entity, const String:className[]) {
	if (tinyMagsActive) {
		if (StrContains(className, "weapon_") != -1) {
			CreateTimer(0.1, TinyMagsDelayClipAmmoTimer, entity);

			SDKHook(entity, SDKHook_Reload, TinyMagsOnWeaponReloadHook);
			SDKHook(entity, SDKHook_ReloadPost, TinyMagsOnWeaponReloadPostHook);
		}
	}
}

public Action:TinyMagsDelayClipAmmoTimer(Handle timer, int weapon) {
	SetClipAmmo(weapon, magazineSize);
	SetReserveAmmo(weapon, magazineSize);
}

public Action:TinyMagsOnWeaponReloadHook(int weapon) {
	if (GetClipAmmo(weapon) == magazineSize) {
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public TinyMagsOnWeaponReloadPostHook(int weapon, bool bSuccessful) {
	if (bSuccessful) {
		CreateTimer(0.1, TinyMagsWaitForReloadTimer, weapon, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:TinyMagsWaitForReloadTimer(Handle timer, int weapon) {
	if (!IsValidEntity(weapon)) {
		return Plugin_Stop;
	}

	if (!GetEntProp(weapon, Prop_Data, "m_bInReload")) {
		SetReserveAmmo(weapon, magazineSize);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}
