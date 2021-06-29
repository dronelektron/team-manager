#include <team>

void SwapTeams() {
    ArrayList players = GetPlayers(PlayerPredicate_All);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);

        ChangePlayerTeamToOpposite(player);
    }

    delete players;
}

void ChangePlayerTeamToOpposite(int client) {
    int team = GetClientTeam(client);

    if (team == TEAM_ALLIES) {
        ChangeClientTeam(client, TEAM_AXIS);
    } else if (team == TEAM_AXIS) {
        ChangeClientTeam(client, TEAM_ALLIES);
    }
}

void ScrambleTeams() {
    ArrayList players = GetPlayers(PlayerPredicate_ActivePlayers);

    FisherYatesShuffle(players);
    AssignTeams(players);

    delete players;
}

void FisherYatesShuffle(ArrayList array) {
    for (int i = array.Length - 1; i > 0; i--) {
        int j = GetRandomInt(0, i);

        array.SwapAt(i, j);
    }
}

void AssignTeams(ArrayList players) {
    int priorityTeam = GetRandomInt(TEAM_ALLIES, TEAM_AXIS);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);
        int team = priorityTeam;

        if (priorityTeam == TEAM_ALLIES) {
            team += i % 2;
        } else {
            team -= i % 2;
        }

        ChangeClientTeam(player, team);
    }
}

void MoveExcessPlayers(MoveExcessPlayerType type) {
    ArrayList allies = GetPlayers(PlayerPredicate_Allies);
    ArrayList axis = GetPlayers(PlayerPredicate_Axis);
    int diff = allies.Length - axis.Length;
    int playersCount = IntAbs(diff);
    ArrayList excessPlayers = null;

    if (diff > UNBALANCE_LIMIT) {
        allies.SortCustom(SortFunc_ByLowestRank);
        excessPlayers = TakeFirstPlayers(allies, playersCount);
    } else if (diff < -UNBALANCE_LIMIT) {
        axis.SortCustom(SortFunc_ByLowestRank);
        excessPlayers = TakeFirstPlayers(axis, playersCount);
    }

    if (excessPlayers != null) {
        switch (type) {
            case MoveExcessPlayerType_ToSpectators: {
                MovePlayersToSpectators(excessPlayers);
            }

            case MoveExcessPlayerType_Distribute: {
                AssignTeams(excessPlayers);
            }
        }

        delete excessPlayers;
    }

    delete axis;
    delete allies;
}

int IntAbs(int number) {
    return number < 0 ? -number : number;
}

void MovePlayersToSpectators(ArrayList players) {
    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);

        MovePlayerToSpectators(player);
    }
}

void MovePlayerToSpectators(int client) {
    ChangeClientTeam(client, TEAM_SPECTATOR);
}

int SortFunc_ByLowestRank(int index1, int index2, Handle array, Handle hndl) {
    ArrayList players = view_as<ArrayList>(array);
    int player1 = players.Get(index1);
    int player2 = players.Get(index2);
    int captures1 = GetPlayerCaptures(player1);
    int captures2 = GetPlayerCaptures(player2);

    if (captures1 != captures2) {
        return captures1 - captures2;
    }

    int frags1 = GetClientFrags(player1);
    int frags2 = GetClientFrags(player2);

    if (frags1 != frags2) {
        return frags1 - frags2;
    }

    int deaths1 = GetClientDeaths(player1);
    int deaths2 = GetClientDeaths(player2);

    return deaths2 - deaths1;
}
