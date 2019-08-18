bool infiniteNadesActive = false;

public ConfigureInfiniteNades() {
	SetConVarInt(mp_death_drop_grenade, 0, true, false);

	infiniteNadesActive = true;
}

public ResetInfiniteNades() {
	infiniteNadesActive = false;

	SetConVarInt(mp_death_drop_grenade, 1, true, false);
}

public InfiniteNadesOnEntitySpawn(int entity, const String:className[]) {
	if (infiniteNadesActive) {
		if (StrContains(className, "_projectile") != -1) {
			SDKHook(entity, SDKHook_SpawnPost, InfiniteNadesSpawnHook);
		}
	}
}

public InfiniteNadesSpawnHook(entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		int nadeslot = GetPlayerWeaponSlot(client, 3);
		if (nadeslot > -1) {
			RemovePlayerItem(client, nadeslot);
		}
		RemoveEdict(nadeslot);

		char className[128];
		GetEdictClassname(entity, className, sizeof(className));

		if (StrEqual(className, "smokegrenade_projectile")) {
			GivePlayerItem(client, "weapon_smokegrenade");
		} else if (StrEqual(className, "flashbang_projectile")) {
			GivePlayerItem(client, "weapon_flashbang");
		} else if (StrEqual(className, "decoy_projectile")) {
			GivePlayerItem(client, "weapon_decoy");
		} else if (StrEqual(className, "hegrenade_projectile")) {
			GivePlayerItem(client, "weapon_hegrenade");
		} else if (StrEqual(className, "molotov_projectile")) {
			GivePlayerItem(client, "weapon_molotov");
		} else if (StrEqual(className, "incgrenade_projectile")) {
			GivePlayerItem(client, "weapon_incgrenade");
		}
	}
}
