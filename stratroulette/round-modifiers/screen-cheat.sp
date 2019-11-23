bool screenCheatActive = false;

ArrayList screenCheatCTPlayers;
ArrayList screenCheatTPlayers;

new screenCheatEntities[MAXPLAYERS + 1];

int ctClientNeedsView;
int tClientNeedsView;

public ConfigureScreenCheat() {
	screenCheatCTPlayers = new ArrayList();
	screenCheatTPlayers = new ArrayList();

	ctClientNeedsView = -1;
	tClientNeedsView = -1;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			int entity = CreateViewEntity();
			screenCheatEntities[client] = entity;

			if (GetClientTeam(client) == CS_TEAM_CT) {
				if (ctClientNeedsView != -1) {
					SetClientViewEntity(ctClientNeedsView, screenCheatEntities[client]);
					ctClientNeedsView = -1;
				}

				if (screenCheatCTPlayers.Length == 0) {
					ctClientNeedsView = client;
				} else {
					SetClientViewEntity(client, screenCheatEntities[screenCheatCTPlayers.Get(screenCheatCTPlayers.Length - 1)]);
				}
				screenCheatCTPlayers.Push(client);
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				if (tClientNeedsView != -1) {
					SetClientViewEntity(tClientNeedsView, screenCheatEntities[client]);
					tClientNeedsView = -1;
				}
				
				if (screenCheatTPlayers.Length == 0) {
					tClientNeedsView = client;
				} else {
					SetClientViewEntity(client, screenCheatEntities[screenCheatTPlayers.Get(screenCheatTPlayers.Length - 1)]);
				}
				screenCheatTPlayers.Push(client);
			}
		}
	}

	screenCheatActive = true;
}

public ResetScreenCheat() {
	screenCheatActive = false;

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			// Reset view
			SetClientViewEntity(i, i);
		}
	}

	delete screenCheatCTPlayers;
	delete screenCheatTPlayers;
}

public Action:ScreenCheatOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!screenCheatActive) {
		return Plugin_Continue;
	}

	new entity = screenCheatEntities[client];
	if (entity != -1) {
		if (IsValidEntity(entity)) {
			float position[3];
			GetClientEyePosition(client, position);

			float eyeAngles[3];
			GetClientEyeAngles(client, eyeAngles);

			TeleportEntity(entity, position, eyeAngles, NULL_VECTOR);
		}
	}

	return Plugin_Continue;
}
