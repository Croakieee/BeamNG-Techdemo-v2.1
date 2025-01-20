// Product Name: XInput generic game controller

$gp_deadzone = "-0.15 0.15"; // 15% deadzone
%mm.bind       (xinput, thumbrx  , "D", $gp_deadzone, gamepadYaw);
%mm.bind       (xinput, thumbry  , "D", $gp_deadzone, gamepadPitch);
%mm.bind       (xinput, thumblx  , "D", $gp_deadzone, steer);
//%mm.bind       (xinput, thumbly  , "D", $gp_deadzone, accelerate_brake_direct);
%mm.bind       (xinput, triggerl , "D", $gp_deadzone, brake_direct);
%mm.bind       (xinput, triggerr , "D", $gp_deadzone, accelerate_direct);
%mm.bind       (xinput, btn_l    , clutch );
%mm.bind       (xinput, btn_a    , shiftUp);
%mm.bind       (xinput, btn_x    , shiftDown);
%mm.bind       (xinput, btn_r    , parkingbrake_toggle);
%mm.bindCmd    (xinput, btn_y    , "gamepadZoom(-0.1);", "gamepadZoom(0);");
%mm.bindCmd    (xinput, btn_b    , "gamepadZoom(0.1);", "gamepadZoom(0);");
%mm.bindCmd    (xinput, btn_rt   , "beamNGResetCamera();", "");
%mm.bindCmd    (xinput, btn_back , "beamNGCameraToggle();", "");
%mm.bindCmd    (xinput, btn_start, "beamNGTogglePhysics();", "");
%mm.bindVLuaCmd(xinput, dpadl    , "electrics.toggle_left_signal()", "");
%mm.bindVLuaCmd(xinput, dpadr    , "electrics.toggle_right_signal()", "");
%mm.bindVLuaCmd(xinput, dpadu    , "electrics.toggle_lights()", "");
%mm.bindVLuaCmd(xinput, dpadd    , "electrics.toggle_warn_signal()", "");
