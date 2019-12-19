new c4Chicken = -1;

public ConfigureChickenDefuse() {
	SetConVarInt(mp_c4timer, 70, true, false);

	int client = GetRandomPlayerFromTeam(CS_TEAM_T);

	c4Chicken = CreateEntityByName("chicken");

	DispatchSpawn(c4Chicken);

	SetEntProp(c4Chicken, Prop_Data, "m_takedamage", 0);

	float tpPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", tpPos);

	TeleportEntity(c4Chicken, tpPos, NULL_VECTOR, NULL_VECTOR);

	new c4 = CreateEntityByName("planted_c4");
	DispatchSpawn(c4);

	tpPos[2] += 12.0;

	TeleportEntity(c4, tpPos, Float: { 0.0, 0.0, 0.0 }, NULL_VECTOR);

	SetVariantString("!activator");
	AcceptEntityInput(c4, "SetParent", c4Chicken, c4, 0);

	SetEntData(c4, g_offsBombTicking, 1, 1, true);

	SetEntPropEnt(c4Chicken, Prop_Send, "m_leader", client);
}

public ResetChickenDefuse() {
	SetConVarInt(mp_c4timer, 40, true, false);

	if (c4Chicken != -1 && IsValidEntity(c4Chicken)) {
		int chickenRef = EntIndexToEntRef(c4Chicken);
		AcceptEntityInput(chickenRef, "kill");
	}

	c4Chicken = -1;
}
