public ConfigureWallhack() {
	int ctColor[3];
	ctColor[0] = 0;
	ctColor[1] = 0;
	ctColor[2] = 255;

	int tColor[3];
	tColor[0] = 255;
	tColor[1] = 255;
	tColor[2] = 0;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_SetTransmit, WallhackSetTransmitHook);

			if (GetClientTeam(client) == CS_TEAM_T) {
				CreateDynamicGlowProp(client, tColor);
			} else {
				CreateDynamicGlowProp(client, ctColor);
			}
		}
	}
}

public ResetWallhack() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_SetTransmit, WallhackSetTransmitHook);
		}
	}
}

public Action:WallhackSetTransmitHook(int entity, int client) {
	return Plugin_Continue;
}

public CreateDynamicGlowProp(int client, int color[3]) {
	int glowProp = CreateEntityByName("prop_dynamic_glow");

	char clientModel[128];
	GetClientModel(client, clientModel, sizeof(clientModel));

	DispatchKeyValue(glowProp, "model", clientModel);
	DispatchKeyValue(glowProp, "solid", "0");

	DispatchSpawn(glowProp);

	SetEntityRenderMode(glowProp, RENDER_GLOW);
	SetEntityRenderColor(glowProp, 0, 0, 0, 0);

	SetEntProp(glowProp, Prop_Send, "m_fEffects", 1);

	SetVariantString("!activator");
	AcceptEntityInput(glowProp, "SetParent", client, glowProp);
	SetVariantString("primary");
	AcceptEntityInput(glowProp, "SetParentAttachment", glowProp, glowProp, 0);

	SetEntProp(glowProp, Prop_Send, "m_bShouldGlow", true);
	SetEntProp(glowProp, Prop_Send, "m_nGlowStyle", 0);
	SetEntPropFloat(glowProp, Prop_Send, "m_flGlowMaxDist", 10000.0);

	int offset = GetEntSendPropOffs(glowProp, "m_clrGlow");

	if (offset == -1) {
		PrintToServer("Unable to find m_clrGlow offset");
		return;
	}

	for (int i = 0; i < 3; i++) {
		SetEntData(glowProp, offset + i, color[i], _, true);
	}
}
