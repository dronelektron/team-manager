#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#pragma semicolon 1
#pragma newdecls required

#include "tm/command"
#include "tm/event"
#include "tm/menu"
#include "tm/message"
#include "tm/player"
#include "tm/team"

#include "modules/command.sp"
#include "modules/menu.sp"
#include "modules/message.sp"
#include "modules/player.sp"
#include "modules/use-case.sp"

public Plugin myinfo = {
    name = "Team manager",
    author = "Dron-elektron",
    description = "Allows you to perform various operations on teams",
    version = "0.2.0",
    url = "https://github.com/dronelektron/team-manager"
};

public void OnPluginStart() {
    AdminMenu_Create();
    RegAdminCmd("sm_tm_move_player", Command_MovePlayer, ADMFLAG_GENERIC, COMMAND_DESCRIPTION_MOVE_PLAYER);
    RegAdminCmd("sm_tm_swap_teams", Command_SwapTeams, ADMFLAG_GENERIC, COMMAND_DESCRIPTION_SWAP_TEAMS);
    RegAdminCmd("sm_tm_scramble_teams", Command_ScrambleTeams, ADMFLAG_GENERIC, COMMAND_DESCRIPTION_SCRAMBLE_TEAMS);
    RegAdminCmd("sm_tm_balance_teams", Command_BalanceTeams, ADMFLAG_GENERIC, COMMAND_DESCRIPTION_BALANCE_TEAMS);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
    HookEvent("dod_point_captured", Event_PointCaptured);
    HookEvent("dod_round_start", Event_RoundStart);
    LoadTranslations("common.phrases");
    LoadTranslations("team-manager.phrases");
}

public void OnLibraryRemoved(const char[] name) {
    if (strcmp(name, ADMIN_MENU) == 0) {
        AdminMenu_Destroy();
    }
}

public void OnAdminMenuReady(Handle topMenu) {
    AdminMenu_OnReady(topMenu);
}

public void OnClientConnected(int client) {
    Player_ResetCaptures(client);
    Player_ResetMoveFlags(client);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    UseCase_MovePlayerToOppositeTeamAfterDeath(client);
}

public Action Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    Player_ResetMoveFlags(client);

    return Plugin_Continue;
}

public void Event_PointCaptured(Event event, const char[] name, bool dontBroadcast) {
    char cappers[EVENT_STRING_MAX_SIZE];

    event.GetString("cappers", cappers, sizeof(cappers));

    UseCase_PointCaptured(cappers);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    UseCase_MovePlayerToOppositeTeamAfterRoundEnd();
}
