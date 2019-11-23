bool blackoutActive = false;

public ConfigureBlackout() {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			float randomFloat = GetRandomFloat(5.0, 10.0);
			CreateTimer(randomFloat, BlackoutFadeOutTimer1, i);
		}
	}

	blackoutActive = true;
}

public ResetBlackout() {
	blackoutActive = false;
}

public Action:BlackoutFadeOutTimer1(Handle timer, int client) {
	if (!blackoutActive) {
		return Plugin_Stop;
	}

	BlackoutClient(client, false, 200, 1024, 512);

	CreateTimer(2.0, BlackoutFadeInTimer1, client);

	return Plugin_Stop;
}

public Action:BlackoutFadeInTimer1(Handle timer, int client) {
	if (!blackoutActive) {
		return Plugin_Stop;
	}

	BlackoutClient(client, true, 200, 1024, 512);

	CreateTimer(2.5, BlackoutFadeOutTimer2, client);

	return Plugin_Stop;
}

public Action:BlackoutFadeOutTimer2(Handle timer, int client) {
	if (!blackoutActive) {
		return Plugin_Stop;
	}

	BlackoutClient(client, false, 220, 512, 512);

	CreateTimer(1.0, BlackoutFadeInTimer2, client);

	return Plugin_Stop;
}

public Action:BlackoutFadeInTimer2(Handle timer, int client) {
	if (!blackoutActive) {
		return Plugin_Stop;
	}

	BlackoutClient(client, true, 220, 512, 512);

	CreateTimer(2.0, BlackoutFadeOutTimer3, client);

	return Plugin_Stop;
}

public Action:BlackoutFadeOutTimer3(Handle timer, int client) {
	if (!blackoutActive) {
		return Plugin_Stop;
	}

	BlackoutClient(client, false, 255, 256, 2048);

	CreateTimer(3.0, BlackoutFadeInTimer3, client);

	return Plugin_Stop;
}

public Action:BlackoutFadeInTimer3(Handle timer, int client) {
	if (!blackoutActive) {
		return Plugin_Stop;
	}

	BlackoutClient(client, true, 255, 256, 2048);

	float randomFloat = GetRandomFloat(10.0, 15.0);
	CreateTimer(randomFloat, BlackoutFadeOutTimer1, client);

	return Plugin_Stop;
}

public BlackoutClient(int client, bool fadeIn, int alpha, int fadeOutTime, int holdTime) {
	new Handle:userMessage = StartMessageOne("Fade", client, USERMSG_RELIABLE);

	if (userMessage == INVALID_HANDLE) {
		return;
	}

	new color[4];
	color[0] = 0;
	color[1] = 0;
	color[2] = 0;
	color[3] = alpha;

	PbSetInt(userMessage,   "duration",   fadeOutTime);
	PbSetInt(userMessage,   "hold_time",  holdTime);
	if (fadeIn) {
		PbSetInt(userMessage,   "flags",      0x0011);
	} else {
		PbSetInt(userMessage,   "flags",      0x0012);
	}
	PbSetColor(userMessage, "clr",        color);

	EndMessage();
}
