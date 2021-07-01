#include <sourcemod>
#include <event>
#include <menu>
#include <player>
#include <team>

public Plugin myinfo = {
    name = "Team manager",
    author = "Dron-elektron",
    description = "Allows you to perform various operations on teams",
    version = "0.1.0",
    url = ""
}

public void OnPluginStart() {
    RegAdminCmd("sm_teammanager", AdminCmd_TeamManager, ADMFLAG_GENERIC, "Open team manager menu");
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
    HookEvent("dod_point_captured", Event_PointCaptured, EventHookMode_Post);
    HookEvent("dod_round_start", Event_RoundStart, EventHookMode_Post);
    LoadTranslations("team-manager.phrases");
}

public void OnClientConnected(int client) {
    ResetPlayerCaptures(client);
    ResetMovePlayerFlags(client);
}

public Action AdminCmd_TeamManager(int client, int args) {
    CreateTeamManagerMenu(client);

    return Plugin_Handled;
}
