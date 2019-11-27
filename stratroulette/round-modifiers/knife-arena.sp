#define KNIFE_ARENA_NUM_FENCES 8
#define KNIFE_ARENA_RADIUS 330.0
#define KNIFE_ARENA_TP_RADIUS 250.0
#define KNIFE_ARENA_TP_HEIGHT 50
#define KNIFE_ARENA_RESET_DELAY 2.0
#define KNIFE_ARENA_NEW_MATCH_DELAY 4.0

float arenaCenter[3];
float specSpawn[3];
bool rotateSpawn;

int ctArenaContestant;
int tArenaContestant;

Handle knifeArenaTimer;

public ConfigureKnifeArena() {
	ctArenaContestant = -1;
	tArenaContestant = -1;

	KeyValues kv = new KeyValues("Locations");

	if (!kv.ImportFromFile(LOCATION_FILE)) {
		PrintToServer("Location file could not be found!");

		delete kv;
		return;
	}

	kv.JumpToKey("Knife-Arena");

	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));

	kv.JumpToKey(mapName);

	kv.JumpToKey("Arena");

	arenaCenter[0] = kv.GetFloat("x", 0.0);
	arenaCenter[1] = kv.GetFloat("y", 0.0);
	arenaCenter[2] = kv.GetFloat("z", 0.0);

	int doubleFence = kv.GetNum("double", 0);
	rotateSpawn = kv.GetNum("rotatespawn", 0) == 1;

	kv.GoBack();

	kv.JumpToKey("Spectator-Spawn");

	specSpawn[0] = kv.GetFloat("x", 0.0);
	specSpawn[1] = kv.GetFloat("y", 0.0);
	specSpawn[2] = kv.GetFloat("z", 0.0);

	int spawnUp = kv.GetNum("up", 0);

	specSpawn[2] += spawnUp * 125.0;

	delete kv;

	for (int i = 0; i < doubleFence + 1; i++) {
		if (i != 0) {
			arenaCenter[2] += 125.0;
		}

		float angle = DegToRad(360.0 / KNIFE_ARENA_NUM_FENCES);

		for (int j = 0; j < KNIFE_ARENA_NUM_FENCES; j++) {
			float tpAngle = angle * j;

			float xLocation = arenaCenter[0] + Cosine(tpAngle) * KNIFE_ARENA_RADIUS;
			float yLocation = arenaCenter[1] + Sine(tpAngle) * KNIFE_ARENA_RADIUS;

			float location[3];
			location[0] = xLocation;
			location[1] = yLocation;
			location[2] = arenaCenter[2];

			float angles[3];
			angles[0] = 0.0;
			angles[1] = 360.0 / KNIFE_ARENA_NUM_FENCES * (j + 0.5);
			angles[2] = 0.0;

			SpawnFenceWithAngles(location, angles);
		}
	}

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, KnifeArenaPlayerOnTakeDamageHook);
			SetEntData(client, g_offsCollisionGroup, 2, 4, true);
			/* SetKnifeClient(client, false); */
			TeleportEntity(client, specSpawn, NULL_VECTOR, NULL_VECTOR);
		}
	}

	HookEvent("player_death", KnifeArenaPlayerDeathEvent);

	knifeArenaTimer = CreateTimer(GetConVarInt(mp_freezetime) + KNIFE_ARENA_NEW_MATCH_DELAY, ArenaPickPair);
}


public ResetKnifeArena() {
	SafeKillTimer(knifeArenaTimer);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, KnifeArenaPlayerOnTakeDamageHook);
		}
	}

	UnhookEvent("player_death", KnifeArenaPlayerDeathEvent);
}

public Action:ResetArena(Handle timer) {
	knifeArenaTimer = INVALID_HANDLE;

	if (ctArenaContestant != -1) {
		HealPlayer(ctArenaContestant, 100);

		SetEntData(ctArenaContestant, g_offsCollisionGroup, 2, 4, true);
		/* SetKnifeClient(ctArenaContestant, false); */
		TeleportEntity(ctArenaContestant, specSpawn, NULL_VECTOR, NULL_VECTOR);
	}

	if (tArenaContestant != -1) {
		HealPlayer(tArenaContestant, 100);

		SetEntData(tArenaContestant, g_offsCollisionGroup, 2, 4, true);
		/* SetKnifeClient(tArenaContestant, false); */
		TeleportEntity(tArenaContestant, specSpawn, NULL_VECTOR, NULL_VECTOR);
	}

	ctArenaContestant = -1;
	tArenaContestant = -1;

	if (!IsWiped()) {
		// TODO: announce next 1v1

		knifeArenaTimer = CreateTimer(KNIFE_ARENA_NEW_MATCH_DELAY, ArenaPickPair);
	}
}

public Action:ArenaPickPair(Handle timer) {
	knifeArenaTimer = INVALID_HANDLE;

	ArrayList ctPlayers = new ArrayList();
	ArrayList tPlayers = new ArrayList();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				ctPlayers.Push(client);
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				tPlayers.Push(client);
			}
		}
	}

	ctArenaContestant = ctPlayers.Get(GetRandomInt(0, ctPlayers.Length - 1));
	tArenaContestant = tPlayers.Get(GetRandomInt(0, tPlayers.Length - 1));

	SetEntData(ctArenaContestant, g_offsCollisionGroup, 5, 4, true);
	SetEntData(tArenaContestant, g_offsCollisionGroup, 5, 4, true);

	HealPlayer(ctArenaContestant, 100);
	HealPlayer(tArenaContestant, 100);

	/* SetKnifeClient(ctArenaContestant, true);
	SetKnifeClient(tArenaContestant, true); */

	float location[3];
	location[0] = arenaCenter[0];
	location[1] = arenaCenter[1];
	if (rotateSpawn) {
		location[1] = arenaCenter[1] + KNIFE_ARENA_TP_RADIUS;
	} else {
		location[0] = arenaCenter[0] + KNIFE_ARENA_TP_RADIUS;
	}
	location[2] = arenaCenter[2] + KNIFE_ARENA_TP_HEIGHT;

	TeleportEntity(ctArenaContestant, location, NULL_VECTOR, NULL_VECTOR);

	if (rotateSpawn) {
		location[1] = arenaCenter[1] - KNIFE_ARENA_TP_RADIUS;
	} else {
		location[0] = arenaCenter[0] - KNIFE_ARENA_TP_RADIUS;
	}

	TeleportEntity(tArenaContestant, location, NULL_VECTOR, NULL_VECTOR);

	char ctName[128];
	GetClientName(ctArenaContestant, ctName, sizeof(ctName));
	char tName[128];
	GetClientName(tArenaContestant, tName, sizeof(tName));

	SendMessageAll("%t", "KnifeArenaNewRound", ctName, tName);
}

public Action:KnifeArenaPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (GetClientTeam(client) == CS_TEAM_CT) {
		ctArenaContestant = -1;
	} else if (GetClientTeam(client) == CS_TEAM_T) {
		tArenaContestant = -1;
	}

	char winnerName[128];
	GetClientName(killer, winnerName, sizeof(winnerName));

	SendMessageAll("%t", "KnifeArenaWinner", winnerName);

	if (!IsWiped()) {
		knifeArenaTimer = CreateTimer(KNIFE_ARENA_RESET_DELAY, ResetArena);
	}
}

public Action:KnifeArenaPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (victim != ctArenaContestant && victim != tArenaContestant) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
