bool currentlyRedLight = false;
float redGreenPositions[MAXPLAYERS + 1][3];

Handle redGreenDamageTimer;
Handle redGreenCurrentTimer;

public ConfigureRedGreen() {
	redGreenDamageTimer = CreateTimer(0.5, RedGreenDamageTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateNewRedGreenTimer();
}

public ResetRedGreen() {
	currentlyRedLight = false;

	SafeKillTimer(redGreenDamageTimer);
	SafeKillTimer(redGreenCurrentTimer);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			redGreenPositions[client][2] = -1.0;
		}
	}
}

public CreateNewRedGreenTimer() {
	float randomFloat;
	if (currentlyRedLight) {
		randomFloat = GetRandomFloat(2.0, 4.0);
	} else {
		randomFloat = GetRandomFloat(4.0, 12.0);
	}

	redGreenCurrentTimer = CreateTimer(randomFloat, RedGreenMessageTimer);
}

public Action:RedGreenMessageTimer(Handle timer) {
	if (!currentlyRedLight) {
		SendMessageAll("%t", "RedLight");
		// Only enforce no move after certain time
		redGreenCurrentTimer = CreateTimer(1.0, RedLightTimer);
	} else {
		SendMessageAll("%t", "GreenLight");
		// Immediately enforce move period
		currentlyRedLight = false;
		CreateNewRedGreenTimer();
	}

	return Plugin_Continue;
}

public Action:RedLightTimer(Handle timer) {
	currentlyRedLight = true;

	// Save player positions
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			float playerPos[3];
			GetClientEyePosition(i, playerPos);

			redGreenPositions[i] = playerPos;
		}
	}

	CreateNewRedGreenTimer();

	return Plugin_Continue;
}

public Action:RedGreenDamageTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			float playerPos[3];
			GetClientEyePosition(i, playerPos);

			if (redGreenPositions[i][2] != -1.0) {
				float oldPlayerPos[3];
				oldPlayerPos[0] = redGreenPositions[i][0];
				oldPlayerPos[1] = redGreenPositions[i][1];
				oldPlayerPos[2] = redGreenPositions[i][2];

				float distance = GetVectorDistance(oldPlayerPos, playerPos);

				if (currentlyRedLight && distance > 10) {
					SDKHooks_TakeDamage(i, i, i, GetTrueDamage(i, 10.0), DMG_GENERIC);

					SendMessage(i, "%t", "DontMoveRedLight");
				}
			}

			redGreenPositions[i] = playerPos;
		}
	}

	return Plugin_Continue;
}
