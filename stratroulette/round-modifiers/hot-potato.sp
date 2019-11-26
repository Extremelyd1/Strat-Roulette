int potatoHolder;
char potatoHolderName[128];

Handle hotPotatoTimer1;
Handle hotPotatoTimer2;
Handle hotPotatoTimer3;

public ConfigureHotPotato() {
	int freezeTime = GetConVarInt(mp_freezetime);

	hotPotatoTimer1 = CreateTimer(freezeTime + 10.0, NewHotPotatoTimer);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, HotPotatoOnTakeDamageHook);
		}
	}

	AddCommandListener(DenyDropListener, "drop");
}

public ResetHotPotato() {
	SafeKillTimer(hotPotatoTimer1);
	SafeKillTimer(hotPotatoTimer2);
	SafeKillTimer(hotPotatoTimer3);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, HotPotatoOnTakeDamageHook);
		}
	}

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:HotPotatoOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (attacker != victim && victim != 0 && attacker != 0 && GetClientTeam(victim) != GetClientTeam(attacker)) {
		SelectHotPotato(victim);
	}

	return Plugin_Handled;
}

public Action:NewHotPotatoTimer(Handle timer) {
	SelectHotPotato();
	hotPotatoTimer1 = CreateTimer(5.0, HotPotatoMessage1Timer);
	hotPotatoTimer2 = CreateTimer(10.0, HotPotatoMessage2Timer);
	hotPotatoTimer3 = CreateTimer(15.0, HotPotatoTimer);

	return Plugin_Continue;
}

stock void SelectHotPotato(int client = -1) {
	RemoveWeapons();
	ArrayList players = new ArrayList();

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			players.Push(i);
		}
	}

	if (client == -1) {
		if (players.Length == 0) {
			// This method should not have been called!
			return;
		}
		int randomInt = GetRandomInt(0, players.Length - 1);
		potatoHolder = players.Get(randomInt);
	} else {
		potatoHolder = client;
	}

	GetClientName(potatoHolder, potatoHolderName, sizeof(potatoHolderName));

	SendMessage(potatoHolder, "%t", "ReceivedPotato");

	for (int i = 0; i < players.Length; i++) {
		int otherClient = players.Get(i);
		if (otherClient != potatoHolder) {
			SendMessage(otherClient, "%t", "PlayerHasPotato", potatoHolderName);
		}
	}

	GiveHotPotato(potatoHolder);
}

public void GiveHotPotato(client) {
	GivePlayerItem(client, "weapon_fiveseven");
}

public Action:HotPotatoMessage1Timer(Handle timer) {
	if (potatoHolder != -1) {
		SendMessage(potatoHolder, "%t", "HotPotatoStage1");
	}

	hotPotatoTimer1 = INVALID_HANDLE;
}

public Action:HotPotatoMessage2Timer(Handle timer) {
	if (potatoHolder != -1) {
		SendMessage(potatoHolder, "%t", "HotPotatoStage2");
	}

	hotPotatoTimer2 = INVALID_HANDLE;
}

public Action:HotPotatoTimer(Handle timer) {
	RemoveWeapons();
	if (potatoHolder != -1) {
		ForcePlayerSuicide(potatoHolder);

		SendMessageAll("%t", "HotPotatoDied", potatoHolderName);

		bool ctWiped = true;
		bool tWiped = true;

		for (int client = 1; client <= MaxClients; client++) {
			if (IsClientInGame(client) && IsPlayerAlive(client)) {
				if (GetClientTeam(client) == CS_TEAM_CT) {
					ctWiped = false;
				} else if (GetClientTeam(client) == CS_TEAM_T) {
					tWiped = false;
				}
			}
		}

		if (ctWiped || tWiped) {
			hotPotatoTimer3 = INVALID_HANDLE;

			return Plugin_Stop;
		}
	}

	hotPotatoTimer1 = CreateTimer(3.0, NewHotPotatoTimer);

	return Plugin_Continue;
}
