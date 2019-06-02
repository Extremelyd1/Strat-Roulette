public Action:Hook_DenyTransmit(entity, client) {
    if (entity != client) {
        if (IsClientInGame(entity)) {
            if (!IsPlayerAlive(client)) {
                if (GetClientTeam(entity) != GetClientTeam(client)) {
                        return Plugin_Handled;
                }
            } else {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}

public Action:Hook_StealthTransmit(entity, client) {
    if (entity != client) {
        if (IsClientInGame(entity)) {
            if (!IsPlayerAlive(client)) {
                if (GetClientTeam(entity) != GetClientTeam(client)) {
                        return Plugin_Handled;
                }
            } else {
                if (!stealthVisible[entity]) {
                    return Plugin_Handled;
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action:Hook_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
    if (g_Bomberman) {
        new victimHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
        if (victimHealth <= damage) {
            // Victim would have been killed by bomb damage

            // Check whether team is wiped
            bool ctWiped = true;
            bool tWiped = true;

            for (int client = 1; client <= MaxClients; client++) {
                if (IsClientInGame(client) && IsPlayerAlive(client)
                    && !IsFakeClient(client) && client != victim) {
                    if (GetClientTeam(client) == CS_TEAM_CT) {
                        ctWiped = false;
                    } else if (GetClientTeam(client) == CS_TEAM_T) {
                        tWiped = false;
                    }
                }
            }

            if (!ctWiped && !tWiped) {
                KillPlayer(victim, victim);
                return Plugin_Handled;
            }

            DataPack data = new DataPack();

            if (ctWiped) {
                data.WriteCell(CS_TEAM_CT);
            } else if (tWiped) {
                data.WriteCell(CS_TEAM_T);
            }

            // Wait 0.1 seconds before killing player manually,
            // to allow round end by bomb to be bypassed
            CreateTimer(0.1, WipeTeamTimer, data);

            return Plugin_Handled;
        }
    }

    if (g_Bodyguard) {
        if (victim != ctLeader && victim != tLeader) {
            return Plugin_Handled;
        }
    }

    if (g_BuddySystem) {
        new String:victimIdString[64];
        IntToString(victim, victimIdString, sizeof(victimIdString));
        float currentChickenHealth;
        if (chickenHealth.GetValue(victimIdString, currentChickenHealth)) {
            if (damage < currentChickenHealth) {
                chickenHealth.SetValue(victimIdString, currentChickenHealth - damage);
                return Plugin_Handled;
            }
            chickenHealth.Remove(victimIdString);
            return Plugin_Continue;
        }
    }

    if (g_BuddySystem || g_HotPotato) {
        if (g_HotPotato) {
            if (attacker != victim && victim != 0 && attacker != 0 &&
                GetClientTeam(victim) != GetClientTeam(attacker)) {
                SelectHotPotato(victim);
            }
        }

        return Plugin_Handled;
    }

    if (g_Vampire) {
		if (attacker == 0) {
			return Plugin_Continue;
		}

		new attackerHealth = GetEntProp(attacker, Prop_Send, "m_iHealth");
		if (IsClientInGame(attacker) && IsPlayerAlive(attacker) && !IsFakeClient(attacker)) {
			new giveHealth = RoundToNearest(attackerHealth + damage);
    		SetEntityHealth(attacker, giveHealth);
		}
	}

    if (g_MonkeySee) {
        return Plugin_Handled;
    }

    if (g_HeadShot) {
        if(damagetype == DMG_FALL
			|| damagetype == DMG_GENERIC
			|| damagetype == DMG_CRUSH
			|| damagetype == DMG_SLASH
			|| damagetype == DMG_BURN
			|| damagetype == DMG_VEHICLE
			|| damagetype == DMG_FALL
			|| damagetype == DMG_BLAST
			|| damagetype == DMG_SHOCK
			|| damagetype == DMG_SONIC
			|| damagetype == DMG_ENERGYBEAM
			|| damagetype == DMG_DROWN
			|| damagetype == DMG_PARALYZE
			|| damagetype == DMG_NERVEGAS
			|| damagetype == DMG_POISON
			|| damagetype == DMG_ACID
			|| damagetype == DMG_AIRBOAT
			|| damagetype == DMG_PLASMA
			|| damagetype == DMG_RADIATION
			|| damagetype == DMG_SLOWBURN
			|| attacker == 0
		) {
            return Plugin_Continue;
        }
		if (!(damagetype & CS_DMG_HEADSHOT)) {
            return Plugin_Handled;
        }
	}

    if (g_HitSwap) {
        if (attacker != victim && victim != 0 && attacker != 0) {
            float victimPos[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
            float attackerPos[3];
            GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPos);

            TeleportEntity(victim, attackerPos, NULL_VECTOR, NULL_VECTOR);
            TeleportEntity(attacker, victimPos, NULL_VECTOR, NULL_VECTOR);
        }
    }

    if (g_DontMiss) {
        char weaponname[128];
        Client_GetActiveWeaponName(attacker, weaponname, sizeof(weaponname));

        for (int i = 0; i < PRIMARY_LENGTH; i++) {
            if (StrEqual(weaponname, WeaponPrimary[i])) {
                DamagePlayer(attacker, -PrimaryDamage[i]);
                return Plugin_Continue;
            }
        }
        for (int i = 0; i < SECONDARY_LENGTH; i++) {
            if (StrEqual(weaponname, WeaponSecondary[i])) {
                DamagePlayer(attacker, -SecondaryDamage[i]);
                return Plugin_Continue;
            }
        }
    }

    return Plugin_Continue;
}