// this file is the interface for CEF <--> T3D

////////////////////////////////
// LevelList
////////////////////////////////
function getLevelList()
{
   %levels = new ArrayObject();
   for(%file = findFirstFile($Server::MissionFileSpec); %file !$= ""; %file = findNextFile($Server::MissionFileSpec))
   {
      if (strstr(%file, "newMission.mis") > -1)
         continue;      
      if (strstr(%file, "newLevel.mis") > -1)
         continue;
      if (strstr(%file, "menu.mis") > -1)
         continue;
      %levels.add(%file);
   }
   
   %i = 0;
   %json = "[";
   %count = %levels.count();
   for (%j = 0; %j < %count-1; %j++)
   {
      %json = %json @ _getMissionInfo( %levels.getKey(%j) ) @ ", ";
   }
   %json = %json @ _getMissionInfo( %levels.getKey( %count - 1 ) ) @ "]";
   echo(%json);
   return %json;
}

function _getMissionInfo( %file )
{
   %levelName = fileBase(%file);
   %levelBasename = %levelName;
   %levelDesc = "A Torque level";

   %LevelInfoObject = _getLevelInfo(%file);

   if (%LevelInfoObject != 0)
   {
      if(%LevelInfoObject.levelName !$= "")
         %levelName = %LevelInfoObject.levelName;
      else if(%LevelInfoObject.name !$= "")
         %levelName = %LevelInfoObject.name;

      if (%LevelInfoObject.desc0 !$= "")
         %levelDesc = %LevelInfoObject.desc0;
         
      %LevelInfoObject.delete();
   }

   return "[\"" @ %levelBasename @ "\",\"" @ %levelName @ "\",\"" @ escape_JSON(%levelDesc) @ "\"]";
}

function _getLevelInfo( %missionFile ) 
{
   %file = new FileObject();
   
   %LevelInfoObject = "";
   
   if ( %file.openForRead( %missionFile ) ) {
      %inInfoBlock = false;
      
      while ( !%file.isEOF() ) {
         %line = %file.readLine();
         %line = trim( %line );
         
         if( %line $= "new ScriptObject(LevelInfo) {" )
            %inInfoBlock = true;
         else if( %line $= "new LevelInfo(theLevelInfo) {" )
            %inInfoBlock = true;
         else if( %inInfoBlock && %line $= "};" ) {
            %inInfoBlock = false;
            %LevelInfoObject = %LevelInfoObject @ %line; 
            break;
         }
         
         if( %inInfoBlock )
            %LevelInfoObject = %LevelInfoObject @ %line @ " ";    
      }
      
      %file.close();
   }
   %file.delete();

   if( %LevelInfoObject !$= "" )
   {
      %LevelInfoObject = "%LevelInfoObject = " @ %LevelInfoObject;
      eval( %LevelInfoObject );

      return %LevelInfoObject;
   }
   
   // Didn't find our LevelInfo
   return 0; 
}

function escape_JSON(%str)
{
	%str = strreplace(%str,"\n","\\\n");
	%str = strreplace(%str,"\"","\\\"");
}

////////////////////////////////
// VehicleList
////////////////////////////////
function getVehicleList()
{
   %json = "{";
   %vehiclesPath = "vehicles/";
   %vehiclesList = getDirectoryList( %vehiclesPath );
   
   %count = getFieldCount( %vehiclesList );
   %separatorChar = "";
   for( %i = 0; %i < %count; %i++ )
   {
      %vehicle = GetField( %vehiclesList, %i );
      %vehicleName = %vehicle;
      
      //filter valid vehicle directories
      %res = findFirstFile( %vehiclesPath @ %vehicle @ "/*.jbeam" );
      if( %res $= "" )
         continue;
      
      if(%vehicle $= "common") continue;
      %vfn = %vehiclesPath @ %vehicle @ "/name.cs";
      if(isFile(%vfn))
         exec(%vfn);
      
      %json = %json @ %separatorChar @ "\"" @ %vehicle @ "\" : {\"name\":\"" @ %vehicleName @ "\", \"configs\":" @ _getVehicleConfigurations(%vehicle) @ "}";

      %separatorChar = ",";
   }

   %json = %json @ "}";
   return %json;
}

function _getVehicleConfigurations(%cv)
{
   %json = "{";

   %filefilter = "vehicles/" @ %cv @ "/*.pc";
   %i = 0;
   for( %fileC = findFirstFile( %filefilter );
      %fileC !$= "";
      %fileC = findNextFile( %filefilter ))
   {
      %configName = fileBase(%fileC);
      %configFile = %configName;
      //echo(" * found vehicle config: "@ %fileC);
      %vfn = %fileC @ ".cs";
      if(isFile(%vfn))
         exec(%vfn);
      
      %json = %json @  "\"" @ %configFile @  "\":{\"name\":\"" @ %configName @ "\", \"file\":\"" @ %fileC @ "\"},";
   }

   %json = %json @ "\"\":{\"name\":\"Default\",\"file\":\"\"}}";

   return %json;
}

////////////////////////////////
// AppList
////////////////////////////////
function getAppList()
{
   %appPath = "html/apps/";
   %appList = getDirectoryList( %appPath );
   %json = "[\"";

   %count = getFieldCount( %appList );
   for( %i = 0; %i < %count - 1; %i++ )
   {
      %json = %json  @ GetField( %appList, %i ) @ "\", \"";
   }
   %json = %json  @ GetField( %appList, %count - 1 ) @ "\"]";

   return %json;
}

function getVehicle()
{
   %obj = LocalClientConnection.getControlObject();
   if (!isObject(%obj))
      return;
   if( %obj.isMethod( "requestReload" ) == false )
      return;

   return "{\"model\": \"" @ %obj.JBeam @ "\", \"configuration\": \"" @ %obj.partConfig @ "\", \"color\": \"" @ %obj.color @ "\"}";
}

function chooseVehicle( %vehicle, %configuration, %color )
{
   %obj = LocalClientConnection.getControlObject();
   if (!isObject(%obj))
      return;
   if( %obj.isMethod( "requestReload" ) == false )
      return;

   if(%color $= "")
      %color = "0 0 0 0";

   %obj.JBeam = %vehicle;
   %obj.partConfig = %configuration;
   %obj.color = %color;

   if(%configuration !$= "")
   {
      %obj.lua("partmgmt.load('" @ %configuration @ "', 0, false)");
   }else{
      %obj.lua("partmgmt.resetConfig()");
   }

   %obj.requestReload();
}

function getCEFOptions()
{
   %res = "{childs:{graphics:{name:'Graphics',childs:{";

   /////////////////////////////////////////////////////////////////////////////
   // resolutions
   /////////////////////////////////////////////////////////////////////////////
   %res = %res @ "resolutions:{name:'Resolutions',description:'These are the display resolutions',type:'combo',options:[";
   %resCount = Canvas.getModeCount();
   for (%i = 0; %i < %resCount; %i++)
   {
      %testResString = Canvas.getMode(%i);
      %testRes = _makePrettyResString(%testResString);
      %res = %res @ "'" @ %testRes @ "',";
   }
   %currentModeStr = _makePrettyResString( $pref::Video::mode );
   %res = %res @ "'" @ %currentModeStr @ "'],val:'" @ %currentModeStr @ "'},";
   /////////////////////////////////////////////////////////////////////////////

   %res = %res @ "}}}}";
   %cmd = "receiveOptions(" @ %res @ ");";
   echo(%cmd);
   beamNGExecuteJS(%cmd, 1);
}


function _makePrettyResString( %resString )
{
   %width = getWord( %resString, $WORD::RES_X );
   %height = getWord( %resString, $WORD::RES_Y );
   
   %aspect = %width / %height;
   %aspect = mRound( %aspect * 100 ) * 0.01;            
   
   switch$( %aspect )
   {
      case "1.33":
         %aspect = "4:3";
      case "1.78":
         %aspect = "16:9";
      default:
         %aspect = "";
   }
   
   %outRes = %width @ " x " @ %height;
   if ( %aspect !$= "" )
      %outRes = %outRes @ "  (" @ %aspect @ ")";

   return %outRes;   
}

function startLevel( %mission, %hostingType ) {
   // if we are connected, disconnect first
   if ( isObject( ServerGroup ) )
         disconnect();

   // So we can't fire the button when loading is in progress.
   if ( isObject( ServerGroup ) )
      return;

   _startLevel( %mission, %hostingType);
}

function _startLevel( %mission, %hostingType ) {
   %missionFile = expandMissionFileName( %mission );
   if ( %missionFile $= "" )
      return false;

   if (%hostingType !$= "")
   {
      %serverType = %hostingType;
   }
   else
   {
      if ($pref::HostMultiPlayer)
         %serverType = "MultiPlayer";
      else
         %serverType = "SinglePlayer";
   }

   // Show the loading screen immediately.
   if ( isObject( LoadingGui ) )
   {
      Canvas.setContent("LoadingGui");
      updateLoadingProgress(1, "loading level");
   }

   // let loading gui load first
   schedule("1500", 0, createAndConnectToLocalServer, %serverType, %missionFile);
}