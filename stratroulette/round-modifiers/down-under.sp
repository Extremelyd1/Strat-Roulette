bool downUnderActive = false;

new downUnderArray[MAXPLAYERS + 1];

public ConfigureDownUnder() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			float position[3];
			GetClientEyePosition(client, position);

			int entity = CreateViewEntity(client, position);

			float angle[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angle);

			angle[2] = 180.0;

			TeleportEntity(entity, NULL_VECTOR, angle, NULL_VECTOR);

			downUnderArray[client] = entity;
		}
	}

	downUnderActive = true;
}

public ResetDownUnder() {
	downUnderActive = false;

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			// Reset player angle
			float angles[3];
			GetClientEyeAngles(i, angles);

			angles[2] = 0.0;

			TeleportEntity(i, NULL_VECTOR, angles, NULL_VECTOR);

			// Reset view
			SetClientViewEntity(i, i);
		}
	}
}

public Action:DownUnderOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (downUnderActive) {
		// Get entity that belongs to player
		new entity = downUnderArray[client];
		if (entity != -1) {
			if (IsValidEntity(entity)) {
				// Set position and angles
				float eyeAngles[3];
				GetClientEyeAngles(client, eyeAngles);

				float position[3];
				GetClientEyePosition(client, position);

				eyeAngles[2] = 180.0;

				TeleportEntity(entity, position, eyeAngles, NULL_VECTOR);

				SetClientViewEntity(client, entity);
			}
		}
	}
}

public int CreateViewEntity(int client, float pos[3]) {

	int entity = CreateEntityByName("env_sprite");
	if (entity != -1) {
		DispatchKeyValue(entity, "model", SPRITE);
		DispatchKeyValue(entity, "renderamt", "0");
		DispatchKeyValue(entity, "rendercolor", "0 0 0");
		DispatchSpawn(entity);

		float angle[3];
		GetClientEyeAngles(client, angle);

		TeleportEntity(entity, pos, angle, NULL_VECTOR);
		TeleportEntity(client, NULL_VECTOR, angle, NULL_VECTOR);

		SetClientViewEntity(client, entity);
		return entity;
	}

	return -1;
}
