bool randomNadesActive = false;

public ConfigureRandomNades() {
	SetConVarInt(mp_death_drop_grenade, 0, true, false);

	randomNadesActive = true;
}

public ResetRandomNades() {
	randomNadesActive = false;

	SetConVarInt(mp_death_drop_grenade, 1, true, false);
}

public RandomNadesOnEntitySpawn(int entity, const String:className[]) {
	if (randomNadesActive) {
		if (StrContains(className, "_projectile") != -1) {
			SDKHook(entity, SDKHook_SpawnPost, RandomNadesSpawnHook);
		}
	}
}

public RandomNadesSpawnHook(entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		int nadeslot = GetPlayerWeaponSlot(client, 3);
		if (nadeslot > -1) {
			RemovePlayerItem(client, nadeslot);
		}
		RemoveEdict(nadeslot);

		int randomInt = GetRandomInt(1, 6);

		if (randomInt == 1) {
			GivePlayerItem(client, "weapon_smokegrenade");
		} else if (randomInt == 2) {
			GivePlayerItem(client, "weapon_flashbang");
		} else if (randomInt == 3) {
			GivePlayerItem(client, "weapon_decoy");
		} else if (randomInt == 4) {
			GivePlayerItem(client, "weapon_hegrenade");
		} else if (randomInt == 5) {
			GivePlayerItem(client, "weapon_molotov");
		} else if (randomInt == 6) {
			GivePlayerItem(client, "weapon_incgrenade");
		}
	}
}
