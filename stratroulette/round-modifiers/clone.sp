new cloneEntities[MAXPLAYERS + 1];
new cloneWeaponEntities[MAXPLAYERS + 1];

public ConfigureClone() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			int entity = CreateEntityByName("prop_dynamic_override");

			char clientModel[128];
			GetClientModel(i, clientModel, sizeof(clientModel));

			DispatchKeyValue(entity, "model", clientModel);

			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", i);

			SetEntData(entity, g_offsCollisionGroup, 2, 4, true);

			float clientPos[3];
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", clientPos);

			float clientAngles[3];
			GetClientEyeAngles(i, clientAngles);

			TeleportEntity(entity, clientPos, clientAngles, NULL_VECTOR);

			DispatchSpawn(entity);
			ActivateEntity(entity);

			cloneEntities[i] = entity;

			int weapon = GiveCloneWeapon(entity);

			cloneWeaponEntities[i] = weapon;
		}
	}

	AddCommandListener(CloneLookAtWeaponListener, "+lookatweapon");
}

public ResetClone() {
	RemoveCommandListener(CloneLookAtWeaponListener, "+lookatweapon");
}

public Action:CloneLookAtWeaponListener(int client, const char[] command, int args) {
	if (!IsPlayerAlive(client)) {
		return Plugin_Continue;
	}

	int cloneEntity = cloneEntities[client];
	if (!IsValidEntity(cloneEntity) || cloneEntity < 1) {
		return Plugin_Continue;
	}

	float clientPosition[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPosition);

	float clientAngles[3];
	GetClientEyeAngles(client, clientAngles);

	clientAngles[0] = 0.0;

	float clonePosition[3];
	GetEntPropVector(cloneEntity, Prop_Send, "m_vecOrigin", clonePosition);

	float cloneAngles[3];
	GetEntPropVector(cloneEntity, Prop_Send, "m_angRotation", cloneAngles);

	TeleportEntity(client, clonePosition, cloneAngles, NULL_VECTOR);
	TeleportEntity(cloneEntity, clientPosition, clientAngles, NULL_VECTOR);

	AcceptEntityInput(cloneWeaponEntities[client], "kill");

	CreateTimer(0.1, DelayCloneWeaponTimer, client);

	return Plugin_Stop;
}

public Action:DelayCloneWeaponTimer(Handle timer, int client) {
	int weapon = GiveCloneWeapon(cloneEntities[client]);

	cloneWeaponEntities[client] = weapon;
}

public int GiveCloneWeapon(int cloneEntity) {
	int weapon = CreateEntityByName("prop_dynamic_override");

	DispatchKeyValue(weapon, "model", "models/weapons/v_rif_m4a1.mdl");

	SetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity", cloneEntity);

	SetVariantString("!activator");
	AcceptEntityInput(weapon, "SetParent", cloneEntity, weapon);

	SetVariantString("weapon_hand_R");
	AcceptEntityInput(weapon, "SetParentAttachment", weapon, weapon, 0);

	float weaponPos[3];
	GetEntPropVector(weapon, Prop_Send, "m_vecOrigin", weaponPos);

	weaponPos[0] -= 13.0;
	weaponPos[1] += 5.0;
	weaponPos[2] += 8.0;

	TeleportEntity(weapon, weaponPos, NULL_VECTOR, NULL_VECTOR);

	SetVariantString("weapon_hand_R");
	AcceptEntityInput(weapon, "SetParentAttachmentMaintainOffset", weapon, weapon, 0);

	DispatchSpawn(weapon);

	return weapon;
}
