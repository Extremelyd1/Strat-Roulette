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
	RemoveWeapons();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
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
