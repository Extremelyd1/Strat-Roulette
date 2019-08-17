int ctLeader;
char ctLeaderName[128];

int tLeader;
char tLeaderName[128];

Handle checkLeaderTimer;

public ConfigureLeader() {
	SetLeader(CS_TEAM_CT);
	SetLeader(CS_TEAM_T);
	SendLeaderMessage(CS_TEAM_CT);
	SendLeaderMessage(CS_TEAM_T);

	float freezeTime = float(GetConVarInt(mp_freezetime));
	checkLeaderTimer = CreateTimer(freezeTime + 7.0, StartLeaderTimer);

	HookEvent("player_death", LeaderPlayerDeathEvent);
}

public ResetLeader() {
	UnhookEvent("player_death", LeaderPlayerDeathEvent);

	SafeKillTimer(checkLeaderTimer);
}

public Action:LeaderPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsWiped()) {
		if (client == ctLeader) {
			SetLeader(CS_TEAM_CT);
			SendLeaderMessage(CS_TEAM_CT);
		} else if (client == tLeader) {
			SetLeader(CS_TEAM_T);
			SendLeaderMessage(CS_TEAM_T);
		}
	}
}

// Simply here to delay starting the timer
// so players can walk to their leader at
// start of the round
public Action:StartLeaderTimer(Handle timer) {
	checkLeaderTimer = CreateTimer(1.0, CheckLeaderTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:CheckLeaderTimer(Handle timer) {
	float ctPos[3];
	float tPos[3];
	if (ctLeader != -1) {
		GetClientEyePosition(ctLeader, ctPos);
	}
	if (tLeader != -1) {
		GetClientEyePosition(tLeader, tPos);
	}

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			float pos[3];
			GetClientEyePosition(i, pos);

			float distance = -1.0;
			if (GetClientTeam(i) == CS_TEAM_CT && ctLeader != -1) {
				distance = GetVectorDistance(pos, ctPos);
			} else if (GetClientTeam(i) == CS_TEAM_T && tLeader != -1) {
				distance = GetVectorDistance(pos, tPos);
			}

			if (distance > 350) {
				SDKHooks_TakeDamage(i, i, i, GetTrueDamage(i, 5.0), DMG_GENERIC);
				SendMessage(i, "%t", "TooFarFromLeader");
			}
		}
	}

	return Plugin_Continue;
}

public SetLeader(team) {
	if (team == CS_TEAM_CT) {
		ctLeader = GetRandomPlayerFromTeam(team);
		if (ctLeader != -1) {
			GetClientName(ctLeader, ctLeaderName, sizeof(ctLeaderName));
		}
	} else {
		tLeader = GetRandomPlayerFromTeam(team);
		if (tLeader != -1) {
			GetClientName(tLeader, tLeaderName, sizeof(tLeaderName));
		}
	}
}

public SendLeaderMessage(team) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			if (GetClientTeam(client) == team) {
				if (team == CS_TEAM_CT && ctLeader != -1) {
					SendMessage(client, "%t", "NewLeader", ctLeaderName);
				} else if (team == CS_TEAM_T && tLeader != -1) {
					SendMessage(client, "%t", "NewLeader", tLeaderName);
				}
			}
		}
	}
	SendMessageTeam(team, "%t", "FollowLeader");
}
