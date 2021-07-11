#include <sourcemod>
#include <morecolors>
#include <event>
#include <menu>
#include <player>
#include <team>
#undef REQUIRE_PLUGIN
#include <adminmenu>

public Plugin myinfo = {
    name = "Team manager",
    author = "Dron-elektron",
    description = "Allows you to perform various operations on teams",
    version = "0.1.1",
    url = ""
}

char ADMIN_MENU[] = "adminmenu";
TopMenu g_adminMenu = null;

public void OnPluginStart() {
    LoadTranslations("team-manager.phrases");

    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
    HookEvent("dod_point_captured", Event_PointCaptured, EventHookMode_Post);
    HookEvent("dod_round_start", Event_RoundStart, EventHookMode_Post);

    TopMenu topMenu;

    if (LibraryExists(ADMIN_MENU) && (topMenu = GetAdminTopMenu()) != null) {
        OnAdminMenuReady(topMenu);
    }
}

public void OnLibraryRemoved(const char[] name) {
    if (StrEqual(name, ADMIN_MENU, false)) {
        g_adminMenu = null;
    }
}

public void OnAdminMenuReady(Handle aTopMenu) {
    TopMenu topMenu = TopMenu.FromHandle(aTopMenu);

    if (topMenu == g_adminMenu) {
        return;
    }

    g_adminMenu = topMenu;

    AddTeamManagerToAdminMenu();
}

public void OnClientConnected(int client) {
    ResetPlayerCaptures(client);
    ResetMovePlayerFlags(client);
}
