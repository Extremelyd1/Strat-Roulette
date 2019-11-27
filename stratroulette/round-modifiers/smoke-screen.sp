#define SMOKE_SCREEN_LENGTH 6

Handle smokeScreenTimer;
Handle smokeScreenBorderTimer;

new smokeEntities[SMOKE_SCREEN_LENGTH];
new smokeEntitiesToDelete[SMOKE_SCREEN_LENGTH];

float smokeScreenStartPos[3];
int smokeScreenXMod;
int smokeScreenYMod;

public ConfigureSmokeScreen() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		}
	}

	BuildSmokeScreenArena();

	CreateTimer(2.0, SmokeScreenSpawnPlayers);

	SmokeScreenSpawnSmokes();
	smokeScreenTimer = CreateTimer(15.0, SmokeScreenTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	smokeScreenBorderTimer = CreateTimer(0.5, SmokeScreenBorderTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetSmokeScreen() {
	SafeKillTimer(smokeScreenTimer);
	SafeKillTimer(smokeScreenBorderTimer);
}

public Action:SmokeScreenTimer(Handle timer) {
	for (int i = 0; i < SMOKE_SCREEN_LENGTH; i++) {
		smokeEntitiesToDelete[i] = smokeEntities[i];
	}

	SmokeScreenSpawnSmokes();

	CreateTimer(1.0, SmokeScreenKillSmokes);

	return Plugin_Continue;
}

public Action:SmokeScreenKillSmokes(Handle timer) {
	for (int i = 0; i < SMOKE_SCREEN_LENGTH; i++) {
		if (IsValidEntity(smokeEntitiesToDelete[i])) {
			AcceptEntityInput(smokeEntitiesToDelete[i], "kill");
		}
	}
}

public Action:SmokeScreenBorderTimer(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			float y = smokeScreenStartPos[0] + smokeScreenXMod * 512.0;

			float clientPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPos);

			float diff = y - clientPos[0];
			if (diff < 0) {
				diff *= -1;
			}

			if (diff < SMOKE_RADIUS) {
				SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, 50.0), DMG_GENERIC);
			}
		}
	}
}

public SmokeScreenSpawnSmokes() {
	for (int i = 0; i < SMOKE_SCREEN_LENGTH; i++) {
		float spawnPos[3];
		spawnPos[0] = smokeScreenStartPos[0] + smokeScreenXMod * 512.0;
		spawnPos[1] = smokeScreenStartPos[1] + i * smokeScreenYMod * 150.0;
		spawnPos[2] = smokeScreenStartPos[2] + 5.0;

		int smokeEntity = CreateEntityByName("info_particle_system");

		DispatchKeyValue(smokeEntity, "start_active", "0");
		DispatchKeyValue(smokeEntity, "effect_name", "explosion_smokegrenade");
		DispatchSpawn(smokeEntity);
		TeleportEntity(smokeEntity, spawnPos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(smokeEntity);
		AcceptEntityInput(smokeEntity, "Start");

		smokeEntities[i] = smokeEntity;
	}
}

public Action:SmokeScreenSpawnPlayers(Handle timer) {
	KeyValues kv = new KeyValues("Locations");

	if (!kv.ImportFromFile(LOCATION_FILE)) {
		PrintToServer("Location file could not be found!");

		delete kv;
		return;
	}

	kv.JumpToKey("Smoke-Screen");

	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));

	kv.JumpToKey(mapName);

	float ctSpawn[3];

	ctSpawn[0] = kv.GetFloat("ctSpawnX", 0.0);
	ctSpawn[1] = kv.GetFloat("ctSpawnY", 0.0);
	ctSpawn[2] = kv.GetFloat("ctSpawnZ", 0.0);

	float tSpawn[3];

	tSpawn[0] = kv.GetFloat("tSpawnX", 0.0);
	tSpawn[1] = kv.GetFloat("tSpawnY", 0.0);
	tSpawn[2] = kv.GetFloat("tSpawnZ", 0.0);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				TeleportEntity(client, ctSpawn, NULL_VECTOR, NULL_VECTOR);
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				TeleportEntity(client, tSpawn, NULL_VECTOR, NULL_VECTOR);
			}
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}

	delete kv;
}

public BuildSmokeScreenArena() {
	KeyValues kv = new KeyValues("Locations");

	if (!kv.ImportFromFile(LOCATION_FILE)) {
		PrintToServer("Location file could not be found!");

		delete kv;
		return;
	}

	kv.JumpToKey("Smoke-Screen");

	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));

	kv.JumpToKey(mapName);

	smokeScreenStartPos[0] = kv.GetFloat("x", 0.0);
	smokeScreenStartPos[1] = kv.GetFloat("y", 0.0);
	smokeScreenStartPos[2] = kv.GetFloat("z", 0.0);

	smokeScreenXMod = kv.GetNum("x-modifier", 1);
	smokeScreenYMod = kv.GetNum("y-modifier", 1);

	delete kv;

	for (int x = 0; x < 6; x++) {
		for (int y = 0; y < 6; y++) {
			float spawnPos[3];
			spawnPos[0] = smokeScreenStartPos[0] - 91.0 + x * smokeScreenXMod * 180.0;
			spawnPos[1] = smokeScreenStartPos[1] + 70.0 + y * smokeScreenYMod * 144.0;
			spawnPos[2] = smokeScreenStartPos[2];

			SpawnScaffolding(spawnPos);
		}
	}

	SmokeScreenFenceLine(smokeScreenStartPos, 90.0, smokeScreenXMod, smokeScreenYMod, 0.0, 0.0, true, 4);
	SmokeScreenFenceLine(smokeScreenStartPos, 0.0, smokeScreenXMod, smokeScreenYMod, smokeScreenXMod * 1024.0, 0.0, false, 3);
	SmokeScreenFenceLine(smokeScreenStartPos, -90.0, -smokeScreenXMod, smokeScreenYMod, smokeScreenXMod * 1024.0, smokeScreenYMod * 768.0, true, 4);
	SmokeScreenFenceLine(smokeScreenStartPos, -180.0, smokeScreenXMod, -smokeScreenYMod, 0.0, smokeScreenYMod * 768.0, false, 3);
}

public SmokeScreenFenceLine(float startPos[3], float rotation, int xMod, int yMod, float startX, float startY, bool xDir, int length) {
	for (int i = 0; i < length; i++) {
		float spawnPos[3];
		spawnPos[0] = startPos[0] + startX;
		if (xDir) {
			spawnPos[0] = spawnPos[0] + i * xMod * 256.0;
		}
		spawnPos[1] = startPos[1] + startY;
		if (!xDir) {
			spawnPos[1] = spawnPos[1] + i * yMod * 256.0;
		}
		spawnPos[2] = startPos[2];

		float angles[3];
		angles[0] = 0.0;
		angles[1] = rotation;
		angles[2] = 0.0;

		SpawnFenceWithAngles(spawnPos, angles);
	}
}
