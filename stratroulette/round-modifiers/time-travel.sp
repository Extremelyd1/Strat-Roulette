#define TIME_TRAVEL_SECONDS 5
#define TIME_TRAVEL_COOLDOWN 10
#define MAX_INTERACT_DIST 200.0

bool timeTravelActive = false;

float timeTravelPositions[MAXPLAYERS + 1][TIME_TRAVEL_SECONDS][3];

int timeTravelOnCooldown[MAXPLAYERS + 1];

Handle timeTravelPositionsTimer;
Handle timeTravelCooldownTimer;

public ConfigureTimeTravel() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			float playerPos[3];
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", playerPos);

			for (int j = 0; j < TIME_TRAVEL_SECONDS; j++) {
				timeTravelPositions[i][j][0] = playerPos[0];
				timeTravelPositions[i][j][1] = playerPos[1];
				timeTravelPositions[i][j][2] = playerPos[2];
			}

			timeTravelOnCooldown[i] = 0;
		}
	}

	timeTravelPositionsTimer = CreateTimer(1.0, TimeTravelSavePositionsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	timeTravelCooldownTimer = CreateTimer(1.0, TimeTravelCooldownTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	AddCommandListener(DenyDropListener, "drop");
	AddCommandListener(TimeTravelLookAtWeaponListener, "+lookatweapon");

	timeTravelActive = true;
}

public ResetTimeTravel() {
	timeTravelActive = false;

	SafeKillTimer(timeTravelPositionsTimer);
	SafeKillTimer(timeTravelCooldownTimer);

	RemoveCommandListener(DenyDropListener, "drop");
	RemoveCommandListener(TimeTravelLookAtWeaponListener, "+lookatweapon");
}

public Action:TimeTravelSavePositionsTimer(Handle timer) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			for (int j = TIME_TRAVEL_SECONDS - 2; j >= 0; j--) {
				timeTravelPositions[i][j + 1][0] = timeTravelPositions[i][j][0];
				timeTravelPositions[i][j + 1][1] = timeTravelPositions[i][j][1];
				timeTravelPositions[i][j + 1][2] = timeTravelPositions[i][j][2];
			}

			float playerPos[3];
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", playerPos);

			timeTravelPositions[i][0][0] = playerPos[0];
			timeTravelPositions[i][0][1] = playerPos[1];
			timeTravelPositions[i][0][2] = playerPos[2];
		}
	}

	return Plugin_Continue;
}

public Action:TimeTravelCooldownTimer(Handle timer) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			int newCooldown = timeTravelOnCooldown[i] - 1;
			if (newCooldown < 0) {
				newCooldown = 0;
			}
			timeTravelOnCooldown[i] = newCooldown;

			if (newCooldown == 0) {
				SendCenterText(i, "%t", "TimeTravelNoCooldown");
			} else {
				SendCenterText(i, "%t", "TimeTravelCooldown", newCooldown);
			}
		}
	}

	return Plugin_Continue;
}

public Action:TimeTravelLookAtWeaponListener(int client, const char[] command, int args) {
	if (!IsPlayerAlive(client)) {
		return Plugin_Continue;
	}
	
	if (!timeTravelActive) {
		return Plugin_Continue;
	}

	if (timeTravelOnCooldown[client] != 0) {
		return Plugin_Continue;
	}
	
	float tpPos[3];
	tpPos[0] = timeTravelPositions[client][TIME_TRAVEL_SECONDS - 1][0];
	tpPos[1] = timeTravelPositions[client][TIME_TRAVEL_SECONDS - 1][1];
	tpPos[2] = timeTravelPositions[client][TIME_TRAVEL_SECONDS - 1][2];

	TeleportEntity(client, tpPos, NULL_VECTOR, NULL_VECTOR);

	timeTravelOnCooldown[client] = TIME_TRAVEL_COOLDOWN;
	
	return Plugin_Continue;
}