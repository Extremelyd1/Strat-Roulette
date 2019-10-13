Handle standoffStunTimer;

public ConfigureMexicanStandoff() {
	KeyValues kv = new KeyValues("Locations");

	if (!kv.ImportFromFile(LOCATION_FILE)) {
		PrintToServer("Location file could not be found!");

		delete kv;
		return;
	}

	kv.JumpToKey("Mexican-Standoff");

	char mapName[128];
	GetCurrentMap(mapName, sizeof(mapName));

	kv.JumpToKey(mapName);

	float xCenter = kv.GetFloat("x", 0.0);
	float yCenter = kv.GetFloat("y", 0.0);
	float zCenter = kv.GetFloat("z", 0.0);

	ArrayList players = new ArrayList();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			players.Push(client);
		}
	}

	float angle = DegToRad(360.0 / players.Length);
	ArrayList locations = new ArrayList();

	for (int i = 0; i < players.Length; i++) {
		float tpAngle = angle * i;

		locations.Push(xCenter + Cosine(tpAngle) * players.Length * 20);
		locations.Push(yCenter + Sine(tpAngle) * players.Length * 20);
	}

	int numPlayers = players.Length;

	for (int i = 0; i < numPlayers; i++) {
		int randomIndex = GetRandomInt(0, players.Length - 1);

		int client = players.Get(randomIndex);
		players.Erase(randomIndex);

		float tpLocation[3];

		tpLocation[0] = locations.Get(i * 2);
		tpLocation[1] = locations.Get(i * 2 + 1);
		tpLocation[2] = zCenter;

		TeleportEntity(client, tpLocation, NULL_VECTOR, NULL_VECTOR);
	}

	int freezeTime = GetConVarInt(mp_freezetime);

	int waitTime = freezeTime;

	if (freezeTime > 1) {
		waitTime = freezeTime - 1;
	}

	standoffStunTimer = CreateTimer(float(waitTime), StandoffStunTimer);
}

public ResetMexicanStandoff() {
	SafeKillTimer(standoffStunTimer);
	standoffStunTimer = INVALID_HANDLE;
}

public Action:StandoffStunTimer(Handle timer) {
	standoffStunTimer = INVALID_HANDLE;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		}
	}
}
