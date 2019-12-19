static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}",	"{PINK}",	  "{GREEN}",
							   "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
							   "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
static char _colorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
							   "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

public ArrayList GetEnabledStrats() {
	KeyValues kv = new KeyValues("Strats");

	if (!kv.ImportFromFile(STRAT_FILE)) {
		PrintToServer("Strat file could not be found!");

		delete kv;
		return new ArrayList();
	}

	if (!kv.GotoFirstSubKey(false)) {
		PrintToServer("No strats in strat file!");

		delete kv;
		return new ArrayList();
	}

	ArrayList enabledStrats = new ArrayList();

	int index = 1;

	do {
		char disabled[3];
		kv.GetString("disable", disabled, sizeof(disabled), "0");

		if (!StrEqual(disabled, "0")) {
			index++;
			continue;
		}

		char mapName[128];
		GetCurrentMap(mapName, sizeof(mapName));

		char restrictedMaps[2560];
		kv.GetString("restricted", restrictedMaps, sizeof(restrictedMaps), "0");

		if (StrEqual(restrictedMaps, "0")) {
			enabledStrats.Push(index);
			index++;
			continue;
		}

		char mapList[10][80];
		new numberOfStrings = ExplodeString(restrictedMaps, ";", mapList, sizeof(mapList), sizeof (mapList[]));

		for (int i = 0; i < numberOfStrings; i++) {
			if (StrEqual(mapList[i], mapName)) {
				enabledStrats.Push(index);
				break;
			}
		}

		index++;
	} while (kv.GotoNextKey(false));

	delete kv;

	return enabledStrats;
}

public SendMessage(int client, String:szMessage[], any:...) {
	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %d", client);
	}

	if (!IsClientInGame(client)) {
		ThrowError("Client %d is not in game", client);
	}

	decl String:szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);

	VFormat(szCMessage, sizeof(szCMessage), szMessage, 3);

	Colorize(szCMessage, MAX_MESSAGE_LENGTH);

	Format(szCMessage, sizeof(szCMessage), " \x01\x0B\x01%s", szCMessage);

	PrintToChat(client, "%s", szCMessage);
}

public SendMessageAll(String:szMessage[], any:...) {
	decl String:szBuffer[MAX_MESSAGE_LENGTH];

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);

			Colorize(szBuffer, MAX_MESSAGE_LENGTH);

			Format(szBuffer, sizeof(szBuffer), " \x01\x0B\x01%s", szBuffer);

			PrintToChat(i, "%s", szBuffer);
		}
	}
}

public SendMessageAlive(String:szMessage[], any:...) {
	decl String:szBuffer[MAX_MESSAGE_LENGTH];

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i)) {
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);

			Colorize(szBuffer, MAX_MESSAGE_LENGTH);

			Format(szBuffer, sizeof(szBuffer), " \x01\x0B\x01%s", szBuffer);

			PrintToChat(i, "%s", szBuffer);
		}
	}
}

public SendMessageTeam(int team, String:szMessage[], any:...) {
	decl String:szBuffer[MAX_MESSAGE_LENGTH];

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			if (team == GetClientTeam(i)) {
				SetGlobalTransTarget(i);
				VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);

				Colorize(szBuffer, MAX_MESSAGE_LENGTH);

				Format(szBuffer, sizeof(szBuffer), " \x01\x0B\x01%s", szBuffer);

				PrintToChat(i, "%s", szBuffer);
			}
		}
	}
}

public SendCenterText(int client, String:szMessage[], any:...) {
	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %d", client);
	}

	if (!IsClientInGame(client)) {
		ThrowError("Client %d is not in game", client);
	}

	decl String:szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);

	VFormat(szCMessage, sizeof(szCMessage), szMessage, 3);

	Colorize(szCMessage, MAX_MESSAGE_LENGTH);

	Format(szCMessage, sizeof(szCMessage), " \x01\x0B\x01%s", szCMessage);

	PrintCenterText(client, "%s", szCMessage);
}

public int GetRandomPlayer() {
	ArrayList players = new ArrayList();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			players.Push(client);
		}
	}

	if (players.Length > 0) {
		int randomIndex = GetRandomInt(0, players.Length - 1);

		return players.Get(randomIndex);
	}

	return -1;
}

public int GetRandomPlayerFromTeam(int team) {
	ArrayList players = new ArrayList();

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == team) {
				players.Push(client);
			}
		}
	}

	if (players.Length > 0) {
		int randomIndex = GetRandomInt(0, players.Length - 1);

		return players.Get(randomIndex);
	}

	return -1;
}

public RemoveWeapons() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			RemoveWeaponsClient(client);
		}
	}
}

stock RemoveWeaponsClient(int client, bool removeC4=false, bool removeKnife=false) {
	// Primary = 0
	// Secondary = 1
	// Knife = 2
	// C4 = 4
	// Shield, Healthshot = 11
	// Tablet = 12

	new primary = GetPlayerWeaponSlot(client, 0);
	new secondary = GetPlayerWeaponSlot(client, 1);
	new knife = GetPlayerWeaponSlot(client, 2);
	new grenade = GetPlayerWeaponSlot(client, 3);
	new c4Slot = GetPlayerWeaponSlot(client, 4);
	new shield_health = GetPlayerWeaponSlot(client, 11);
	new tablet = GetPlayerWeaponSlot(client, 12);

	if (primary > -1) {
		RemovePlayerItem(client, primary);
		RemoveEdict(primary);
	}

	if (secondary > -1) {
		RemovePlayerItem(client, secondary);
		RemoveEdict(secondary);
	}

	if (removeKnife && knife > -1) {
		RemovePlayerItem(client, knife);
		RemoveEdict(knife);
	}

	while (grenade != -1) {
		RemovePlayerItem(client, grenade);
		RemoveEdict(grenade);

		grenade = GetPlayerWeaponSlot(client, 3);
	}

	new c4SlotBuffer = -1;

	char classname[128];
	while (c4Slot != -1) {
		GetEdictClassname(c4Slot, classname, sizeof(classname));

		if (!removeC4 && StrEqual(classname, "weapon_c4")) {
			c4SlotBuffer = c4Slot;

			RemovePlayerItem(client, c4Slot);
		} else {
			RemovePlayerItem(client, c4Slot);

			RemoveEdict(c4Slot);
		}

		c4Slot = GetPlayerWeaponSlot(client, 4);
	}

	if (c4SlotBuffer != -1) {
		EquipPlayerWeapon(client, c4SlotBuffer);
	}


	while (shield_health != -1) {
		RemovePlayerItem(client, shield_health);
		RemoveEdict(shield_health);

		shield_health = GetPlayerWeaponSlot(client, 11);
	}

	if (tablet > -1) {
		RemovePlayerItem(client, tablet);
		RemoveEdict(tablet);
	}
}

public RemoveNades() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			for (int j = 0; j < 6; j++) {
				SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, GrenadesAll[j]);
			}
		}
	}
}

public SetKnife(bool add) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetKnifeClient(client, add);
		}
	}
}

// TODO: This causes a memory leak when switching between giving and removing a knife
public SetKnifeClient(int client, bool add) {
	new knife = GetPlayerWeaponSlot(client, 2);
	if (add) {
		if (knife == -1) {
			new newKnife = GivePlayerItem(client, "weapon_knife");
			EquipPlayerWeapon(client, newKnife);
		}
	} else {
		if (knife != -1) {
			RemovePlayerItem(client, knife);
			RemoveEdict(knife);
		}
	}
}

public GiveAllPlayersItem(char[] item) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			GivePlayerItem(client, item);
		}
	}
}

stock bool IsWiped(int excludeClient = -1) {
	bool ctWiped = true;
	bool tWiped = true;

	if (GetConVarInt(mp_respawn_on_death_ct) == 1) {
		ctWiped = false;
	}
	if (GetConVarInt(mp_respawn_on_death_t) == 1) {
		tWiped = false;
	}

	for (int client = 1; client <= MaxClients; client++) {
		if (client == excludeClient) {
			continue;
		}

		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				ctWiped = false;
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				tWiped = false;
			}
		}
	}

	return ctWiped || tWiped;
}

stock void HealPlayer(int client, int amount, bool exceedCap=false) {
	new currentHealth = GetEntProp(client, Prop_Send, "m_iHealth");
	new newHealth = currentHealth + amount;

	if (!exceedCap && newHealth > health) {
		newHealth = health;
	}

	SetEntityHealth(client, newHealth);
}

public SetClipAmmo(weapon, ammo) {
	SetEntProp(weapon, Prop_Send, "m_iClip1", ammo);
}

public SetActiveWeaponClipAmmo(client, ammo) {
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (weapon < 1) {
		return;
	}

	SetClipAmmo(weapon, ammo);
}

public int GetClipAmmo(weapon) {
	return GetEntProp(weapon, Prop_Send, "m_iClip1");
}

public int GetActiveWeaponClipAmmo(client) {
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if(weapon < 1) {
		return -1;
	}

	return GetClipAmmo(weapon);
}

public SetReserveAmmo(weapon, ammo) {
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
}

public SetActiveWeaponReserveAmmo(client, ammo) {
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if(weapon < 1) {
		return;
	}

	SetReserveAmmo(weapon, ammo);
}

public GetReserveAmmo(weapon) {
	return GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
}

public GetActiveWeaponReserveAmmo(client) {
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if(weapon < 1) {
		return -1;
	}

	return GetReserveAmmo(weapon);
}

stock void Colorize(String:msg[], int size, bool stripColor = false) {
	for (int colorNameIndex = 0; colorNameIndex < sizeof(_colorNames); colorNameIndex++) {
		if (stripColor) {
			ReplaceString(msg, size, _colorNames[colorNameIndex], "");  // replace with white
		} else {
			ReplaceString(msg, size, _colorNames[colorNameIndex], _colorCodes[colorNameIndex]);
		}
	}
}

// Precache & prepare download for overlays & decals
stock void PrecacheDecalAnyDownload(char[] sOverlay) {
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%s.vmt", sOverlay);
	PrecacheDecal(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", sOverlay);
	AddFileToDownloadsTable(sBuffer);

	Format(sBuffer, sizeof(sBuffer), "%s.vtf", sOverlay);
	PrecacheDecal(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", sOverlay);
	AddFileToDownloadsTable(sBuffer);
}

// Show overlay to a client with lifetime | 0.0 = no auto remove
stock void ShowOverlay(int client, char[] path, float lifetime) {
	if (!IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client)) {
		return;
	}

	ClientCommand(client, "r_screenoverlay \"%s.vtf\"", path);

	if (lifetime != 0.0) {
		CreateTimer(lifetime, DeleteOverlay, GetClientUserId(client));
	}
}

// Show overlay to all clients with lifetime | 0.0 = no auto remove
stock void ShowOverlayAll(char[] path, float lifetime) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i)) {
			continue;
		}

		ClientCommand(i, "r_screenoverlay \"%s.vtf\"", path);

		if (lifetime != 0.0) {
			CreateTimer(lifetime, DeleteOverlay, GetClientUserId(i));
		}
	}
}

stock void RemoveOverlayAll() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i)) {
			continue;
		}

		ClientCommand(i, "r_screenoverlay \"\"");
	}
}

// Remove overlay from a client - Timer!
stock Action DeleteOverlay(Handle timer, any userid) {

	int client = GetClientOfUserId(userid);
	if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client)) {
		return;
	}

	ClientCommand(client, "r_screenoverlay \"\"");
}

public void SafeKillTimer(&Handle:timer) {
	if (timer != INVALID_HANDLE) {
		CloseHandle(timer);
		timer = INVALID_HANDLE;
	}
}

public float GetTrueDamage(int client, float damage) {
	int armor = Client_GetArmor(client);

	if (armor > 0) {
		return damage * 2;
	}

	return damage;
}

public float GetReducedDamage(int client, float damage) {
	int armor = Client_GetArmor(client);

	if (armor > 0) {
		return damage / 2;
	}

	return damage;
}

public void SDKReload(int weapon) {
	if (hReload != null) {
		SDKCall(hReload, weapon);
	}
}

stock Client_SetArmor(client, value) {
	SetEntProp(client, Prop_Data, "m_ArmorValue", value);
}

stock Client_GetArmor(client) {
	return GetEntProp(client, Prop_Data, "m_ArmorValue");
}

stock Client_SetHideHud(client, flags) {
	SetEntProp(client, Prop_Send, "m_iHideHUD", flags);
}

stock Client_GetActiveWeapon(client) {
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

	if (!IsValidEntity(weapon)) {
		return INVALID_ENT_REFERENCE;
	}

	return weapon;
}

stock Client_GetActiveWeaponName(client, String:buffer[], size) {
	new weapon = Client_GetActiveWeapon(client);

	if (weapon == INVALID_ENT_REFERENCE) {
		buffer[0] = '\0';
		return INVALID_ENT_REFERENCE;
	}

	Entity_GetClassName(weapon, buffer, size);

	return weapon;
}

stock Entity_GetClassName(entity, String:buffer[], size) {
	return GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);
}

public int CreateViewEntity() {

	int entity = CreateEntityByName("env_sprite");
	if (entity != -1) {
		DispatchKeyValue(entity, "model", SPRITE);
		DispatchKeyValue(entity, "renderamt", "0");
		DispatchKeyValue(entity, "rendercolor", "0 0 0");
		DispatchSpawn(entity);

		return entity;
	}

	return -1;
}

public FitPlayerUp(int client, float startPos[3], float interval, int tries) {
	bool success = false;

	startPos[2] = startPos[2] - interval;

	float mins[3];
	mins[0] = -CLIENTWIDTH / 2;
	mins[1] = -CLIENTWIDTH / 2;
	mins[2] = 0.0;

	float maxs[3];
	maxs[0] = CLIENTWIDTH / 2;
	maxs[1] = CLIENTWIDTH / 2;
	maxs[2] = CLIENTHEIGHT;

	while (!success && tries > 0) {
		startPos[2] = startPos[2] + interval;

		new Handle:hitboxTrace = TR_TraceHullFilterEx(startPos, startPos, mins, maxs, MASK_PLAYERSOLID, PlayerRayFilter, client);

		if (!TR_DidHit(hitboxTrace)) {
			TeleportEntity(client, startPos, NULL_VECTOR, NULL_VECTOR);
			success = true;
		} else {
			tries--;
		}

		CloseHandle(hitboxTrace);
	}
}

stock any:Math_Max(any:value, any:max) {
	if (value > max) {
		value = max;
	}

	return value;
}
