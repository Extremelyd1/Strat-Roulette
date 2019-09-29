bool stealthActive = false;

new stealthVisible[MAXPLAYERS + 1];

public ConfigureStealth() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_SetTransmit, StealthSetTransmitHook);
		}
	}

	stealthActive = true;
}

public ResetStealth() {
	stealthActive = false;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			stealthVisible[client] = false;
			SDKUnhook(client, SDKHook_SetTransmit, StealthSetTransmitHook);
		}
	}
}

public Action:StealthOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (stealthActive) {
		int walkMask = IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT;
		int otherMask = IN_ATTACK | IN_RELOAD;
		if (buttons & otherMask || (buttons & walkMask && !(buttons & IN_SPEED))) {
			stealthVisible[client] = true;
		} else {
			stealthVisible[client] = false;
		}
	}
}

public Action:StealthSetTransmitHook(int entity, int client) {
	if (entity != client) {
		if (IsClientInGame(entity)) {
			if (!IsPlayerAlive(client)) {
				if (GetClientTeam(entity) != GetClientTeam(client)) {
						return Plugin_Handled;
				}
			} else {
				if (!stealthVisible[entity]) {
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}
