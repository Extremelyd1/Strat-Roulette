Handle buddyTimer;

new chickens[MAXPLAYERS + 1];
new StringMap:chickenHealth;

public ConfigureBuddySystem() {
	chickenHealth = CreateTrie();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			new chicken = CreateEntityByName("chicken");
			float playerPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerPos);

			DispatchSpawn(chicken);
			SetEntProp(chicken, Prop_Send, "m_fEffects", 0);

			SDKHookEx(chicken, SDKHook_OnTakeDamage, BuddySystemChickenOnTakeDamageHook);
			SDKHook(client, SDKHook_OnTakeDamage, BuddySystemPlayerOnTakeDamageHook);

			// Teleport chicken to player
			TeleportEntity(chicken, playerPos, NULL_VECTOR, NULL_VECTOR);

			// Set chicken to follow player
			SetEntPropEnt(chicken, Prop_Send, "m_leader", client);

			chickens[client] = chicken;

			new String:chickenIdString[64];
			IntToString(chicken, chickenIdString, sizeof(chickenIdString));
			chickenHealth.SetValue(chickenIdString, 200.0);
		}
	}
	// Create timer to enforce leader of chicken
	buddyTimer = CreateTimer(0.1, BuddyTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	HookEvent("other_death", BuddySystemOtherDeathEvent);
}

public ResetBuddySystem() {
	SafeKillTimer(buddyTimer);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, BuddySystemPlayerOnTakeDamageHook);
			chickens[client] = -1;
		}
	}

	if (chickenHealth.Size != 0) {
		StringMapSnapshot snapshot = chickenHealth.Snapshot();
		for (int i = 0; i < snapshot.Length; i++) {
			char key[64];
			snapshot.GetKey(i, key, sizeof(key));

			int chickenRef = EntIndexToEntRef(StringToInt(key));
			AcceptEntityInput(chickenRef, "kill");
		}

		delete snapshot;
	}

	delete chickenHealth;
}

public Action:BuddySystemChickenOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	// Find owner of attacked chicken
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			// If the owner is in the same team, do not damage chicken
			if (chickens[client] == victim && GetClientTeam(client) == GetClientTeam(inflictor)) {
				return Plugin_Handled;
			}
		}
	}

	new String:victimIdString[64];
	IntToString(victim, victimIdString, sizeof(victimIdString));
	float currentChickenHealth;
	if (chickenHealth.GetValue(victimIdString, currentChickenHealth)) {
		if (damage < currentChickenHealth) {
			chickenHealth.SetValue(victimIdString, currentChickenHealth - damage);
			return Plugin_Handled;
		}
		chickenHealth.Remove(victimIdString);
		return Plugin_Continue;
	}

	return Plugin_Continue;
}

public Action:BuddySystemPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	return Plugin_Stop;
}

public Action:BuddySystemOtherDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "otherid");
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			// Get chicken that belongs to player
			new chicken = chickens[i];

			if (chicken == entity) {
				SDKHooks_TakeDamage(i, attacker, attacker, GetTrueDamage(i, float(health)), DMG_GENERIC);
				chickens[i] = -1;

				break;
			}
		}
	}
}

public Action:BuddyTimer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			// Get chicken that belongs to player
			if (chickens[i] != -1) {
				new chicken = chickens[i];
				if (chicken != 0 && IsValidEntity(chicken)) {
					// Set the leader property again
					SetEntPropEnt(chicken, Prop_Send, "m_leader", i);
				}
			}
		}
	}
	return Plugin_Continue;
}
