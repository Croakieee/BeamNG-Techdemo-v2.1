////////////////////////////////////////////////
//// Vehicle Keyboard mappings

%mm.bind( keyboard, a, moveleft );
%mm.bind( keyboard, d, moveright );
%mm.bind( keyboard, w, moveforward );
%mm.bind( keyboard, s, movebackward );

%mm.bind( keyboard, left, steer_left );
%mm.bind( keyboard, right, steer_right );
%mm.bind( keyboard, up, accelerate );
%mm.bind( keyboard, down, brake );

// shifting
%mm.bind( keyboard, lshift, clutch );
%mm.bind( keyboard, x, shiftUp);
%mm.bind( keyboard, z, shiftDown);
%mm.bind( keyboard, q, toggleShifterMode );

$np_movespeed = 0.1;
// camera/numpad
function np_x(%val)
{
   if(%val > 0)
   {
      $mvYawLeftSpeed = %val * $np_movespeed;
      $mvYawRightSpeed = 0;
   }
   else
   {
      $mvYawLeftSpeed = 0;
      $mvYawRightSpeed = -%val * $np_movespeed;
   }
}
function np_y(%val)
{
   if(%val > 0)
   {
      $mvPitchDownSpeed = %val * $np_movespeed;
      $mvPitchUpSpeed = 0;
   }
   else
   {
      $mvPitchDownSpeed = 0;
      $mvPitchUpSpeed = -%val * $np_movespeed;
   }
}
%mm.bindCmd(keyboard, numpad4, "np_x(-1);", "np_x(0);");
%mm.bindCmd(keyboard, numpad6, "np_x(1);", "np_x(0);");
%mm.bindCmd(keyboard, numpad8, "np_y(1);", "np_y(0);");
%mm.bindCmd(keyboard, numpad2, "np_y(-1);", "np_y(0);");
%mm.bindCmd(keyboard, numpad9, "gamepadZoom(-0.1);", "gamepadZoom(0);");
%mm.bindCmd(keyboard, numpad3, "gamepadZoom(0.1);", "gamepadZoom(0);");
%mm.bindCmd(keyboard, numpad5, "beamNGResetCamera();", "");
%mm.bindCmd(keyboard, numpad1, "beamNGCameraLookback();", "");
%mm.bindCmd(keyboard, tab,     "beamNGSwitchVehicle(1);", "");
%mm.bindCmd(keyboard, "shift tab", "beamNGSwitchVehicle(-1);", "");
%mm.bindCmd(keyboard, c,       "beamNGCameraToggle();", "");
//%mm.bindCmd(keyboard, "ctrl m", "reloadInputMaps();", "" );
//%mm.bindVLuaCmd(keyboard, "shift m", "inputwizard.activate()", "");

// assorted
%mm.bindCmd(keyboard, i, "beamNGResetPhysics();", "");
%mm.bindCmd(keyboard, r, "beamNGResetPhysics();", "");
%mm.bindCmd(keyboard, j, "beamNGTogglePhysics();", "");
%mm.bind(keyboard, p, parkingbrake_toggle);
%mm.bindCmd(keyboard, "ctrl r", "beamNGReloadCurrentVehicle();", "");
//%mm.bindCmd(keyboard, "shift t", "beamNGReloadSystemLua();", "");
//%mm.bindSLuaCmd(keyboard, "ctrl t", "showAIGUI()", "");

//%mm.bindCmd(keyboard, "ctrl e", "beamNGExecuteJS(\"VehicleChooser.open();\", 0);", "");
//%mm.bindVLuaCmd(keyboard, "ctrl w", "partmgmt.showGUI()", "");


//%mm.bindCmd(keyboard, "ctrl escape", "quit();", "" );
%mm.bindCmd(keyboard, "escape", "", "escapeFromGame();");

// some toolkit functions

%mm.bindVLuaCmd(keyboard, "comma", "electrics.toggle_left_signal()", "");
%mm.bindVLuaCmd(keyboard, "period", "electrics.toggle_right_signal()", "");
%mm.bindVLuaCmd(keyboard, "slash", "electrics.toggle_warn_signal()", "");
%mm.bindVLuaCmd(keyboard, "n", "electrics.toggle_lights()", "");


%mm.bindCmd(keyboard, "f1", "", "BeamNGHelpToggle();");


%mm.bindVLuaCmd(keyboard, "alt left", "bullettime.selectPreset('<')", "");
%mm.bindVLuaCmd(keyboard, "alt right", "bullettime.selectPreset('>')", "");
%mm.bindVLuaCmd(keyboard, "alt up", "bullettime.selectPreset('^')", "");
%mm.bindVLuaCmd(keyboard, "alt down", "bullettime.selectPreset('v')", "");