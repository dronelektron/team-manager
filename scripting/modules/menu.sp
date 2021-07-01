void CreateTeamManagerMenu(int client) {
    Menu menu = new Menu(MenuHandler_TeamManager);

    menu.SetTitle("%T", TEAM_MANAGER, client);

    AddFormattedItem(menu, MOVE_PLAYER, client);
    AddFormattedItem(menu, SWAP_TEAMS, client);
    AddFormattedItem(menu, SCRAMBLE_TEAMS, client);
    AddFormattedItem(menu, BALANCE_TEAMS, client);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_TeamManager(Menu menu, MenuAction action, int param1, int param2) {
    if (IsMenuItemSelected(menu, action)) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, MOVE_PLAYER)) {
            CreateMovePlayerMenu(param1);
        } else if (StrEqual(info, SWAP_TEAMS)) {
            SwapTeams();
        } else if (StrEqual(info, SCRAMBLE_TEAMS)) {
            ScrambleTeams();
        } else if (StrEqual(info, BALANCE_TEAMS)) {
            CreateBalanceTeamsMenu(param1);
        }
    }

    return 0;
}

void CreateMovePlayerMenu(int client) {
    Menu menu = new Menu(MenuHandler_MovePlayer);

    menu.SetTitle("%T", MOVE_PLAYER, client);

    AddFormattedItem(menu, IMMEDIATELY, client);
    AddFormattedItem(menu, AFTER_DEATH, client);
    AddFormattedItem(menu, AT_THE_END_OF_THE_ROUND, client);
    AddFormattedItem(menu, TO_SPECTATORS, client);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MovePlayer(Menu menu, MenuAction action, int param1, int param2) {
    if (IsMenuItemSelected(menu, action)) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, IMMEDIATELY)) {
            SetMovePlayerType(param1, MovePlayerType_Immediately);
        } else if (StrEqual(info, AFTER_DEATH)) {
            SetMovePlayerType(param1, MovePlayerType_AfterDeath);
        } else if (StrEqual(info, AT_THE_END_OF_THE_ROUND)) {
            SetMovePlayerType(param1, MovePlayerType_RoundEnd);
        } else if (StrEqual(info, TO_SPECTATORS)) {
            SetMovePlayerType(param1, MovePlayerType_ToSpectators);
        }

        CreatePlayersMenu(param1);
    }

    return 0;
}

void CreateBalanceTeamsMenu(int client) {
    Menu menu = new Menu(MenuHandler_BalanceTeams);

    menu.SetTitle("%T", BALANCE_TEAMS, client);

    AddFormattedItem(menu, MOVE_EXCESS_PLAYERS_TO_SPECTATORS, client);
    AddFormattedItem(menu, DISTRIBUTE_EXCESS_PLAYERS, client);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_BalanceTeams(Menu menu, MenuAction action, int param1, int param2) {
    if (IsMenuItemSelected(menu, action)) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, MOVE_EXCESS_PLAYERS_TO_SPECTATORS)) {
            MoveExcessPlayers(MoveExcessPlayerType_ToSpectators);
        } else if (StrEqual(info, DISTRIBUTE_EXCESS_PLAYERS)) {
            MoveExcessPlayers(MoveExcessPlayerType_Distribute);
        }
    }

    return 0;
}

void CreatePlayersMenu(int client) {
    Menu menu = new Menu(MenuHandler_Players);

    menu.SetTitle("%T", SELECT_PLAYER, client);

    AddPlayersToMenu(client, menu);

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Players(Menu menu, MenuAction action, int param1, int param2) {
    if (IsMenuItemSelected(menu, action)) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        int userId = StringToInt(info);
        int target = GetClientOfUserId(userId);

        if (target == 0) {
            return 0;
        }

        switch (GetMovePlayerType(param1)) {
            case MovePlayerType_Immediately: {
                ChangePlayerTeamToOpposite(target);
            }

            case MovePlayerType_AfterDeath: {
                if (IsMovePlayerFlagEnabled(target, MOVE_PLAYER_FLAG_AFTER_DEATH)) {
                    DisableMovePlayerFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                } else {
                    EnableMovePlayerFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                }
            }

            case MovePlayerType_RoundEnd: {
                if (IsMovePlayerFlagEnabled(target, MOVE_PLAYER_FLAG_ROUND_END)) {
                    DisableMovePlayerFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                } else {
                    EnableMovePlayerFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                }
            }

            case MovePlayerType_ToSpectators: {
                MovePlayerToSpectators(target);
            }
        }
    }

    return 0;
}

bool IsMenuItemSelected(Menu menu, MenuAction action) {
    if (action == MenuAction_End) {
        delete menu;

        return false;
    }

    return action == MenuAction_Select;
}

void AddFormattedItem(Menu menu, const char[] phrase, int client) {
    char buffer[TEXT_BUFFER_MAX_SIZE];

    Format(buffer, sizeof(buffer), "%T", phrase, client);

    menu.AddItem(phrase, buffer);
}

void AddPlayersToMenu(int client, Menu menu) {
    ArrayList players = GetPlayers(PlayerPredicate_ActivePlayers);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);
        int userId = GetClientUserId(player);
        char userIdStr[TEXT_BUFFER_MAX_SIZE];
        char item[TEXT_BUFFER_MAX_SIZE];

        IntToString(userId, userIdStr, sizeof(userIdStr));

        switch (GetMovePlayerType(client)) {
            case MovePlayerType_AfterDeath: {
                bool isMovePlayerAfterDeath = IsMovePlayerFlagEnabled(player, MOVE_PLAYER_FLAG_AFTER_DEATH);

                FormatPlayerItem(item, sizeof(item), player, isMovePlayerAfterDeath);
            }

            case MovePlayerType_RoundEnd: {
                bool isMovePlayerAfterRoundEnd = IsMovePlayerFlagEnabled(player, MOVE_PLAYER_FLAG_ROUND_END);

                FormatPlayerItem(item, sizeof(item), player, isMovePlayerAfterRoundEnd);
            }

            default: {
                Format(item, sizeof(item), MENU_PLAYER_ITEM, player);
            }
        }

        menu.AddItem(userIdStr, item);
    }

    delete players;
}

void FormatPlayerItem(char[] item, int itemMaxLen, int player, bool condition) {
    if (condition) {
        Format(item, itemMaxLen, MENU_PLAYER_ITEM_ENABLED, player);
    } else {
        Format(item, itemMaxLen, MENU_PLAYER_ITEM_DISABLED, player);
    }
}
