public ConfigurePlayerColors(char color[500]) {
	int colorR = 255;
	int colorG = 255;
	int colorB = 255;

	bool setNewColor = false;
	if (StrEqual(color, "black")) {
		colorR = 0;
		colorG = 0;
		colorB = 0;
		setNewColor = true;
	} else if (StrEqual(color, "pink")) {
		colorR = 255;
		colorG = 0;
		colorB = 255;
		setNewColor = true;
	}

	if (setNewColor) {
		for (int client = 1; client <= MaxClients; client++) {
			if (IsClientInGame(client) && IsPlayerAlive(client)) {
				SetEntityRenderColor(client, colorR, colorG, colorB, 0);
			}
		}
	}
}

public ResetPlayerColors() {
	// Not sure if necessary
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntityRenderColor(client, 255, 255, 255, 0);
		}
	}
}
