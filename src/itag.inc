#if !defined _samp_included
	#error Please include a_samp or a_npc before itag
#endif

#if !defined PAWNRAKNET_INC_
	#error You must have Pawn.RakNet include in order to use this one.
#endif

#if defined _itag_included
	#endinput
#endif

#define _itag_included

/*
	define
*/

#if !defined ITAG_DEBUG_INFO
	#define ITAG_DEBUG_INFO true
#endif

#if !defined MAX_ITAG_FORMAT_STRING
	#define MAX_ITAG_FORMAT_STRING 32
#endif

#if !defined DEFAULT_ITAG_RADIUS
	#define DEFAULT_ITAG_RADIUS 10.0
#endif

#if ITAG_DEBUG_INFO
	static IT_DebugStr[144];

	#define IT_DebugMessage(%1) \
		printf(IT_DebugStr, "IT: " %1)
#endif

/*
    enums
*/

enum e_ITAG_INFO {
    #if defined _streamer_included
        STREAMER_TAG_3D_TEXT_LABEL:e_T3DText,
    #else
        Text3D:e_T3DText,
    #endif 

	e_TName[MAX_PLAYER_NAME + 1],
	bool:e_TShow,
}

static
	gTagInfo[MAX_PLAYERS][e_ITAG_INFO],

	bool:gTagStatus;
    

/*
    const
*/

const RPC_onShowPlayerNameTag = 80;

/*
    ORPC
*/

ORPC:RPC_onShowPlayerNameTag(playerid, BitStream:bs) 
{
	if (playerid == -1) {
		return 0;
	}

    static
		playerId,
        bool:tag;

    BS_ReadUint16(bs, playerId);
    BS_ReadUint8(bs, tag);


    return 1;
}

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
		if (gTagStatus && !gTagInfo[forplayerid][e_TShow]) {
			IT_Enable3DNameTagForPlayer(playerid, forplayerid, true);
			IT_OnRPCSendNameTag(playerid, forplayerid, false);
		} else if (gTagInfo[forplayerid][e_TShow]) {
			IT_OnRPCSendNameTag(playerid, forplayerid, false);
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

static stock IT_OnRPCSendNameTag(fromplayerid, toplayerid, bool:show)
{
	new
		BitStream:bs = BS_New();

	BS_WriteValue (
		bs,
		PR_UINT16, toplayerid,
		PR_UINT8, show);
	BS_RPC (bs, fromplayerid, RPC_onShowPlayerNameTag, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete (bs);
	return 1;
}

stock IT_Enable3DNameTagForType(fromplayerid, toplayerid = INVALID_PLAYER_ID, bool:enable, bool:enableLabel = true, Float:drawdistance = DEFAULT_ITAG_RADIUS, color = 0xFFFFFFFF, const inputtext[] = "")
{
	if (strlen(inputtext) > MAX_ITAG_FORMAT_STRING) {
	   	return IT_DebugMessage("The maximum number of characters %d", MAX_ITAG_FORMAT_STRING);
	}

	if (toplayerid == INVALID_PLAYER_ID) {
		gTagStatus = enable;
		
		#if defined foreach
			foreach (new playerid : Player) {
		#else
			for (playerid = GetPlayerPoolSize(); playerid != -1; playerid--) {
				if (!IsPlayerConnected(playerid)) {
					continue;
				}
		#endif
				IT_Enable3DNameTagForPlayer(fromplayerid, playerid, enable, enableLabel, drawdistance, color, inputtext);
			}
	} else {
		IT_Enable3DNameTagForPlayer(fromplayerid, toplayerid, enable, enableLabel, drawdistance, color, inputtext);
	}
	return 1;
}

static stock IT_Enable3DNameTagForPlayer(fromplayerid, toplayerid, bool:enable, bool:enableLabel = true, Float:drawdistance = DEFAULT_ITAG_RADIUS, color = 0xFFFFFFFF, const inputtext[] = "")
{
	gTagInfo[toplayerid][e_TShow] = enable;

	static Float:player_x, Float:player_y, Float:player_z;
	GetPlayerPos(toplayerid, player_x, player_y, player_z);

	if (!gTagInfo[toplayerid][e_T3DText]) {
		static 
			fmt_tag[MAX_ITAG_FORMAT_STRING];

		if (strlen (inputtext) > 0) {
			format(fmt_tag, sizeof(fmt_tag), "%s", inputtext);
		} else {
			format(fmt_tag, sizeof(fmt_tag), "%s(%d)", gTagInfo[toplayerid][e_TName], toplayerid);
		}

		IT_OnRPCSendNameTag(fromplayerid, toplayerid, enable);
		
		if (fromplayerid == toplayerid) {
			IT_OnRPCSendNameTag(toplayerid, fromplayerid, enable);
		}

		if (enableLabel) {
			#if defined _streamer_included
				gTagInfo[toplayerid][e_T3DText] = CreateDynamic3DTextLabel(fmt_tag, color, player_x, player_y, player_z + 0.17, drawdistance, toplayerid, .testlos = 1);
			#else
				gTagInfo[toplayerid][e_T3DText] = Create3DTextLabel(fmt_tag, color, 0.0, 0.0, 0.0, drawdistance, -1, 1);
				Attach3DTextLabelToPlayer(gTagInfo[toplayerid][e_T3DText], toplayerid, 0.0, 0.0, 0.17);
			#endif
		}
	} else {
		IT_ResetNameTagInfo(toplayerid);
	}
	return 1;
}

static stock IT_ResetNameTagInfo(playerid)
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

	gTagInfo[playerid][e_TShow] = false;
	return 1;
}
