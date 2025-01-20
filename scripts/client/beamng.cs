// BeamNG specific scripts

////////////////////////////////////////////////
// always load the keyboard
%mm = moveMap;
exec("./inputmaps/keyboard.inputmap.cs");
exec("./inputmaps/xi_gamepad.inputmap.cs");
%mm = "";
////////////////////////////////////////////////

////////////////////////////////////////////////
//// Joystick or Gamepad Controller bindings

// helper variables for the keyboard steering
$keybdSteerStateLeft = 0;
$keybdSteerStateRight = 0;

function steer_left( %val, %inputType ) {
   $keybdSteerStateLeft = %val;
   // check if the other arrow key is still pressed
   if(%val == 0 && $keybdSteerStateRight == 1)
   {
      steer_right(1, %inputType);
      return;
   }

   vlua("input.event(\'axisx0\', " @ -%val @ ", " @ %inputType @ ")");
}

function steer_right( %val, %inputType ) {
   $keybdSteerStateRight = %val;
   // check if the other arrow key is still pressed
   if(%val == 0 && $keybdSteerStateLeft == 1)
   {
      steer_left(1, %inputType);
      return;
   }

   vlua("input.event(\'axisx0\', " @ %val @ ", " @ %inputType @ ")");
}

function accelerate_brake_direct( %val, %inputType ) {
    if (%val > 0)
    {
        accelerate_direct(%val, %inputType);
        brake_direct(0, %inputType);
    }
    else
    {
        brake_direct(- %val, %inputType);
        accelerate_direct(0, %inputType);
    }
}

function steer( %val, %inputType ) {
   vlua("input.event(\'axisx0\', " @ %val @ ", " @ %inputType @ ")");
}

function steer_direct( %val ) {
   vlua("input.event(\'axisx0\', " @ %val @ ", 2)");
}

function accelerate( %val, %inputType ) {
   vlua("input.event(\'axisy0\', " @ %val @ ", " @ %inputType @ ")");
}

function accelerate_direct( %val ) {
   vlua("input.event(\'axisy0\', " @ %val @ ", 2)");
}

function brake( %val, %inputType ) {
   vlua("input.event(\'axisy1\', " @ %val @ ", " @ %inputType @ ")");
}

function brake_direct( %val ) {
   vlua("input.event(\'axisy1\', " @ %val @ ", 2)");
}

function parkingbrake_toggle( %val, %inputType ) {
   vlua("input.toggleEvent(\'axisy2\', " @ %val @ ", " @ %inputType @ ")");
}

function parkingbrake( %val, %inputType ) {
   vlua("input.event(\'axisy2\', " @ %val @ ", " @ %inputType @ ")");
}

function parkingbrake_direct( %val ) {
   vlua("input.event(\'axisy2\', " @ %val @ ", 2)");
}

function clutch( %val, %inputType ) {
   vlua("input.event(\'axisy3\', " @ %val @ ", " @ %inputType @ ")");
}

function clutch_direct( %val, %inputType ) {
   vlua("input.event(\'axisy3\', " @ %val @ ", 2)");
}

function shiftUp( %val ) {
   if(%val)
      vlua("drivetrain.shiftUp()");
}

function shiftDown( %val ) {
   if(%val)
      vlua("drivetrain.shiftDown()");
}

function shiftToGear( %val ) {
   vlua("drivetrain.shiftToGear(" @ %val @ ")");
}

function toggleShifterMode( %val ) {
   if(%val)
      vlua("drivetrain.toggleShifterMode()");
}

function BeamNGVehicle::activate(%this, %mode)
{
   %mm = %this.getActionMap();
   if(%mode == "1")
   {
      //vehicle was activated
      %mm.push();

      LocalClientConnection.player = %this;
   } else
   {
      // vehicle was deactivated
      %mm.pop();
   }
}

function spawnVehicle()
{
    %pos = ServerConnection.getCameraObject().position;
    %pos = VectorAdd(%pos, "5 0 0");
    %fields = "position = \"" @ %pos @ "\";";
    //%fields = %fields @ "rotation = \"" @ ServerConnection.getCameraObject().rotation @ "\";";
    %vehicle = spawnObject("BeamNGVehicle", "default_vehicle", "", %fields, "");
    %vehicle.JBeam = "hatch";
    %vehicle.spawnObject();
    %vehicle.setName("clone");

    beamNGSwitchVehicle(1);

    MissionGroup.add( %vehicle );
}

function BeamNGVehicle::tryLoadMappingFromDir(%this, %mm, %device, %basedir, %guid, %productName, %vidpidstr)
{
   // try 1: The Vendor ID and Product ID combined
   %joyMap = %basedir@"/" @ strlwr(%vidpidstr) @ ".inputmap.cs";
   %joyMap = stripChars(%joyMap, "{}-");
   %lstr = "  - trying to load mapping via VendorID/ProductID: " @ %joyMap;
   if (isFile(%joyMap)) {
      exec(%joyMap);
      %this.lua("input.rawDevices['"@%device@"']['loaded_fn'] = '"@%joyMap@"'");
      echo(%lstr @ " - SUCCESSFUL");
      return true;
   } else {
      echo(%lstr @ " - file not existing");
   }
   %this.lua("input.rawDevices['"@%device@"']['filename_a'] = '"@%joyMap@"'");

   // try 2: the name
   %mapName = stripChars(strlwr(%productName), "+*!@#$%^&_[]|\/<>=~`\"',.;:?() {}-");
   %joyMap = %basedir@"/" @ %mapName @ ".inputmap.cs";
   %lstr = "  - trying to load mapping via name: " @ %joyMap;
   if (isFile(%joyMap)) {
      exec(%joyMap);
      %this.lua("input.rawDevices['"@%device@"']['loaded_fn'] = '"@%joyMap@"'");
      echo(%lstr @ " - SUCCESSFUL");
      return true;
   } else {
      echo(%lstr @ " - file not existing");
   }
   %this.lua("input.rawDevices['"@%device@"']['filename_b'] = '"@%joyMap@"'");

   /*
   // try 3: the full guid
   %joyMap = %basedir@"/" @ strlwr(%guid) @ ".inputmap.cs";
   %joyMap = stripChars(%joyMap, "{}-");
   if (isFile(%joyMap)) {
      echo("  - trying to load mapping via full GUID: " @ %joyMap);
      exec(%joyMap);
      %this.lua("input.rawDevices['"@%device@"']['loaded_fn'] = '"@%joyMap@"'");
      return true;
   } else {
      echo("  - joystick specific mapping file not found: " @ %joyMap);
   }
   %this.lua("input.rawDevices['"@%device@"']['filename_a'] = '"@%joyMap@"'");
   */
}

// 0 = unload
// 1 = add, but not load
// 2 = add and load
function beamngPrefabState(%val, %objName, %objFileName, %objPos, %objRotation, %objScale)
{
	if(%val != 0 && !isObject(%objName)) {
		echo("adding prefab " @ %objName);
		// load it
		%p = new Prefab(%objName) {
			filename = %objFileName;
			loadMode = "Manual";
			position = %objPos;
			rotation = %objRotation;
			scale    = %objScale;
			canSave  = "1";
			canSaveDynamicFields = "1";
		};
		MissionCleanup.add(%p);
		if(%val == 2) {
			echo("loading prefab " @ %objName);
			%p.load();
		}
	} else if(%val == 0 && isObject(%objName)) {
		echo("unloading prefab " @ %objName);
		%objName.unload();
		%objName.delete();
	}
}

function GameTSCtrl::onRightMouseDown( %this )
{
	hideCursor();
	%this.setEnabledControl(false);
	Canvas.alwaysHandleMouseButtons = true;
}


function GameTSCtrl::onRightMouseUp( %this )
{
	showCursor();
	%this.setEnabledControl(true);
	Canvas.alwaysHandleMouseButtons = false;
}

function reloadInputMaps()
{
   %obj = LocalClientConnection.getControlObject();
   if (!isObject(%obj)) return;
   if( %obj.isMethod( "reloadInputMaps" ) )
      %obj.reloadInputMaps();
}

function BeamNGVehicle::init( %this, %vehiclePath )
{
   %this.vehiclePath = %vehiclePath;
   %this.reloadInputMaps();
}

$BeamNGHelpDisplay = false;
function BeamNGHelpToggle(%unused) {
    $BeamNGHelpDisplay = !$BeamNGHelpDisplay;
    beamNGExecuteJS("HookManager.trigger('HelpToggle',"@ $BeamNGHelpDisplay @ ")", 1);
}

function BeamNGVehicle::postSpawn( %this )
{
   // support for old beamngDiffuseColorSlot
   %matCount = %this.getTargetCount();
   for( %i = 0; %i < %matCount; %i++ )
   {
      %matName = %this.getTargetName(%i);
      if(%matName !$= "")
      {
         %mat = getMaterialMapping( %matName );
         %changed = 0;
         if(%this.color !$= "" && %this.color !$= "0 0 0 0" && %mat.beamngDiffuseColorSlot !$= "")
         {
            %mat.instanceDiffuse[%mat.beamngDiffuseColorSlot] = true;
            %changed = 1;
         }
         if(%changed == 1)
         {
            %mat.flush();
            %mat.reload();
         }
      }
   }
}

function BeamNGVehicle::reloadInputMaps( %this )
{
   echo(" *** initializing vehicle (T3D side) *** ");
   %mm = %this.getActionMap();
   //echo(" %this.getActionMap()" @ %mm);
   %this.lua("input.rawDevices = {}");
    // dynamically load joystick maps
    if( !isJoystickDetected() )
    {
       echo("no joysticks or gamepads detected.");
    }
    // thid might detect new devices:
    //restartDirectInputSystem();
   %devices = getRegisteredDevices();
   %count = getWordCount(%devices);
   for (%i = 0; %i < %count; %i++)
   {
     %device = getWord( %devices, %i );
     echo("*** " @ %device @ " ***");
     if ( strstr(%device, "mouse") == -1 && strstr(%device, "keyboard") == -1)
     {
        // unbind joysticks and gamepad and so on
        echo(" (unbinding...)");
        if(!moveMap.unbindDevice(%device))
           echo(" *** unbinding failed!");
     }
     %guid = getProductGUID(%device);
     %productName = getProductName(%device);
     %pidvid = getVendorIDProductID(%device);
     %pid = getWord( %pidvid, 0 );
     %vid = getWord( %pidvid, 1 );
     %vidpidstr = %pid@%vid; // same thing without the space in the middle
     echo(" - Product Name: " @ %productName);
     echo(" - Product ID: " @ %pid);
     echo(" - Vendor ID: " @ %vid);
     echo(" - GUID: " @ %guid);
     %features = getFeaturesString(%device);
     echo(" - " @ %features);

     %this.lua("input.rawDevices['"@%device@"'] = {}");

     %basedir = "scripts/client/inputmaps/custom";
     if(!%this.tryLoadMappingFromDir(%mm, %device, %basedir, %guid, %productName, %vidpidstr))
     {
        // try the normal dir
        %basedir = "scripts/client/inputmaps";
        if(!%this.tryLoadMappingFromDir(%mm, %device, %basedir, %guid, %productName, %vidpidstr))
        {
           echo("--- unable to find mapping for this controller ---");
        }
     }

     // then load all vehicle specific maps
     %basedir = %this.vehiclePath @ "inputmaps";
     %this.tryLoadMappingFromDir(%mm, %device, %basedir, %guid, %productName, %vidpidstr);

     // update lua
     %this.lua("input.rawDevices['"@%device@"']['product_id'] = '"@%pid@"'");
     %this.lua("input.rawDevices['"@%device@"']['vendor_id'] = '"@%vid@"'");
     %this.lua("input.rawDevices['"@%device@"']['product_name'] = '"@%productName@"'");
     %this.lua("input.rawDevices['"@%device@"']['guid'] = '"@%guid@"'");
     %this.lua("input.rawDevices['"@%device@"']['features'] = '"@%features@"'");
   }
   echo(" *** loading input map DONE *** ");

   // now bind the connect event to the above function
   moveMap.bindCmd(joystick0, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(joystick1, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(joystick2, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(joystick3, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(joystick4, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(gamepad0, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(gamepad1, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(gamepad2, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(gamepad3, connect, "reloadInputMaps();", "");
   moveMap.bindCmd(gamepad4, connect, "reloadInputMaps();", "");
   //moveMap.save("input-save.cs");

   %this.lua("input.mapsReloaded()");

   echo(" *** done intializing vehicle (T3D side) *** ");
}

//reloadInputMaps();



//$Camera = LocalClientConnection.camera;

function tpc()
{
    %p = createCameraFollowPath(exampleCamPath, myPathCam);
    //$savecamera = $Camera;
    //$Camera = %p;
    LocalClientConnection.setControlObject(%p);
    //%p.setTarget(0);
}

function createCameraFollowPath(%path, %name)
{
    if( isObject(%path) && %path.getCount())
    {
        %pathNode = %path.getObject(0);
        %pos = %pathNode.position;
        %rot = %pathNode.rotation;
		echo ("camera inital pos: " @ %pos);
		echo ("camera inital rot: " @ %rot);
		if(isObject(%name)) {
			%name.delete();
		}
        %p = new PathCamera(%name) {
            dataBlock = PathCameraDatablock;
            position = %pos;
			rotation = %rot;
        };
		%p.reset(%pathNode.msToNext);

        for(%i = 1; %i < %path.getCount(); %i++) {
            %pathNode  = %path.getObject(%i);
            %transform = %pathNode.getTransform();
            %p.pushBack(%transform, %pathNode.msToNext, %pathNode.type, %pathNode.smoothingType);
        }

        return %p;
    }
}

function myPathCam::onNode (%this, %nodeIdx) //A script callback that indicates the path camera has arrived at a specific node in its path. Server side only.
{
   echo("pathCam::onNode: " @ %this SPC %this.getTransform() SPC %nodeIdx);
   /*
   if(%nodeIdx == 15) {
	   %this.setTarget(0);
   }
   if(%nodeIdx == 3) {
	   %this.setTarget(15);
   }
   */
}

echo("### beamng.cs loaded");