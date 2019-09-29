new StringMap:smokeMap;

Handle poisonDamageTimer;

public ConfigurePoison() {
	smokeMap = CreateTrie();

	poisonDamageTimer = CreateTimer(0.5, PoisonDamageTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	HookEvent("smokegrenade_detonate", PoisonSmokeGrenadeDetonateEvent);
	HookEvent("smokegrenade_expired", PoisonSmokeGrenadeExpireEvent);
}

public ResetPoison() {
	SafeKillTimer(poisonDamageTimer);

	delete smokeMap;
}

public Action:PoisonSmokeGrenadeDetonateEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "entityid");
	float pos[3];
	pos[0] = GetEventFloat(event, "x");
	pos[1] = GetEventFloat(event, "y");
	pos[2] = GetEventFloat(event, "z");

	new String:entityIdString[64];
	IntToString(entity, entityIdString, sizeof(entityIdString));

	smokeMap.SetArray(entityIdString, pos, 3);
}

public Action:PoisonSmokeGrenadeExpireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "entityid");

	new String:entityIdString[64];
	IntToString(entity, entityIdString, sizeof(entityIdString));

	smokeMap.Remove(entityIdString);
}

public Action:PoisonDamageTimer(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			float playerPos[3];
			GetClientEyePosition(client, playerPos);

			StringMapSnapshot snapshot = smokeMap.Snapshot();
			for (int i = 0; i < snapshot.Length; i++) {
				char key[64];
				snapshot.GetKey(i, key, sizeof(key));

				float smokePos[3];
				smokeMap.GetArray(key, smokePos, sizeof(smokePos));

				float distance = GetVectorDistance(playerPos, smokePos);

				if (distance < SMOKE_RADIUS) {
					SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, 5.0), DMG_GENERIC);
					SendMessage(client, "%t", "SmokeToxic");
				}
			}
			// Free snapshot variable
			delete snapshot;
		}
	}

	return Plugin_Continue;
}
