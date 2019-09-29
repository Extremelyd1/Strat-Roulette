static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}",	"{PINK}",	  "{GREEN}",
							   "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
							   "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
static char _colorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
							   "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

public int GetNumberOfStrats() {
	KeyValues kv = new KeyValues("Strats");

	if (!kv.ImportFromFile(STRAT_FILE)) {
		PrintToServer("Strat file could not be found!");

		delete kv;
		return -1;
	}

	if (!kv.GotoFirstSubKey(false)) {
		PrintToServer("No strats in strat file!");

		delete kv;
		return -1;
	}

	int numberOfStrats = 0;

	do {
		if (kv.GetDataType(NULL_STRING) == KvData_None) {
			numberOfStrats++;
		}
	} while (kv.GotoNextKey(false));

	delete kv;

	return numberOfStrats;
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
	// Shield = 11

	new primary = GetPlayerWeaponSlot(client, 0);
	new secondary = GetPlayerWeaponSlot(client, 1);
	new knife = GetPlayerWeaponSlot(client, 2);
	new c4Slot = GetPlayerWeaponSlot(client, 4);
	new shield = GetPlayerWeaponSlot(client, 11);

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

	if (shield > -1) {
		RemovePlayerItem(client, shield);
		RemoveEdict(shield);
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

public bool IsWiped() {
	bool ctWiped = true;
	bool tWiped = true;

	if (GetConVarInt(mp_respawn_on_death_ct) == 1) {
		ctWiped = false;
	}
	if (GetConVarInt(mp_respawn_on_death_t) == 1) {
		tWiped = false;
	}

	for (int client = 1; client <= MaxClients; client++) {
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

public void SafeKillTimer(Handle timer) {
	if (timer != INVALID_HANDLE) {
		CloseHandle(timer);
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
