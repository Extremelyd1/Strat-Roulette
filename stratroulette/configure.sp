public ConfigureThirdPerson() {
    if (StrEqual(ThirdPerson, "1")) {
		SetConVarInt(sv_allow_thirdperson, 1, true, false);
		CreateTimer(0.1, EnableThirdPerson);
	}
}

public ConfigureWeapons() {
    // For random weapon generate first whether it
    // should be primary of secondary
    new randomIntCat = -1;
    if (StrContains(Weapon, "weapon_random") != -1) {
        randomIntCat = GetRandomInt(0, 1);
    }

    char primary[256];
    char secondary[256];

    if (StrContains(Weapon, "weapon_primary_random") != -1 || randomIntCat == 0) {
        new randomInt = GetRandomInt(0, PRIMARY_LENGTH - 1);
        Format(primary, sizeof(primary), WeaponPrimary[randomInt]);
    }
    if (StrContains(Weapon, "weapon_secondary_random") != -1 || randomIntCat == 1) {
        new randomInt = GetRandomInt(0, SECONDARY_LENGTH - 1);
        Format(secondary, sizeof(secondary), WeaponSecondary[randomInt]);
    }

    // If we need to give a weapon
    if (!StrEqual(Weapon, "none")) {
		decl String:bit[10][80];
		new SumOfStrings = ExplodeString(Weapon, ";", bit, sizeof bit, sizeof bit[]);

		for (int string = 0; string < SumOfStrings; string++) {
            for (int j = 1; j <= MaxClients; j++) {
                if (IsClientInGame(j) && IsPlayerAlive(j) && !IsFakeClient(j)) {
                    if (!g_Zombies || GetClientTeam(j) == CS_TEAM_CT) {
                        if (StrEqual(bit[string], "weapon_primary_random")
                         || (StrEqual(bit[string], "weapon_random") && randomIntCat == 0)) {
                            GivePlayerItem(j, primary);
                        } else if (StrEqual(bit[string], "weapon_secondary_random")
                         || (StrEqual(bit[string], "weapon_random") && randomIntCat == 1)) {
                            GivePlayerItem(j, secondary);
                        } else {
                            GivePlayerItem(j, bit[string]);
                        }
                    }
                }
            }
        }
    }

    return 1;
}

public ConfigureArmorDefuser() {
    // Defuser
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == CS_TEAM_CT) {
                if (StrEqual(Defuser, "1")) {
                    SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
                }
            }
            if (!StrEqual(Armor, "0")) {
                new armorInt = StringToInt(Armor);
                Client_SetArmor(client, armorInt);
            }
            if (StrEqual(Helmet, "1")) {
                SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 1);
            }
        }
    }
}

public ConfigureHealth() {
    g_Health = StringToInt(Health);
    if (g_Health != 100) {
        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                if (!g_Zombies || GetClientTeam(client) == CS_TEAM_T) {
                    SetEntityHealth(client, g_Health);
                }
            }
        }
    }
}

public ConfigureDecoySound() {
    if (StrEqual(DecoySound, "1")) {
		g_DecoySound = true;
	} else {
		g_DecoySound = false;
	}
}

public ConfigureNoKnife() {
    if (StrEqual(NoKnife, "1")) {
        SetKnife(false);
    }
}

public ConfigureInfiniteAmmo() {
    if (StrEqual(InfiniteAmmo, "1") || StrEqual(InfiniteAmmo, "2")) {
		new SetAmmoInt = StringToInt(InfiniteAmmo);
		SetConVarInt(sv_infinite_ammo, SetAmmoInt, true, false);
	}
}

public ConfigureInfiniteNades() {
    if (StrEqual(InfiniteNade, "1")) {
		g_InfiniteNade = true;
        SetConVarInt(mp_death_drop_grenade, 0, true, false);
	} else {
		g_InfiniteNade = false;
	}
}

public ConfigureSpeed() {
    new Float:newPlayerSpeed = StringToFloat(PlayerSpeed);
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client)) {
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", newPlayerSpeed);
        }
    }
}

public ConfigureGravity() {
    new newPlayerGravity = StringToInt(PlayerGravity);

	if (newPlayerGravity != 800) {
		SetConVarInt(sv_gravity, newPlayerGravity, true, false);
	}
}

public ConfigureNoRecoil() {
    if (StrEqual(NoRecoil, "1")) {
		if (weapon_accuracy_nospread != INVALID_HANDLE) {
			SetConVarInt(weapon_accuracy_nospread, 1, true, false);
			SetConVarInt(weapon_recoil_cooldown, 0, true, false);
			SetConVarInt(weapon_recoil_decay1_exp, 99999, true, false);
			SetConVarInt(weapon_recoil_decay2_exp, 99999, true, false);
			SetConVarInt(weapon_recoil_decay2_lin, 99999, true, false);
			SetConVarInt(weapon_recoil_scale, 0, true, false);
			SetConVarInt(weapon_recoil_suppression_shots, 500, true, false);
		}
	}
}

public ConfigureNoScope() {
    if (StrEqual(NoScope, "1")) {
		g_NoScope = true;
	} else {
		g_NoScope = false;
	}
}

public ConfigureVampire() {
    if (StrEqual(Vampire, "1")) {
		g_Vampire = true;
	} else {
		g_Vampire = false;
	}
}

public ConfigurePlayerColors() {
    int colorR = 255;
	int colorG = 255;
	int colorB = 255;

	bool setNewColor = false;
	if (StrEqual(PColor, "black")) {
		colorR = 0;
		colorG = 0;
		colorB = 0;
		setNewColor = true;
	} else if (StrEqual(PColor, "pink")) {
		colorR = 255;
		colorG = 0;
		colorB = 255;
		setNewColor = true;
	}

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (setNewColor) {
                SetEntityRenderColor(client, colorR, colorG, colorB, 0);
            }
		}
	}
}

public ConfigureBackwards() {
    if (StrEqual(Backwards, "1")) {
		SetConVarInt(sv_accelerate, -5, true, false);
        SetConVarFloat(sv_airaccelerate, -0.5, true, false);
	}
}

public ConfigureFov() {
    new newFov = StringToInt(Fov);

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            SetEntProp(client, Prop_Send, "m_iDefaultFOV", newFov);
			SetEntProp(client, Prop_Send, "m_iFOV", newFov);
        }
    }
}

public ConfigureChickenDefuse() {
    if (StrEqual(ChickenDefuse, "1")) {
		g_ChickenDefuse = true;
	} else {
		g_ChickenDefuse = false;
	}
}

public ConfigureHeadshotOnly() {
    if (StrEqual(HeadShot, "1")) {
		g_HeadShot = true;
	} else {
		g_HeadShot = false;
	}
}

public ConfigureSlowMotion() {
    if (StrEqual(SlowMotion, "1")) {
		g_SlowMotion = true;
        CreateTimer(1.0, SlowMotionTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	} else {
		g_SlowMotion = false;
	}
}

public ConfigureWeirdRecoilView() {
    if (!StrEqual(RecoilView, "0.0555")) {
        new Float:newRecoilView = StringToFloat(RecoilView);

    	SetConVarFloat(weapon_recoil_view_punch_extra, newRecoilView, true, false);
    }
}

public ConfigureFriction() {
    if (StrEqual(AlwaysMove, "1")) {
		SetConVarInt(sv_friction, -1, true, false);
	}
}

public ConfigureDropWeapons() {
    if (StrEqual(DropWeapons, "1")) {
        g_DropWeapons = true;
        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                CreateNewDropWeaponsTimer(client);
            }
        }
        CreateTimer(5.0, DropWeaponsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_DropWeapons = false;
    }
}

public ConfigureOneInTheChamber() {
    if (StrEqual(OneInTheChamber, "1")) {
        g_OneInTheChamber = true;
        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                SetClipAmmo(client, 1);
            }
        }
        CreateTimer(0.1, SetWeaponAmmo, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_OneInTheChamber = false;
    }
}

public ConfigureLeader() {
    if (StrEqual(Leader, "1")) {
        g_Leader = true;
        SetLeader(CS_TEAM_CT);
        SetLeader(CS_TEAM_T);
        SendLeaderMessage(CS_TEAM_CT);
        SendLeaderMessage(CS_TEAM_T);

        int freezeTime = GetConVarInt(mp_freezetime);
        CreateTimer(freezeTime + 1.0, StartLeaderTimer);
    } else {
        g_Leader = false;
    }
}

public ConfigureAllOnMap() {
    if (StrEqual(AllOnMap, "1")) {
        SetConVarInt(mp_radar_showall, 1, true, false);
    }
}

public ConfigureInvisible() {
    if (StrEqual(Invisible, "1")) {
        for (int client = 1; client <= MaxClients; client++) {
    		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                SDKHook(client, SDKHook_SetTransmit, Hook_DenyTransmit);
            }
        }
    } else {
        for (int client = 1; client <= MaxClients; client++) {
    		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                SDKUnhook(client, SDKHook_SetTransmit, Hook_DenyTransmit);
            }
        }
    }
}

public ConfigureAxeFists() {
    if (StrEqual(Axe, "1")) {
        g_Axe = true;
        CreateTimer(1.0, CheckAxeFistsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else if (StrEqual(Fists, "1")) {
        g_Fists = true;
        CreateTimer(1.0, CheckAxeFistsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_Axe = false;
        g_Fists = false;
    }
}

public ConfigureBuddySystem() {
    if (StrEqual(BuddySystem, "1")) {
        g_BuddySystem = true;
        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                new chicken = CreateEntityByName("chicken");
                float playerPos[3];
                GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerPos);

                DispatchSpawn(chicken);
                SetEntProp(chicken, Prop_Send, "m_fEffects", 0);

                SDKHookEx(chicken, SDKHook_OnTakeDamage, OnTakeDamage);

                // Teleport chicken to player
                TeleportEntity(chicken, playerPos, NULL_VECTOR, NULL_VECTOR);

                // Set chicken to follow player
                SetEntPropEnt(chicken, Prop_Send, "m_leader", client);

                // Store client and chicken
                new String:playerIdString[64];
                IntToString(client, playerIdString, sizeof(playerIdString));
                chickenMap.SetValue(playerIdString, chicken);

                new String:chickenIdString[64];
                IntToString(chicken, chickenIdString, sizeof(chickenIdString));
                chickenHealth.SetValue(chickenIdString, 200.0);
            }
        }
        // Create timer to enforce leader of chicken
        CreateTimer(0.1, BuddyTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_BuddySystem = false;
    }
}

public ConfigureRandomNade() {
    if (StrEqual(RandomNade, "1")) {
        g_RandomNade = true;
        SetConVarInt(mp_death_drop_grenade, 0, true, false);
    } else {
        g_RandomNade = false;
    }
}

public ConfigureZombies() {
    if (StrEqual(Zombies, "1")) {
        g_Zombies = true;
    } else {
        g_Zombies = false;
    }
}

public ConfigureHitSwap() {
    if (StrEqual(HitSwap, "1")) {
        g_HitSwap = true;
    } else {
        g_HitSwap = false;
    }
}

public ConfigureRedGreen() {
    if (StrEqual(RedGreen, "1")) {
        g_RedGreen = true;
        CreateTimer(0.5, RedGreenDamageTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
        CreateNewRedGreenTimer();
    } else {
        g_RedGreen = false;
        g_RedLight = false;
    }
}

public ConfigureManhunt() {
    if (StrEqual(Manhunt, "1")) {
        g_Manhunt = true;
        SetLeader(CS_TEAM_CT);
        SetLeader(CS_TEAM_T);
        SendVIPMessage(CS_TEAM_CT);
        SendVIPMessage(CS_TEAM_T);
    } else {
        g_Manhunt = false;
    }
}

public ConfigureWinner() {
    if (StrEqual(Winner, "t")) {
        SetConVarInt(mp_default_team_winner_no_objective, -1, true, false);
    } else if (StrEqual(Winner, "draw")) {
        SetConVarInt(mp_default_team_winner_no_objective, 1, true, false);
    }
}

public ConfigureHotPotato() {
    if (StrEqual(HotPotato, "1")) {
        g_HotPotato = true;
        ctLeader = -1;
        int freezeTime = GetConVarInt(mp_freezetime);

        CreateTimer(freezeTime + 10.0, NewHotPotatoTimer);
    } else {
        g_HotPotato = false;
    }
}

public ConfigureKillRound() {
    if (StrEqual(KillRound, "1")) {
        g_KillRound = true;
        SetConVarInt(mp_ignore_round_win_conditions, 1, true, false);
    } else {
        g_KillRound = false;
    }
}

public ConfigureBomberman() {
    if (StrEqual(Bomberman, "1")) {
        g_Bomberman = true;
        SetConVarInt(mp_plant_c4_anywhere, 1, true, false);
        SetConVarInt(mp_c4timer, 10, true, false);
        SetConVarInt(mp_c4_cannot_be_defused, 1, true, false);
        SetConVarInt(mp_anyone_can_pickup_c4, 1, true, false);
        CreateTimer(0.1, CheckC4Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_Bomberman = false;
    }
}

public ConfigureDontMiss() {
    if (StrEqual(DontMiss, "1")) {
        g_DontMiss = true;
    } else {
        g_DontMiss = false;
    }
}

public ConfigureCrabWalk() {
    if (StrEqual(CrabWalk, "1")) {
        g_CrabWalk = true;
    } else {
        g_CrabWalk = false;
    }
}

public ConfigureRandomGuns() {
    if (StrEqual(RandomGuns, "1")) {
        g_RandomGuns = true;
        CreateTimer(1.0, RandomGunsTimer);
    } else {
        g_RandomGuns = false;
    }
}

public ConfigurePoison() {
    if (StrEqual(Poison, "1")) {
        smokeMap.Clear();
        g_Poison = true;
        CreateTimer(0.5, PoisonDamageTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_Poison = false;
    }
}

public ConfigureBodyguard() {
    if (StrEqual(Bodyguard, "1")) {
        g_Bodyguard = true;
        SetLeader(CS_TEAM_CT);
        SetLeader(CS_TEAM_T);

        SendVIPMessage(CS_TEAM_CT);
        SendVIPMessage(CS_TEAM_T);

        if (ctLeader != -1) {
            if (IsClientInGame(ctLeader) && IsPlayerAlive(ctLeader) && !IsFakeClient(ctLeader)) {
                GivePlayerItem(ctLeader, "weapon_fiveseven");
            }
        }
        if (tLeader != -1) {
            if (IsClientInGame(tLeader) && IsPlayerAlive(tLeader) && !IsFakeClient(tLeader)) {
                GivePlayerItem(tLeader, "weapon_fiveseven");
            }
        }

        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)
             && client != ctLeader && client != tLeader) {
                 GivePlayerItem(client, "weapon_shield");
            }
        }
    } else {
        g_Bodyguard = false;
    }
}

public ConfigureZeusRound() {
    if (StrEqual(ZeusRound, "1")) {
        g_ZeusRound = true;
    } else {
        g_ZeusRound = false;
    }
}

public ConfigurePocketTP() {
    if (StrEqual(PocketTP, "1")) {
        g_PocketTP = true;
        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client)) {
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
            }
        }
    } else {
        g_PocketTP = false;
    }
}
