bool captchaActive = false;

char captchaAnswer[64];
ArrayList captchaClients;

Handle captchaTimer;

public ConfigureCaptcha() {
	captchaClients = new ArrayList();

	float randomFloat = GetRandomFloat(2.0, 5.0);
	captchaTimer = CreateTimer(GetConVarInt(mp_freezetime) + randomFloat, SendCaptchaTimer);

	captchaActive = true;
}

public ResetCaptcha() {
	captchaActive = false;

	delete captchaClients;

	SafeKillTimer(captchaTimer);
}

public Action:CaptchaOnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	if (captchaActive) {
		if (captchaClients.FindValue(client) != -1) {
			if (StrEqual(sArgs, captchaAnswer)) {
				GivePlayerItem(client, primaryWeapon);
				GivePlayerItem(client, secondaryWeapon);
				captchaClients.Erase(captchaClients.FindValue(client));
			} else {
				SendMessage(client, "%t", "CaptchaWrong");
			}
			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

public Action:SendCaptchaTimer(Handle timer) {
	int randomInt1 = GetRandomInt(5, 20);
	int randomInt2 = GetRandomInt(5, 20);

	IntToString(randomInt1 + randomInt2, captchaAnswer, sizeof(captchaAnswer));

	SendMessageAll("%t", "CaptchaQuestion", randomInt1, randomInt2);
	SendMessageAlive("%t", "CaptchaTypeAnswerChat");

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			// Client is not on list
			if (captchaClients.FindValue(client) == -1) {
				captchaClients.Push(client);
				RemoveWeaponsClient(client);
			}
		}
	}

	float randomFloat = GetRandomFloat(8.0, 15.0);
	captchaTimer = CreateTimer(randomFloat, SendCaptchaTimer);

	return Plugin_Continue;
}
