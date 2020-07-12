#include <sourcemod>
#include <sdktools>
#include <weddings>
#include <emitsoundany>

public Plugin:myinfo =
{
	name = "SM Weddings Sounds",
	author = "Franc1sco Steam: franug",
	description = "",
	version = "1.0",
	url = "http://servers-cfg.foroactivo.com/"
};

public OnMapStart()
{
	AddFileToDownloadsTable("sound/franug/love_incoming.mp3");
	AddFileToDownloadsTable("sound/franug/love_wins.mp3");
	
	PrecacheSound("franug/love_incoming.mp3");
	PrecacheSound("franug/love_wins.mp3");
}


public Action OnProposal(proposer, target)
{
	EmitSoundToClient(proposer, "franug/love_incoming.mp3");
	EmitSoundToClient(target, "franug/love_incoming.mp3");
}

public void OnWeddingPost(proposer, accepter)
{

	EmitSoundToAll("franug/love_wins.mp3");
}