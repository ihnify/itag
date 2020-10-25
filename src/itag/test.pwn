#include <a_samp>
#include <ssacnf2>
#include <Pawn.CMD>
#include <Pawn.RakNet>
#include <itag.pwn>

main() {}

CMD:i_tag(playerid, params[])
{
    new
        toggle,
		subparams[5];

	if (sscanf(params, "s[5]i", subparams, toggle)) {
		SendClientMessage(playerid, -1, "USAGE: /i_tag <id/all> <toggle ( 0 / 1 )>");
        return SendClientMessage(playerid, -1, "0 - enable, 1 - disable.");
	}

	new
		targetid = INVALID_PLAYER_ID;

	if (!strcmp(subparams, "all", true)) {
		targetid = INVALID_PLAYER_ID;
	} else if (sscanf(subparams, "u", targetid) || targetid == INVALID_PLAYER_ID) {
		SendClientMessage(playerid, -1, "The player is not connected");
		return 1;
	}

    IT_Enable3DNameTagForType(playerid, targetid, !toggle);
	return 1;
}