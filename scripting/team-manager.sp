#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <adminmenu>
#include <morecolors>
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

char ADMIN_MENU[] = "adminmenu";

TopMenu g_adminMenu = null;

TopMenuObject g_teamManagerCategory = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemMovePlayer = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemSwapTeams = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemScrambleTeams = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemBalanceTeams = INVALID_TOPMENUOBJECT;

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
    g_teamManagerCategory = g_adminMenu.AddCategory(TEAM_MANAGER, TopMenuHandler_TeamManager);

    if (g_teamManagerCategory != INVALID_TOPMENUOBJECT) {
        g_menuItemMovePlayer = g_adminMenu.AddItem(MOVE_PLAYER, TopMenuHandler_TeamManager, g_teamManagerCategory);
        g_menuItemSwapTeams = g_adminMenu.AddItem(SWAP_TEAMS, TopMenuHandler_TeamManager, g_teamManagerCategory);
        g_menuItemScrambleTeams = g_adminMenu.AddItem(SCRAMBLE_TEAMS, TopMenuHandler_TeamManager, g_teamManagerCategory);
        g_menuItemBalanceTeams = g_adminMenu.AddItem(BALANCE_TEAMS, TopMenuHandler_TeamManager, g_teamManagerCategory);
    }
}

public void TopMenuHandler_TeamManager(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        if (topobj_id == g_teamManagerCategory) {
            Format(buffer, maxlength, "%T", TEAM_MANAGER, param);
        } else if (topobj_id == g_menuItemMovePlayer) {
            Format(buffer, maxlength, "%T", MOVE_PLAYER, param);
        } else if (topobj_id == g_menuItemSwapTeams) {
            Format(buffer, maxlength, "%T", SWAP_TEAMS, param);
        } else if (topobj_id == g_menuItemScrambleTeams) {
            Format(buffer, maxlength, "%T", SCRAMBLE_TEAMS, param);
        } else if (topobj_id == g_menuItemBalanceTeams) {
            Format(buffer, maxlength, "%T", BALANCE_TEAMS, param);
        }
    } else if (action == TopMenuAction_DisplayTitle) {
        if (topobj_id == g_teamManagerCategory) {
            Format(buffer, maxlength, "%T", TEAM_MANAGER, param);
        }
    } else if (action == TopMenuAction_SelectOption) {
        if (topobj_id == g_menuItemMovePlayer) {
            CreateMovePlayerMenu(param);
        } else if (topobj_id == g_menuItemSwapTeams) {
            if (SwapTeams()) {
                CPrintToChatAll("%t %t", "Prefix", "Teams was swapped");
                LogAction(param, -1, "\"%L\" swapped teams", param);
            }
        } else if (topobj_id == g_menuItemScrambleTeams) {
            if (ScrambleTeams()) {
                CPrintToChatAll("%t %t", "Prefix", "Teams was scrambled");
                LogAction(param, -1, "\"%L\" scrambled teams", param);
            }
        } else if (topobj_id == g_menuItemBalanceTeams) {
            CreateBalanceTeamsMenu(param);
        }
    }
}

public void OnClientConnected(int client) {
    ResetPlayerCaptures(client);
    ResetMovePlayerFlags(client);
}
