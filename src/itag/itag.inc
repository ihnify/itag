#if !defined _samp_included
	#error Please include a_samp or a_npc before itag
#endif

#if defined _itag_h_included
	#endinput
#endif

#define _itag_h_included

/*
	define
*/

#if !defined ITAG_DEBUG_INFO
	#define ITAG_DEBUG_INFO true
#endif

#if !defined MAX_ITAG_FORMAT_STRING
	#define MAX_ITAG_FORMAT_STRING 32
#endif

#if !defined ITAG_LABEL_DISTANCE
	#define ITAG_LABEL_DISTANCE 10.0
#endif

#if !defined ITAG_DRAW_DISTANCE 
	#define ITAG_DRAW_DISTANCE 300
#endif

#if !defined ITAG_LABEL_STATUS
	#define ITAG_LABEL_STATUS true
#endif

#if !defined ITAG_COLOR
	#define ITAG_COLOR 0xFFFFFFFF
#endif

/*
    const
*/

#if defined PAWNRAKNET_INC_
	const RPC_onShowPlayerNameTag = 80;
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
	bool:e_TShowLabel,
}
