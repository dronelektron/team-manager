#include <sourcemod>
#include <player>
#include <team>
#include <menu>

public Plugin myinfo = {
    name = "Team manager",
    author = "Dron-elektron",
    description = "Allows you to perform various operations on teams",
    version = "0.1.0",
    url = ""
}

public void OnPluginStart() {
    RegAdminCmd("sm_teammanager", AdminCmd_TeamManager, ADMFLAG_GENERIC, "Open team manager menu");
    HookEvent("dod_point_captured", Event_PointCaptured);
    HookEvent("player_death", Event_PlayerDeath);
    LoadTranslations("team-manager.phrases");
}

public void OnClientConnected(int client) {
    ResetPlayerCaptures(client);
    SetMovePlayerAfterDeath(client, false);
}

public Action AdminCmd_TeamManager(int client, int args) {
    CreateTeamManagerMenu(client, MenuHandler_TeamManager);

    return Plugin_Handled;
}

public int MenuHandler_TeamManager(Menu menu, MenuAction action, int param1, int param2) {
    if (IsMenuItemSelected(menu, action)) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, MOVE_PLAYER)) {
            CreateMovePlayerMenu(param1, MenuHandler_MovePlayer);
        } else if (StrEqual(info, SWAP_TEAMS)) {
            SwapTeams();
        } else if (StrEqual(info, SCRAMBLE_TEAMS)) {
            ScrambleTeams();
        } else if (StrEqual(info, BALANCE_TEAMS)) {
            CreateBalanceTeamsMenu(param1, MenuHandler_BalanceTeams);
        }
    }

    return 0;
}

public int MenuHandler_MovePlayer(Menu menu, MenuAction action, int param1, int param2) {
    if (IsMenuItemSelected(menu, action)) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, IMMEDIATELY)) {
            SetMovePlayerType(param1, MovePlayerType_Immediately);
        } else if (StrEqual(info, AFTER_DEATH)) {
            SetMovePlayerType(param1, MovePlayerType_AfterDeath);
        } else if (StrEqual(info, TO_SPECTATORS)) {
            SetMovePlayerType(param1, MovePlayerType_ToSpectators);
        }

        CreatePlayersMenu(param1, MenuHandler_Players);
    }

    return 0;
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
                SetMovePlayerAfterDeath(target, false);
                ChangePlayerTeamToOpposite(target);
            }

            case MovePlayerType_AfterDeath: {
                bool isMovePlayerAfterDeath = !IsMovePlayerAfterDeath(target);

                SetMovePlayerAfterDeath(target, isMovePlayerAfterDeath);
            }

            case MovePlayerType_ToSpectators: {
                SetMovePlayerAfterDeath(target, false);
                MovePlayerToSpectators(target);
            }
        }
    }

    return 0;
}
