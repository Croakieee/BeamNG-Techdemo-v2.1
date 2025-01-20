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

if ( isObject( moveMap ) )
   moveMap.delete();
new ActionMap(moveMap);


//------------------------------------------------------------------------------
// Non-remapable binds
//------------------------------------------------------------------------------

function escapeFromGame()
{
   if ( $Server::ServerType $= "SinglePlayer" )
      MessageBoxYesNo( "Exit", "Exit to Desktop?", "quit();", "");
   else
      MessageBoxYesNo( "Disconnect", "Disconnect from the server?", "disconnect();", "");
}

//moveMap.bindCmd(keyboard, "escape", "", "handleEscape();");

//------------------------------------------------------------------------------
// Movement Keys
//------------------------------------------------------------------------------

$movementSpeed = 1; // m/s

function setSpeed(%speed)
{
   if(%speed)
      $movementSpeed = %speed;
}

function moveleft(%val)
{
   $mvLeftAction = %val * $movementSpeed;
}

function moveright(%val)
{
   $mvRightAction = %val * $movementSpeed;
}

function moveforward(%val)
{
   $mvForwardAction = %val * $movementSpeed;
}

function movebackward(%val)
{
   $mvBackwardAction = %val * $movementSpeed;
}

function moveup(%val)
{
   %object = ServerConnection.getControlObject();
   
   if(%object.isInNamespaceHierarchy("Camera"))
      $mvUpAction = %val * $movementSpeed;
}

function movedown(%val)
{
   %object = ServerConnection.getControlObject();
   
   if(%object.isInNamespaceHierarchy("Camera"))
      $mvDownAction = %val * $movementSpeed;
}

function turnLeft( %val )
{
   $mvYawRightSpeed = %val ? $Pref::Input::KeyboardTurnSpeed : 0;
}


// 3d spacemouse support :)
$absRotateAxisFactorYaw = 1;
$absRotateAxisFactorPitch = 1;
$absRotateAxisFactorRoll = 1;

$absTranslateAxisFactorX = 1;
$absTranslateAxisFactorY = 1;
$absTranslateAxisFactorZ = 1;
$yawTemp = 0;
function yawAbs(%val)
{
    $mvYaw = ($yawTemp - %val) * $absRotateAxisFactorYaw;
    echo("yawAbs(" @ $mvYaw @ ")");
    $yawTemp = %val;
}

$rollTemp = 0;
function rollAbs(%val)
{
    $mvRoll = ($rollTemp - %val) * $absRotateAxisFactorRoll;
    echo("rollAbs(" @ $mvRoll @ ")");
    $rollTemp = %val;
}

$pitchTemp = 0;
function pitchAbs(%val)
{
    $mvPitch = ($pitchTemp - %val) * $absRotateAxisFactorPitch;
    echo("pitchAbs(" @ $mvPitch @ ")");
    $pitchTemp = %val;
}

$xAxisAbsTemp = 0;
function xAxisAbs(%val)
{
    %tmp = ($xAxisAbsTemp - %val) * $absTranslateAxisFactorX;
    $mvAbsXAxis = %tmp;
    echo("xAxisAbs(" @ %tmp @ ")");
    $xAxisAbsTemp = %val;
}

$yAxisAbsTemp = 0;
function yAxisAbs(%val)
{
    %tmp = ($yAxisAbsTemp - %val) * $absTranslateAxisFactorY;
    $mvAbsYAxis = %tmp;
    echo("yAxisAbs(" @ %tmp @ ")");
    $yAxisAbsTemp = %val;
}

$zAxisAbsTemp = 0;
function zAxisAbs(%val)
{
    %tmp = ($zAxisAbsTemp - %val) * $absTranslateAxisFactorZ;
    $mvAbsZAxis = %tmp;
    echo("zAxisAbs(" @ %tmp @ ")");
    $zAxisAbsTemp = %val;
}
// 3d axis end

function turnRight( %val )
{
   $mvYawLeftSpeed = %val ? $Pref::Input::KeyboardTurnSpeed : 0;
}

function panUp( %val )
{
   $mvPitchDownSpeed = %val ? $Pref::Input::KeyboardTurnSpeed : 0;
}

function panDown( %val )
{
   $mvPitchUpSpeed = %val ? $Pref::Input::KeyboardTurnSpeed : 0;
}

function getMouseAdjustAmount(%val)
{
   // based on a default camera FOV of 90'
   return(%val * ($cameraFov / 90) * 0.01) * $pref::Input::LinkMouseSensitivity;
}

function getGamepadAdjustAmount(%val)
{
   // based on a default camera FOV of 90'
   return(%val * ($cameraFov / 90) * 0.01) * 10.0;
}

function camXChange(%val)
{
   // update beamng
   $mvCamX += getMouseAdjustAmount(%val);
   // update T3D free camera and things
   yaw(%val);
}

function camYChange(%val)
{
   // update beamng
   $mvCamY += getMouseAdjustAmount(%val);
   // update T3D free camera and things
   pitch(%val);
}

function yaw(%val)
{
   %yawAdj = getMouseAdjustAmount(%val);
   if(ServerConnection && ServerConnection.isControlObjectRotDampedCamera())
   {
      // Clamp and scale
      %yawAdj = mClamp(%yawAdj, -m2Pi()+0.01, m2Pi()-0.01);
      %yawAdj *= 0.5;
   }

   $mvYaw += %yawAdj;
}

function pitch(%val)
{
   %pitchAdj = getMouseAdjustAmount(%val);
   if(ServerConnection && ServerConnection.isControlObjectRotDampedCamera())
   {
      // Clamp and scale
      %pitchAdj = mClamp(%pitchAdj, -m2Pi()+0.01, m2Pi()-0.01);
      %pitchAdj *= 0.5;
   }
   $mvPitch += %pitchAdj;
}

function jump(%val)
{
   $mvTriggerCount2++;
}

function gamePadMoveX( %val )
{
   $mvXAxis_L = %val;
}

function gamePadMoveY( %val )
{
   $mvYAxis_L = %val;
}

function gamepadYaw(%val)
{
   %yawAdj = getGamepadAdjustAmount(%val);
   if(ServerConnection.isControlObjectRotDampedCamera())
   {
      // Clamp and scale
      %yawAdj = mClamp(%yawAdj, -m2Pi()+0.01, m2Pi()-0.01);
      %yawAdj *= 0.5;
   }

   if(%yawAdj > 0)
   {
      $mvYawLeftSpeed = %yawAdj;
      $mvYawRightSpeed = 0;
   }
   else
   {
      $mvYawLeftSpeed = 0;
      $mvYawRightSpeed = -%yawAdj;
   }
}

function gamepadPitch(%val)
{
   %pitchAdj = getGamepadAdjustAmount(%val);
   if(ServerConnection.isControlObjectRotDampedCamera())
   {
      // Clamp and scale
      %pitchAdj = mClamp(%pitchAdj, -m2Pi()+0.01, m2Pi()-0.01);
      %pitchAdj *= 0.5;
   }

   if(%pitchAdj > 0)
   {
      $mvPitchDownSpeed = %pitchAdj;
      $mvPitchUpSpeed = 0;
   }
   else
   {
      $mvPitchDownSpeed = 0;
      $mvPitchUpSpeed = -%pitchAdj;
   }
}

function gamepadZoom(%val)
{
   %pitchAdj = getGamepadAdjustAmount(%val);
   if(ServerConnection.isControlObjectRotDampedCamera())
   {
      // Clamp and scale
      %pitchAdj = mClamp(%pitchAdj, -m2Pi()+0.01, m2Pi()-0.01);
      %pitchAdj *= 0.5;
   }

   if(%pitchAdj > 0)
   {
      $mvZoomInSpeed = %pitchAdj;
      $mvZoomOutSpeed = 0;
   }
   else
   {
      $mvZoomInSpeed = 0;
      $mvZoomOutSpeed = -%pitchAdj;
   }
}
//moveMap.bind( keyboard, a, moveleft );
//moveMap.bind( keyboard, d, moveright );
//moveMap.bind( keyboard, left, moveleft );
//moveMap.bind( keyboard, right, moveright );

//moveMap.bind( keyboard, w, moveforward );
//moveMap.bind( keyboard, s, movebackward );
//moveMap.bind( keyboard, up, moveforward );
//moveMap.bind( keyboard, down, movebackward );


// dynamic bindings for lua
moveMap.bindCmd(keyboard, q, "vlua(\"input.keys.Q = true\");", "vlua(\"input.keys.Q = false\");");
moveMap.bindCmd(keyboard, e, "vlua(\"input.keys.E = true\");", "vlua(\"input.keys.E = false\");");

moveMap.bindCmd(keyboard, w, "vlua(\"input.keys.W = true\");", "vlua(\"input.keys.W = false\");");
moveMap.bindCmd(keyboard, s, "vlua(\"input.keys.S = true\");", "vlua(\"input.keys.S = false\");");

moveMap.bindCmd(keyboard, a, "vlua(\"input.keys.A = true\");", "vlua(\"input.keys.A = false\");");
moveMap.bindCmd(keyboard, d, "vlua(\"input.keys.D = true\");", "vlua(\"input.keys.D = false\");");

moveMap.bindCmd(keyboard, t, "vlua(\"input.keys.T = true\");", "vlua(\"input.keys.T = false\");");
moveMap.bindCmd(keyboard, f, "vlua(\"input.keys.F = true\");", "vlua(\"input.keys.F = false\");");

moveMap.bindCmd(keyboard, g, "vlua(\"input.keys.G = true\");", "vlua(\"input.keys.G = false\");");
moveMap.bindCmd(keyboard, h, "vlua(\"input.keys.H = true\");", "vlua(\"input.keys.H = false\");");

moveMap.bindCmd(keyboard, r, "vlua(\"input.keys.R = true\");", "vlua(\"input.keys.R = false\");");
moveMap.bindCmd(keyboard, y, "vlua(\"input.keys.Y = true\");", "vlua(\"input.keys.Y = false\");");


// default ones:
moveMap.bind( keyboard, pageup, moveup );
moveMap.bind( keyboard, pagedown, movedown );

//moveMap.bind( keyboard, space, jump );
moveMap.bind( mouse, xaxis, camXChange );
moveMap.bind( mouse, yaxis, camYChange );

//moveMap.bind( gamepad, thumbrx, "D", "-0.23 0.23", gamepadYaw );
//moveMap.bind( gamepad, thumbry, "D", "-0.23 0.23", gamepadPitch );
//moveMap.bind( gamepad, thumblx, "D", "-0.23 0.23", gamePadMoveX );
//moveMap.bind( gamepad, thumbly, "D", "-0.23 0.23", gamePadMoveY );

//moveMap.bind( gamepad, btn_a, jump );
//moveMap.bindCmd( gamepad, btn_back, "disconnect();", "" );

//moveMap.bindCmd(gamepad, dpadl, "toggleLightColorViz();", "");
//moveMap.bindCmd(gamepad, dpadu, "toggleDepthViz();", "");
//moveMap.bindCmd(gamepad, dpadd, "toggleNormalsViz();", "");
//moveMap.bindCmd(gamepad, dpadr, "toggleLightSpecularViz();", "");


//------------------------------------------------------------------------------
// Mouse Trigger
//------------------------------------------------------------------------------

function mouseFire(%val)
{
   $mvTriggerCount0++;
}

//function altTrigger(%val)
//{
   //$mvTriggerCount1++;
//}

moveMap.bind( mouse, button0, mouseFire );
//moveMap.bind( mouse, button1, altTrigger );

//------------------------------------------------------------------------------
// Gamepad Trigger
//------------------------------------------------------------------------------

function gamepadFire(%val)
{
   if(%val > 0.1 && !$gamepadFireTriggered)
   {
      $gamepadFireTriggered = true;
      $mvTriggerCount0++;
   }
   else if(%val <= 0.1 && $gamepadFireTriggered)
   {
      $gamepadFireTriggered = false;
      $mvTriggerCount0++;
   }
}

function gamepadAltTrigger(%val)
{
   if(%val > 0.1 && !$gamepadAltTriggerTriggered)
   {
      $gamepadAltTriggerTriggered = true;
      $mvTriggerCount1++;
   }
   else if(%val <= 0.1 && $gamepadAltTriggerTriggered)
   {
      $gamepadAltTriggerTriggered = false;
      $mvTriggerCount1++;
   }
}

//moveMap.bind(gamepad, triggerr, gamepadFire);
//moveMap.bind(gamepad, triggerl, gamepadAltTrigger);

//------------------------------------------------------------------------------
// Zoom and FOV functions
//------------------------------------------------------------------------------

if($Player::CurrentFOV $= "")
   $Player::CurrentFOV = $pref::Player::DefaultFOV / 2;

// toggleZoomFOV() works by dividing the CurrentFOV by 2.  Each time that this
// toggle is hit it simply divides the CurrentFOV by 2 once again.  If the
// FOV is reduced below a certain threshold then it resets to equal half of the
// DefaultFOV value.  This gives us 4 zoom levels to cycle through.

function toggleZoomFOV()
{
    $Player::CurrentFOV = $Player::CurrentFOV / 2;

    if($Player::CurrentFOV < 5)
        resetCurrentFOV();

    if(ServerConnection.zoomed)
      setFOV($Player::CurrentFOV);
    else
    {
      setFov(ServerConnection.getControlCameraDefaultFov());
    }
}

function resetCurrentFOV()
{
   $Player::CurrentFOV = ServerConnection.getControlCameraDefaultFov() / 2;
}

function turnOffZoom()
{
   ServerConnection.zoomed = false;
   setFov(ServerConnection.getControlCameraDefaultFov());

   // Rather than just disable the DOF effect, we want to set it to the level's
   // preset values.
   //DOFPostEffect.disable();
   ppOptionsUpdateDOFSettings();
}

function setZoomFOV(%val)
{
   if(%val)
      toggleZoomFOV();
}

function toggleZoom(%val)
{
   if (%val)
   {
      ServerConnection.zoomed = true;
      setFov($Player::CurrentFOV);

      DOFPostEffect.setAutoFocus( true );
      DOFPostEffect.setFocusParams( 0.5, 0.5, 50, 500, -5, 5 );
      DOFPostEffect.enable();
   }
   else
   {
      turnOffZoom();
   }
}

//moveMap.bind(keyboard, f, setZoomFOV);
//moveMap.bind(keyboard, r, toggleZoom);
//moveMap.bind( gamepad, btn_b, toggleZoom );

//------------------------------------------------------------------------------
// Camera & View functions
//------------------------------------------------------------------------------

function toggleFreeLook( %val )
{
   if ( %val )
      $mvFreeLook = true;
   else
      $mvFreeLook = false;
}

function toggleFirstPerson(%val)
{
   if (%val)
   {
      ServerConnection.setFirstPerson(!ServerConnection.isFirstPerson());
   }
}

function toggleCamera(%val)
{
   if (%val)
      commandToServer('ToggleCamera');
}

//moveMap.bind( keyboard, z, toggleFreeLook );
//moveMap.bind(keyboard, tab, toggleFirstPerson );
moveMap.bind(keyboard, "shift c", toggleCamera);

//moveMap.bind( gamepad, btn_back, toggleCamera );


//------------------------------------------------------------------------------
// Demo recording functions
//------------------------------------------------------------------------------

function startRecordingDemo( %val )
{
   if ( %val )
      startDemoRecord();
}

function stopRecordingDemo( %val )
{
   if ( %val )
      stopDemoRecord();
}

moveMap.bind( keyboard, F3, startRecordingDemo );
moveMap.bind( keyboard, F4, stopRecordingDemo );


//------------------------------------------------------------------------------
// Helper Functions
//------------------------------------------------------------------------------

function dropCameraAtPlayer(%val)
{
   if (%val)
      commandToServer('dropCameraAtPlayer');
}

function dropPlayerAtCamera(%val)
{
   if (%val)
      commandToServer('DropPlayerAtCamera');
}

moveMap.bind(keyboard, "F8", dropCameraAtPlayer);
moveMap.bind(keyboard, "F7", dropPlayerAtCamera);

function bringUpOptions(%val)
{
   if (%val) {
      Canvas.pushDialog(OptionsDlg);
      Canvas.pushDialog(PostFXManager);
   }
}

GlobalActionMap.bind(keyboard, "ctrl o", bringUpOptions);


//------------------------------------------------------------------------------
// Debugging Functions
//------------------------------------------------------------------------------

$MFDebugRenderMode = 0;
function cycleDebugRenderMode(%val)
{
   if (!%val)
      return;

   $MFDebugRenderMode++;

   if ($MFDebugRenderMode > 16)
      $MFDebugRenderMode = 0;
   if ($MFDebugRenderMode == 15)
      $MFDebugRenderMode = 16;

   setInteriorRenderMode($MFDebugRenderMode);

   if (isObject(ChatHud))
   {
      %message = "Setting Interior debug render mode to ";
      %debugMode = "Unknown";

      switch($MFDebugRenderMode)
      {
         case 0:
            %debugMode = "NormalRender";
         case 1:
            %debugMode = "NormalRenderLines";
         case 2:
            %debugMode = "ShowDetail";
         case 3:
            %debugMode = "ShowAmbiguous";
         case 4:
            %debugMode = "ShowOrphan";
         case 5:
            %debugMode = "ShowLightmaps";
         case 6:
            %debugMode = "ShowTexturesOnly";
         case 7:
            %debugMode = "ShowPortalZones";
         case 8:
            %debugMode = "ShowOutsideVisible";
         case 9:
            %debugMode = "ShowCollisionFans";
         case 10:
            %debugMode = "ShowStrips";
         case 11:
            %debugMode = "ShowNullSurfaces";
         case 12:
            %debugMode = "ShowLargeTextures";
         case 13:
            %debugMode = "ShowHullSurfaces";
         case 14:
            %debugMode = "ShowVehicleHullSurfaces";
         // Depreciated
         //case 15:
         //   %debugMode = "ShowVertexColors";
         case 16:
            %debugMode = "ShowDetailLevel";
      }

      ChatHud.addLine(%message @ %debugMode);
   }
}

GlobalActionMap.bind(keyboard, "F9", cycleDebugRenderMode);

function showMetrics(%val)
{
   if(%val)
      metrics("fps gfx shadow sfx terrain groundcover forest net");
}
GlobalActionMap.bind(keyboard, "ctrl F2", showMetrics);


//------------------------------------------------------------------------------
//
// Start profiler by pressing ctrl f3
// ctrl f3 - starts profile that will dump to console and file
//
function doProfile(%val)
{
   if (%val)
   {
      // key down -- start profile
      echo("Starting profile session...");
      profilerReset();
      profilerEnable(true);
   }
   else
   {
      // key up -- finish off profile
      echo("Ending profile session...");

      profilerDumpToFile("profilerDumpToFile" @ getSimTime() @ ".txt");
      profilerEnable(false);
   }
}

GlobalActionMap.bind(keyboard, "ctrl F3", doProfile);

//------------------------------------------------------------------------------
// Misc.
//------------------------------------------------------------------------------

//GlobalActionMap.bind(keyboard, "tilde", toggleConsole);
//GlobalActionMap.bindCmd(keyboard, "alt k", "cls();","");
//GlobalActionMap.bindCmd(keyboard, "alt enter", "", "Canvas.attemptFullscreenToggle();");
//GlobalActionMap.bindCmd(keyboard, "ctrl l", "LuaReload();", "" );


// ----------------------------------------------------------------------------
// Oculus Rift
// ----------------------------------------------------------------------------

function OVRSensorRotEuler(%pitch, %roll, %yaw)
{
   //echo("Sensor euler: " @ %pitch SPC %roll SPC %yaw);
   $mvRotZ0 = %yaw;
   $mvRotX0 = %pitch;
   $mvRotY0 = %roll;
}

$mvRotIsEuler0 = true;
$OculusVR::GenerateAngleAxisRotationEvents = false;
$OculusVR::GenerateEulerRotationEvents = true;
moveMap.bind( oculusvr, ovr_sensorrotang0, OVRSensorRotEuler );


$showFPS = false;
function toggleFPS(%val)
{
   if (%val) {
      if ($showFPS == false) {
          metrics("fps gfx terrain net groundcover forest time reflect decal shadow basicshadow light particlepart");
          $showFPS = true;
      } else {
          metrics("");
          $showFPS = false;
      }
   }
}

moveMap.bind(keyboard, "ctrl f", toggleFPS);