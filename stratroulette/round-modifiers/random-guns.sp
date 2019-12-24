Handle randomGunsTimer;

public ConfigureRandomGuns() {
	randomGunsTimer = CreateTimer(1.0, RandomGunsTimer);

	AddCommandListener(DenyDropListener, "drop");
}

public ResetRandomGuns() {
	SafeKillTimer(randomGunsTimer);

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:RandomGunsTimer(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			new primary = GetPlayerWeaponSlot(client, 0);
			new secondary = GetPlayerWeaponSlot(client, 1);

			if (primary > -1) {
				RemovePlayerItem(client, primary);
				RemoveEdict(primary);
			}

			if (secondary > -1) {
				RemovePlayerItem(client, secondary);
				RemoveEdict(secondary);
			}
			
			new randomIntCat = GetRandomInt(0, 1);

			char weapon[256];
			if (randomIntCat == 0) {
				new randomInt = GetRandomInt(0, PRIMARY_LENGTH - 1);
				Format(weapon, sizeof(weapon), WeaponPrimary[randomInt]);
			} else {
				new randomInt = GetRandomInt(0, SECONDARY_LENGTH - 1);
				Format(weapon, sizeof(weapon), WeaponSecondary[randomInt]);
			}
			GivePlayerItem(client, weapon);
		}
	}

	float randomFloat = GetRandomFloat(5.0, 9.0);

	randomGunsTimer = CreateTimer(randomFloat, RandomGunsTimer);

	return Plugin_Continue;
}
