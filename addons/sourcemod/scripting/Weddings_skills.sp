/*  SM Weddings skills
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <weddings>
#include <cstrike>
#include <store>
#undef REQUIRE_PLUGIN
#include <franug_deadgames>
#define REQUIRE_PLUGIN


new g_BeamSprite;
new g_HaloSprite;
new GlowSprite;
//new g_iAccount = -1;

//new bool:money[MAXPLAYERS+1];
new bool:beacon[MAXPLAYERS+1];

bool gp_bDeadGames;

//#define SOUND_RESPAWN "player/pl_respawn.wav"

int g_iTime[MAXPLAYERS + 1];

public Plugin:myinfo =
{
	name = "SM Weddings skills",
	author = "Franc1sco Steam: franug",
	description = "",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	LoadTranslations("weddings_skills.phrases");
	CreateConVar("sm_weddings_skills", "1.0", "version",FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegConsoleCmd("sm_loveskills", TheLove);
	
	RegConsoleCmd("sm_love", DOMenu);
	
	gp_bDeadGames = LibraryExists("franug_deadgames");
	
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPostAdminCheck(i);
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "franug_deadgames"))
	{
		gp_bDeadGames = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "franug_deadgames"))
	{
		gp_bDeadGames = true;
	}
}

public Action:DOMenu(client,args)
{
	new Handle:menu = CreateMenu(DIDMenuHandler2);
	SetMenuTitle(menu, "Love menu by Franc1sco Franug");
	char menuitem[64];
	
	Format(menuitem,sizeof(menuitem), "%T", "Weddings Skills",client);
	AddMenuItem(menu, "sm_loveskills", menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T", "Marry",client);
	AddMenuItem(menu, "sm_marry", menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T", "Revoke",client);
	AddMenuItem(menu, "sm_revoke", menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T", "Proposals",client);
	AddMenuItem(menu, "sm_proposals", menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T", "Divorce",client);
	AddMenuItem(menu, "sm_divorce", menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T", "Couples",client);
	AddMenuItem(menu, "sm_couples", menuitem);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DIDMenuHandler2(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		
		FakeClientCommand(client, info);
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public OnClientPostAdminCheck(client)
{
	//money[client] = true;
	beacon[client] = true;
	g_iTime[client] = GetTime();
}

public OnMapStart()
{
	g_BeamSprite = PrecacheModel("materials/sprites/bomb_planted_ring.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo.vtf");
	GlowSprite = PrecacheModel("materials/sprites/blueglow1.vmt");
	CreateTimer(1.0, Temporizador, _,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	//PrecacheSound(SOUND_RESPAWN, true);	
	
	//g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
}

public Action:Temporizador(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			new casado = GetPartnerSlot(i);
			if(casado < 1 || !IsClientInGame(casado) || !IsPlayerAlive(casado) || GetClientTeam(i) != GetClientTeam(casado)) continue;
			
			if(beacon[i]) SetupBeacon(i, casado);
			//SharedMoney(i, casado);
				
		}
}

SetupBeacon(client, married)
{
	new Float:vec[3];
	GetClientAbsOrigin(married, vec);
	vec[2] += 10;
	TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, {247, 191, 190, 255}, 10, 0);
	TE_SendToClient(client);
}

/* SharedMoney(client, married)
{
	if(!money[client] || !money[married]) return;
	
	new dinerototal = ObtenerDinero(client) + ObtenerDinero(married);
	dinerototal /= 2;
	FijarDinero(client, dinerototal);
	FijarDinero(married, dinerototal);
}

stock ObtenerDinero(client)
{
	new dinero = GetEntData(client, g_iAccount);
	return dinero;
}

stock FijarDinero(client, cantidad)
{
	SetEntData(client, g_iAccount, cantidad);
} */

public Action:TheLove(client,args)
{
	if(GetPartnerSlot(client) > 0)
		DID(client);
	else
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T","You need to be married and your love in the server for use this command",client);
		
	return Plugin_Handled;
}

Teleportar(client, casado)
{
	if(!IsClientInGame(casado) || !IsPlayerAlive(client) || !IsPlayerAlive(casado) || GetClientTeam(client) != GetClientTeam(casado) || (gp_bDeadGames && (DeadGames_IsOnGame(client) || DeadGames_IsOnGame(casado))))
	{
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T","You and your love need to be on the same team",client);
		TheLove(client, 0);
		return;
	}
	
	if(GetTime() < (g_iTime[client]+(1*30)))
	{
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Tienes que esperar %i segundos usar el teleport otra vez", (g_iTime[client]+(1*30)) - GetTime());
		TheLove(client, 0);
		return;
	}

	decl Float:ang[3], Float:vec[3];
	GetClientAbsAngles(casado, ang);
	GetClientAbsOrigin(casado, vec);
	
	TeleportEntity(client, vec, ang, NULL_VECTOR);
	FakeClientCommand(client, "sm_nb");
	
	g_iTime[client] = GetTime();
	g_iTime[casado] = GetTime();
	
	TE_SetupGlowSprite(vec, GlowSprite, 5.0, 2.0, 50);
	TE_SendToAll();
	
	
	//PrintToChatAll(" \x04[SM_Weddings-Skills] \x05El jugador \x04%N \x05se ha teleportado a su amor\x04 %N", client, casado);
	
	//EmitSoundToAll(SOUND_RESPAWN, client);
	
	PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T", "You has been teleported to your love",client);
	TheLove(client, 0);
}

Sacrificio(client, casado)
{
	if(!IsClientInGame(casado) || !IsPlayerAlive(client) || IsPlayerAlive(casado) || (gp_bDeadGames && (DeadGames_IsOnGame(client) || DeadGames_IsOnGame(casado))))
	{
		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T", "You and your love need to be alive",client);
		TheLove(client, 0);
		return;
	}
	
	if(GetClientTeam(client) == GetClientTeam(casado))
	{
		decl Float:ang[3], Float:vec[3];
		GetClientAbsAngles(client, ang);
		GetClientAbsOrigin(client, vec);
		
/* 		decl Float:ang2[3], Float:vec2[3];
		GetClientAbsAngles(casado, ang2);
		GetClientAbsOrigin(casado, vec2); */
		int vida = GetClientHealth(client);
		CS_RespawnPlayer(casado);
		
		SetEntityHealth(casado, vida);
		
		TeleportEntity(casado, vec, ang, NULL_VECTOR);
		//TeleportEntity(client, vec2, ang2, NULL_VECTOR);
		ForcePlayerSuicide(client);
	
		PrintToChat(casado, " \x04[SM_Weddings-Skills] \x05%T","Your love has been dead for save you",client);

		PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T",  "You has been sacrificed for save to your love of infection",client);
		
	}
	else PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T", "You need to be human and your love zombie for use it",client);
}

public Action:DID(client) 
{
	new Handle:menu = CreateMenu(DIDMenuHandler);
	
/* 	if(money[clientId]) AddMenuItem(menu, "option1", "Disable shared money");
	else AddMenuItem(menu, "option1", "Enable shared money"); */
	
	char menuitem[64];
	
	Format(menuitem,sizeof(menuitem), "%T", "Weddings Skills",client);
	SetMenuTitle(menu, menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T", "Disable beacon in your love",client);
	if(beacon[client]) AddMenuItem(menu, "option2", menuitem);
	else 
	{
		Format(menuitem,sizeof(menuitem), "%T",  "Enable beacon in your love",client);
		AddMenuItem(menu, "option2", menuitem);
	}
	
	Format(menuitem,sizeof(menuitem), "%T",  "Teleport to your love position",client);
	AddMenuItem(menu, "option3", menuitem);
	
	Format(menuitem,sizeof(menuitem), "%T",  "Sacrifice for your love",client);
	AddMenuItem(menu, "option4", menuitem);
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);

}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new casado = GetPartnerSlot(client);
		if(casado < 1)
		{
			PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T", "You need to be married and your love in the server for use this command",client);
			return;
		}
		
		new String:info[32];
        
		GetMenuItem(menu, itemNum, info, sizeof(info));
        
/* 		if ( strcmp(info,"option1") == 0 ) 
		{
			if(money[client])
			{
				money[client] = false;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Shared money disabled");
			}
			else
			{
				money[client] = true;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05Shared money enabled");
			}
			DID(client);
		} */
        
		if ( strcmp(info,"option2") == 0 ) 
		{
			if(beacon[client])
			{
				beacon[client] = false;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T","Beacon in your love disabled",client);
			}
			else
			{
				beacon[client] = true;
				PrintToChat(client, " \x04[SM_Weddings-Skills] \x05%T","Beacon in your love enabled",client);
			}
			DID(client);
		}
		else if ( strcmp(info,"option3") == 0 ) 
		{
			Teleportar(client, casado);
		}
		else if ( strcmp(info,"option4") == 0 ) 
		{
			Sacrificio(client, casado);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action OnWedding(proposer, accepter)
{
	if(!IsValidClient(proposer))
	{
		if(IsValidClient(accepter)) PrintToChat(accepter, " \x04[SM_Weddings-Skills] \x05%T","Both need to be ingame to weddings", accepter);
		return Plugin_Handled;
	}
	
	if(!IsValidClient(accepter))
	{
		if(IsValidClient(proposer)) PrintToChat(proposer, " \x04[SM_Weddings-Skills] \x05%T","Both need to be ingame to weddings", proposer);
		return Plugin_Handled;
	}
	
	if(Store_GetClientCredits(proposer) >= 3000 && Store_GetClientCredits(accepter) >= 3000)
	{
		Store_SetClientCredits(proposer, Store_GetClientCredits(proposer)-3000);
		Store_SetClientCredits(accepter, Store_GetClientCredits(accepter)-3000);

		return Plugin_Continue;
	}
	
	PrintToChat(proposer, " \x04[SM_Weddings-Skills] \x05%T","You dont have enought credits to weddings (cost 3000 credits)",proposer);
	PrintToChat(accepter, " \x04[SM_Weddings-Skills] \x05%T","You dont have enought credits to weddings (cost 3000 credits)",accepter);
	return Plugin_Handled;
}



public Action OnDivorce(proposer, accepter)
{	
	if(Store_GetClientCredits(proposer) >= 10000)
	{
		Store_SetClientCredits(proposer, Store_GetClientCredits(proposer)-10000);
		//Store_SetClientCredits(accepter, Store_GetClientCredits(accepter)-10000);

		return Plugin_Continue;
	}
	
	PrintToChat(proposer, " \x04[SM_Weddings-Skills] \x05%T","You dont have enought credits to divorce (cost 10000 credits)",proposer);
	//PrintToChat(accepter, " \x04[SM_Weddings-Skills] \x05%T","You dont have enought credits to divorce (cost 10000 credits)",accepter);
	return Plugin_Handled;
}

public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}