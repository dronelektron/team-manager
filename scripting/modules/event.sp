#include <event>

public void Event_PointCaptured(Event event, const char[] name, bool dontBroadcast) {
    char cappers[EVENT_STRING_MAX_SIZE];

    event.GetString("cappers", cappers, sizeof(cappers));

    for (int i = 0; i < strlen(cappers); i++) {
        int player = cappers[i];

        IncrementPlayerCaptures(player);
    }
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    if (IsMovePlayerAfterDeath(client)) {
        SetMovePlayerAfterDeath(client, false);
        ChangePlayerTeamToOpposite(client);
    }
}
