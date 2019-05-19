#include "itag.inc"

#if defined _itag_included
	#endinput
#endif

#define _itag_included

/*
	define
*/

#if ITAG_DEBUG_INFO
	new IT_DebugStr[144];

	#define IT_DebugMessageError(%1) \
		format(IT_DebugStr, sizeof(IT_DebugStr), %1), printf("IT_Error: " %1, IT_DebugStr)
#endif


static
	gTagInfo[MAX_PLAYERS][e_ITAG_INFO],
	gTagText[MAX_ITAG_FORMAT_STRING],
	bool:gTagStatus;

/*
    OnGameModeInit
*/

#if defined _inc_y_hooks || defined _INC_y_hooks
	hook OnGameModeInit()
#else
	public OnGameModeInit()
#endif
	{
		gTagStatus = true;

		#if defined ITAG_OnGameModeInit
			return ITAG_OnGameModeInit();
		#else
			return 1;
		#endif
	}

#if !defined _inc_y_hooks && !defined _INC_y_hooks
	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif

	#define OnGameModeInit ITAG_OnGameModeInit
	#if defined ITAG_OnGameModeInit
		forward ITAG_OnGameModeInit();
	#endif
#endif

/*
    OnPlayerConnect
*/

#if defined _inc_y_hooks || defined _INC_y_hooks
	hook OnPlayerConnect(playerid)
#else
	public OnPlayerConnect(playerid)
#endif
	{
		GetPlayerName(playerid, gTagInfo[playerid][e_TName], MAX_PLAYER_NAME);
		IT_ResetNameTagInfo(playerid);
		#if defined ITAG_OnPlayerConnect
			return ITAG_OnPlayerConnect(playerid);
		#else
			return 1;
		#endif
	}

#if !defined _inc_y_hooks && !defined _INC_y_hooks
	#if defined _ALS_OnPlayerConnect
		#undef OnPlayerConnect
	#else
		#define _ALS_OnPlayerConnect
	#endif

	#define OnPlayerConnect ITAG_OnPlayerConnect
	#if defined ITAG_OnPlayerConnect
		forward ITAG_OnPlayerConnect(playerid);
	#endif
#endif

/*
    OnPlayerDisconnect
*/

#if defined _inc_y_hooks || defined _INC_y_hooks
	hook OnPlayerDisconnect(playerid, reason)
#else
	public OnPlayerDisconnect(playerid, reason)
#endif
	{
		IT_ResetNameTagInfo(playerid);
		#if defined ITAG_OnPlayerDisconnect
			return ITAG_OnPlayerDisconnect(playerid, reason);
		#else
			return 1;
		#endif
	}

#if !defined _inc_y_hooks && !defined _INC_y_hooks
	#if defined _ALS_OnPlayerDisconnect
		#undef OnPlayerDisconnect
	#else
		#define _ALS_OnPlayerDisconnect
	#endif

	#define OnPlayerDisconnect ITAG_OnPlayerDisconnect
	#if defined ITAG_OnPlayerDisconnect
	    forward ITAG_OnPlayerDisconnect(playerid, reason);
	#endif
#endif

#if defined _inc_y_hooks || defined _INC_y_hooks
	hook OnPlayerStreamIn(playerid, forplayerid)
#else
	public OnPlayerStreamIn(playerid, forplayerid)
#endif
	{
		if (!gTagStatus && gTagInfo[playerid][e_TShow]) {
			IT_Enable3DNameTagType(forplayerid, playerid, false, .inputtext = strlen(gTagText) > 0 ? gTagText : "");
		} 

		if (gTagStatus && !gTagInfo[playerid][e_TShow]) {
			IT_Enable3DNameTagType(forplayerid, playerid, false, .inputtext = strlen(gTagText) > 0 ? gTagText : "");
		}
		#if defined ITAG_OnPlayerStreamIn
			return ITAG_OnPlayerStreamIn(playerid, forplayerid);
		#else
			return 1;
		#endif
	}

#if !defined _inc_y_hooks && !defined _INC_y_hooks
	#if defined _ALS_OnPlayerStreamIn
		#undef OnPlayerStreamIn
	#else
		#define _ALS_OnPlayerStreamIn
	#endif

	#define OnPlayerStreamIn ITAG_OnPlayerStreamIn
	#if defined ITAG_OnPlayerStreamIn
	    forward ITAG_OnPlayerStreamIn(playerid, forplayerid);
	#endif
#endif

/*
    stock
*/

stock getplayer(playerid)
{
	return gTagInfo[playerid][e_TShow];
}

stock IT_Enable3DNameTagType(fromplayerid, toplayerid = INVALID_PLAYER_ID, bool:enableTag, bool:enableLabel = ITAG_LABEL_STATUS, Float:drawDistanceLabel = ITAG_LABEL_DISTANCE, color = ITAG_COLOR, const inputtext[] = "")
{
	if (strlen(inputtext) > MAX_ITAG_FORMAT_STRING) {
	   	return IT_DebugMessageError("The maximum number of characters %d", MAX_ITAG_FORMAT_STRING);
	}

	if (toplayerid == INVALID_PLAYER_ID) {
		if (gTagStatus == enableTag) {
			return IT_DebugMessageError("NameTag is now %s", enableTag ? "enable" : "disable");
		}

		gTagStatus = enableTag;
		
		#if defined foreach
			foreach (new playerid : Player) {
				if (gTagInfo[playerid][e_TShow] == enableTag) {
					continue;
				}
		#else
			for (playerid = GetPlayerPoolSize(); playerid != -1; playerid--) {
				if (!IsPlayerConnected(playerid)) {
					continue;
				}
		#endif
				IT_Enable3DNameTag(fromplayerid, playerid, enableTag, enableLabel, drawDistanceLabel, color, inputtext);
				printf("%d ", playerid);
			}
	} else {
		if (gTagInfo[toplayerid][e_TShow] == enableTag) {
			return IT_DebugMessageError("The player %s[%d] already has NameTag %s", gTagInfo[toplayerid][e_TName], toplayerid, enableTag ? "enable" : "disable");
		}

		IT_Enable3DNameTag(fromplayerid, toplayerid, enableTag, enableLabel, drawDistanceLabel, color, inputtext);
	}
	return 1;
}

stock IT_Update3DNameTag(playerid, bool:enableLabel = ITAG_LABEL_STATUS, color = ITAG_COLOR, const inputtext[] = "")
{
	if (gTagInfo[playerid][e_TShow]) {
		return IT_DebugMessageError("Player %d not disabled NameTag.", playerid);
	}

	if (gTagInfo[playerid][e_TShowLabel] == enableLabel) {
		return IT_DebugMessageError("The player %s[%d] already has 3D text %s", gTagInfo[playerid][e_TName], playerid, enableLabel ? "enable" : "disable");
	}

	#if defined _streamer_included
		//UpdateDynamic3DTextLabelText(gTagInfo[toplayerid][e_T3DText], color, const text[]);
		gTagInfo[toplayerid][e_T3DText] = CreateDynamic3DTextLabel(gTagText, color, player_x, player_y, player_z + 0.17, drawdistance, toplayerid, .testlos = 1);
	#else
		gTagInfo[toplayerid][e_T3DText] = Create3DTextLabel(gTagText, color, 0.0, 0.0, 0.0, drawdistance, -1, 1);
		Attach3DTextLabelToPlayer(gTagInfo[toplayerid][e_T3DText], toplayerid, 0.0, 0.0, 0.17);
	#endif
	return 1;
}

stock IT_Update3DNameTagToAll(bool:enableLabel = ITAG_LABEL_STATUS, color = ITAG_COLOR, const inputtext[] = "")
{
	if (gTagStatus) {
		return IT_DebugMessageError("NameTag not disabled");
	}

	if (strlen(inputtext) > MAX_ITAG_FORMAT_STRING) {
	   	return IT_DebugMessageError("The maximum number of characters %d", MAX_ITAG_FORMAT_STRING);
	}

	if(strlen(inputtext) > 0) {
		gTagText[0] = '\0';

		format(gTagText, MAX_ITAG_FORMAT_STRING, "%s", inputtext);
	}

	#if defined foreach
		foreach (new playerid : Player) {
	#else
		for (playerid = GetPlayerPoolSize(); playerid != -1; playerid--) {
			if (!IsPlayerConnected(playerid)) {
				continue;
			}
	#endif
			UpdateDynamic3DTextLabelText(gTagInfo[playerid][e_T3DText], color, gTagText);
			gTagInfo[playerid][e_TShowLabel] = enableLabel;
		}
		return 1;
}

static stock IT_Enable3DNameTag(fromplayerid, toplayerid, bool:enableTag, bool:enableLabel = ITAG_LABEL_STATUS, Float:drawDistanceLabel = ITAG_LABEL_DISTANCE, color = ITAG_COLOR, const inputtext[] = "")
{
	static Float:player_x, Float:player_y, Float:player_z;
	GetPlayerPos(toplayerid, player_x, player_y, player_z);

	if (!enableTag) {
		if (GetPlayerDistanceFromPoint(fromplayerid, player_x, player_y, player_z) <= 300.0) {
			if (!gTagInfo[toplayerid][e_T3DText]) {
				gTagInfo[toplayerid][e_TShow] = enableTag;
				if (enableLabel) {
					gTagInfo[toplayerid][e_TShowLabel] = enableLabel;

					if (strlen (inputtext) > 0) {
						format(gTagText, MAX_ITAG_FORMAT_STRING, "%s", inputtext);
					} else {
						format(gTagText, MAX_ITAG_FORMAT_STRING, "%s(%d)", gTagInfo[toplayerid][e_TName], toplayerid);
					}

					#if defined _streamer_included
						gTagInfo[toplayerid][e_T3DText] = CreateDynamic3DTextLabel(gTagText, color, player_x, player_y, player_z + 0.20, drawDistanceLabel, toplayerid, .testlos = 1);
					#else
						gTagInfo[toplayerid][e_T3DText] = Create3DTextLabel(gTagText, color, 0.0, 0.0, 0.0, drawDistanceLabel, -1, 1);
						Attach3DTextLabelToPlayer(gTagInfo[toplayerid][e_T3DText], toplayerid, 0.0, 0.0, 0.20);
					#endif

					goto showPlayerNameTag;
				}
			}
		}
	} else {
		IT_ResetNameTagInfo(toplayerid, enableTag);

	showPlayerNameTag:
		#if defined PAWNRAKNET_INC_
			IT_OnRPCSendNameTag(fromplayerid, toplayerid, enableTag); // for toplayer

			if (toplayerid != INVALID_PLAYER_ID) {
				IT_OnRPCSendNameTag(toplayerid, fromplayerid, enableTag); // for fromplayer
			}
		#else
			ShowPlayerNameTagForPlayer(fromplayerid, toplayerid, enableTag); // for toplayer
			
			if (toplayerid != INVALID_PLAYER_ID) {
				ShowPlayerNameTagForPlayer(toplayerid, fromplayerid, enableTag); // for fromplayer
			}
		#endif
		return 1;
	}
	return 1;
}

static stock IT_ResetNameTagInfo(playerid, bool:enable = true)
{
	#if defined _streamer_included
        if (gTagInfo[playerid][e_T3DText]) {
            DestroyDynamic3DTextLabel(gTagInfo[playerid][e_T3DText]);
			gTagInfo[playerid][e_T3DText] = STREAMER_TAG_3D_TEXT_LABEL:INVALID_3DTEXT_ID;
        }
    #else
        if (gTagInfo[playerid][e_T3DText]) {
            Delete3DTextLabel(gTagInfo[playerid][e_T3DText]);
			gTagInfo[playerid][e_T3DText] = Text3D:INVALID_3DTEXT_ID;
        }
    #endif

	gTagInfo[playerid][e_TShow] = enable;
	gTagInfo[playerid][e_TShowLabel] = false;
	return 1;
}

#if defined PAWNRAKNET_INC_
	static stock IT_OnRPCSendNameTag(fromplayerid, toplayerid, bool:show)
	{
		new
			BitStream:bs = BS_New();

		BS_WriteValue(
			bs,
			PR_UINT16, toplayerid,
			PR_UINT8, show);
		BS_RPC(bs, fromplayerid, RPC_onShowPlayerNameTag, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
		BS_Delete(bs);
		return 1;
	}
#endif