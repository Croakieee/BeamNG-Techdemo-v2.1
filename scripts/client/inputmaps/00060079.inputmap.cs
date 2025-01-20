// Product Name: Generic USB Joystick
// GUID: {00060079-0000-0000-0000-504944564944}
//  - 18 objects: rzaxis (axis), zaxis (axis), zaxis (axis), yaxis (axis), xaxis (axis), button0 (button), button1 (button), button2 (button), button3 (button), button4 (button), button5 (button), button6 (button), button7 (button), button8 (button), button9 (button), button10 (button), button11 (button)


// 0 deadzone
$gp_deadzone = "-0.15 0.15";

// 5% deadzone: 
// $gp_deadzone = "-0.05 0.05";

//movement

// Thumb Left X axis
%mm.bind(%device, xaxis, "D", "-0.05 0.05", steer);

// L2 for braking and reversing, triggers button6 too
%mm.bind(%device, rxaxis, "R", brake);

// R2 for accelerating, triggers button 7
%mm.bind(%device, ryaxis, "R", accelerate);

//D-PAD functionality: starts
%mm.bindVLuaCmd(%device, upov, "electrics.toggle_lights()", "");
%mm.bindVLuaCmd(%device, dpov, "electrics.toggle_warn_signal()", "");

%mm.bindVLuaCmd(%device, lpov, "electrics.toggle_left_signal()", "");
%mm.bindVLuaCmd(%device, rpov, "electrics.toggle_right_signal()", "");
//D-PAD functionality: ends

//R1 Handbrake
%mm.bind(%device, button5, parkingbrake_toggle);

//L1 Clutch
%mm.bind(%device, button4, clutch);

//Camera device
%mm.bind(%device, zaxis  , "D", $gp_deadzone, gamepadYaw);
%mm.bind(%device, rzaxis  , "D", $gp_deadzone, gamepadPitch);

%mm.bind(%device, button0, shiftUp);
%mm.bind(%device, button1, shiftDown);
%mm.bind(%device, button2, "gamepadZoom(0.1);", "beamNGZoom(0);");
%mm.bind(%device, button3, "gamepadZoom(-0.1);", "beamNGZoom(0);");

%mm.bind(%device, button8, "beamNGCameraToggle();", "");


//%mm.bindCmd(%device, button0, "beamNGCameraToggle();", "");
//%mm.bindCmd(%device, button10, "beamNGResetCamera();", "");

echo("PS 4 Controller mapping loaded");