//-----------------------------------------------------------------------------
// Copyright (c) 2012 GarageGames, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//-----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Mission Loading & Mission Info
// The mission loading server handshaking is handled by the
// core/scripts/client/missingLoading.cs.  This portion handles the interface
// with the game GUI.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Loading Phases:
// Phase 1: Download Datablocks
// Phase 2: Download Ghost Objects
// Phase 3: Scene Lighting

//----------------------------------------------------------------------------
// Phase 1
//----------------------------------------------------------------------------

function onMissionDownloadPhase1(%missionName, %musicTrack)
{
   updateLoadingProgress(0, "postfx");

   // Load the post effect presets for this mission.
   
   /*
   // disabled the postfx preset loading code
   %path = "levels/" @ fileBase( %missionName ) @ "/" @ fileBase( %missionName ) @ $PostFXManager::fileExtension;
   echo("trying to load mission postfx settings from file: " @ %path @ " ...");
   if ( isScriptFile( %path ) )
   {
      postFXManager::loadPresetHandler( %path ); 
      echo("... file found and loaded");
   } else
   {
      echo("... file not found, loading default postfx settings");
      PostFXManager::settingsApplyDefaultPreset();
   }
   */
               
   // Close and clear the message hud (in case it's open)
   if ( isObject( MessageHud ) )
      MessageHud.close();

   // Reset the loading progress controls:
   if ( !isFunction( updateLoadingProgress ) )
      return;

   updateLoadingProgress(0, "datablocks");
}

function onPhase1Progress(%progress)
{
   if ( !isFunction( updateLoadingProgress ) )
      return;
      
   updateLoadingProgress(%progress, "");
}

function onPhase1Complete()
{
   if ( !isFunction( updateLoadingProgress ) )
      return;

   updateLoadingProgress(1, "");
}

//----------------------------------------------------------------------------
// Phase 2
//----------------------------------------------------------------------------

function onMissionDownloadPhase2()
{
   if ( !isFunction( updateLoadingProgress ) )
      return;
      
   updateLoadingProgress(0, "objects");
}

function onPhase2Progress(%progress)
{
   if ( !isFunction( updateLoadingProgress ) )
      return;
        
   updateLoadingProgress(%progress, "");
}

function onPhase2Complete()
{
   if ( !isFunction( updateLoadingProgress ) )
      return;

   updateLoadingProgress( 1, "" );
}   

function onFileChunkReceived(%fileName, %ofs, %size)
{
   if ( !isFunction( updateLoadingProgress ) )
      return;     

   updateLoadingProgress(%ofs / %size, "downloading " @ %fileName @ "...");
}

//----------------------------------------------------------------------------
// Phase 3
//----------------------------------------------------------------------------

function onMissionDownloadPhase3()
{
   if ( !isFunction( updateLoadingProgress ) )
      return;
      
   updateLoadingProgress(0, "lighting mission");
}

function onPhase3Progress(%progress)
{
   if ( !isFunction( updateLoadingProgress ) )
      return;

   updateLoadingProgress(%progress, "");
}

function onPhase3Complete()
{
   $lightingMission = false;

   if ( !isFunction( updateLoadingProgress ) )
      return;

   updateLoadingProgress(1, "nearly done");
}

//----------------------------------------------------------------------------
// Mission loading done!
//----------------------------------------------------------------------------

function onMissionDownloadComplete()
{
   // Client will shortly be dropped into the game, so this is
   // good place for any last minute gui cleanup.
}


//------------------------------------------------------------------------------
// Before downloading a mission, the server transmits the mission
// information through these messages.
//------------------------------------------------------------------------------

addMessageCallback( 'MsgLoadInfo', handleLoadInfoMessage );
addMessageCallback( 'MsgLoadDescripition', handleLoadDescriptionMessage );
addMessageCallback( 'MsgLoadInfoDone', handleLoadInfoDoneMessage );
addMessageCallback( 'MsgLoadFailed', handleLoadFailedMessage );

//------------------------------------------------------------------------------

function handleLoadInfoMessage( %msgType, %msgString, %mapName ) 
{
	// Clear all of the loading info lines:
	for( %line = 0; %line < LoadingGui.qLineCount; %line++ )
		LoadingGui.qLine[%line] = "";
	LoadingGui.qLineCount = 0;
}

//------------------------------------------------------------------------------

function handleLoadDescriptionMessage( %msgType, %msgString, %line )
{
	LoadingGui.qLine[LoadingGui.qLineCount] = %line;
	LoadingGui.qLineCount++;

   // Gather up all the previous lines, append the current one
   // and stuff it into the control
	%text = "<spush><font:Arial:16>";
	
	for( %line = 0; %line < LoadingGui.qLineCount - 1; %line++ )
		%text = %text @ LoadingGui.qLine[%line] @ " ";
   %text = %text @ LoadingGui.qLine[%line] @ "<spop>";
}

//------------------------------------------------------------------------------

function handleLoadInfoDoneMessage( %msgType, %msgString )
{
   // This will get called after the last description line is sent.
}

//------------------------------------------------------------------------------

function handleLoadFailedMessage( %msgType, %msgString )
{
   MessageBoxOK( "Mission Load Failed", %msgString NL "Press OK to return to the Main Menu", "disconnect();" );
}
