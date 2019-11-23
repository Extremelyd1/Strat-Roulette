Menu currentVoteMenu;
bool isVoteStarted = false;
new StringMap:roundVotes;

public ForceEndVote() {
	if (isVoteStarted) {
		currentVoteMenu.Cancel();

		delete currentVoteMenu;
		delete roundVotes;
		isVoteStarted = false;
	}
}

public EndRoundVote() {
	if (isVoteStarted) {
		if (roundVotes.Size > 0) {
			ArrayList highestVotes = new ArrayList();
			int maxVotes = 0;

			StringMapSnapshot snapshot = roundVotes.Snapshot();
			for (int i = 0; i < snapshot.Length; i++) {
				char key[64];
				snapshot.GetKey(i, key, sizeof(key));

				int roundVoteNumber;
				if (roundVotes.GetValue(key, roundVoteNumber)) {
					if (roundVoteNumber > maxVotes) {
						maxVotes = roundVoteNumber;
						highestVotes.Clear();
					}
					if (roundVoteNumber >= maxVotes) {
						highestVotes.PushString(key);
					}
				}
			}

			delete snapshot;

			int randomIndex = GetRandomInt(0, highestVotes.Length - 1);
			char winningRoundString[32];
			highestVotes.GetString(randomIndex, winningRoundString, sizeof(winningRoundString));

			KeyValues kv = new KeyValues("Strats");
			kv.ImportFromFile(STRAT_FILE);

			if (!kv.JumpToKey(winningRoundString)) {
				PrintToServer("Strat number %s could not be found!", winningRoundString);

				delete kv;
				return;
			}

			char roundName[256];
			kv.GetString("name", roundName, sizeof(roundName), "No name round!");

			delete kv;

			Format(voteRoundNumber, sizeof(voteRoundNumber), winningRoundString);
			nextRoundVoted = true;

			for (new i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && !IsFakeClient(i)) {
					char translatedRoundName[128];
					Format(translatedRoundName, sizeof(translatedRoundName), "%T", roundName, i);
					SendMessage(i, "%t", "RoundVotingFinished", translatedRoundName);
				}
			}
		}

		currentVoteMenu.Cancel();

		delete roundVotes;
		delete currentVoteMenu;

		isVoteStarted = false;
	}
}

public PlayerDeathCheckVote(int client) {
	if (g_AllowVoting.IntValue == 0) {
		return;
	}
	
	if (!isVoteStarted) {
		CreateRoundVoteMenu();
	}

	currentVoteMenu.Display(client, 180);
}

public CreateRoundVoteMenu() {
	if (currentVoteMenu != INVALID_HANDLE) {
		delete currentVoteMenu;
	}

	roundVotes = CreateTrie();

	Menu menu = new Menu(VoteMenuHandler, MENU_ACTIONS_ALL);
	menu.SetTitle("RoundVoteTitle");

	ArrayList options = GetEnabledStrats();

	for (int i = 1; i < 6; i++) {
		if (options.Length == 0) {
			break;
		}

		int randomRound = options.Get(GetRandomInt(0, options.Length - 1));

		options.Erase(options.FindValue(randomRound));

		char randomRoundString[16];
		IntToString(randomRound, randomRoundString, sizeof(randomRoundString));

		KeyValues kv = new KeyValues("Strats");
		kv.ImportFromFile(STRAT_FILE);

		if (!kv.JumpToKey(randomRoundString)) {
			PrintToServer("Strat number %s could not be found for voting!", randomRoundString);

			delete kv;
			continue;
		}

		char roundName[256];
		kv.GetString("name", roundName, sizeof(roundName), "No name round!");
		Colorize(roundName, sizeof(roundName), true);

		menu.AddItem(randomRoundString, roundName);

		delete kv;
	}

	menu.ExitButton = false;

	currentVoteMenu = menu;

	isVoteStarted = true;
}

public int VoteMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		// Param1 is client, param2 is selected item index
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		int currentValue;
		if (roundVotes.GetValue(info, currentValue)) {
			roundVotes.SetValue(info, currentValue + 1);
		} else {
			roundVotes.SetValue(info, 1);
		}
	}

	if (action == MenuAction_DisplayItem) {
		/* Get the display string, we'll use it as a translation phrase */
		char display[64];
		menu.GetItem(param2, "", 0, _, display, sizeof(display));

		/* Translate the string to the client's language */
		char buffer[255];
		Format(buffer, sizeof(buffer), "%T", display, param1);

		/* Override the text */
		return RedrawMenuItem(buffer);
	}

	if (action == MenuAction_Display) {
		/* Panel Handle is the second parameter */
		Panel panel = view_as<Panel>(param2);

		/* Translate to our phrase */
		char buffer[255];
		Format(buffer, sizeof(buffer), "%T", "RoundVoteTitle", param1);

		panel.SetTitle(buffer);
	}

	return 0;
}
