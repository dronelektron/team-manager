#if defined _player_included
 #endinput
#endif
#define _player_included

#define MOVE_PLAYER_FLAG_AFTER_DEATH (1 << 0)
#define MOVE_PLAYER_FLAG_ROUND_END (1 << 1)

enum MovePlayerType {
    MovePlayerType_Immediately = 0,
    MovePlayerType_AfterDeath,
    MovePlayerType_AfterRoundEnd,
    MovePlayerType_ToSpectators
};

typedef PlayerPredicate = function bool (int client);
