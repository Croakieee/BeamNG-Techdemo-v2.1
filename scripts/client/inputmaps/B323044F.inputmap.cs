// Product Name: Thrustmaster Dual Trigger 3-in-1
// GUID:  {05C4054C-0000-0000-0000-504944564944}
//  - 21 objects: rzaxis (axis), zaxis (axis), yaxis (axis), xaxis (axis), button0 (button), button1 (button), button2 (button), button3 (button), button4 (button) , button5 (button), button6 (button), button7 (button), button8 (button), button9 (button), button10 (button), button11 (button), button12 (button), button13 (button), ryaxis (axis), rxaxis (axis)


// 0 deadzone
$gp_deadzone = "-0.15 0.15";

// 5% deadzone: 
// $gp_deadzone = "-0.05 0.05";

//movement

// Thumb Left X axis
%mm.bind(%device, xaxis, "D", "-0.05 0.05", steer);

// L2 for braking and reversing, triggers button6 too
%mm.bind(%device, rxaxis, "RI", brake);

// R2 for accelerating, triggers button 7
%mm.bind(%device, ryaxis, "RI", accelerate);

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

//Camera 
%mm.bind(%device, zaxis  , "D", $gp_deadzone, gamepadYaw);
%mm.bind(%device, rzaxis  , "D", $gp_deadzone, gamepadPitch);

//Unassigned
%mm.bind(%device, button0, shiftUp);
%mm.bind(%device, button3, shiftDown);

%mm.bind(%device, button6, shiftDown);
%mm.bind(%device, button7, shiftDown);

//Zooming in and out
%mm.bindCmd(%device, button1, "gamepadZoom(0.1);", "gamepadZoom(0);");
%mm.bindCmd(%device, button2, "gamepadZoom(-0.1);", "gamepadZoom(0);");

%mm.bind(%device, button8, "beamNGCameraToggle();", "");


//%mm.bindCmd(%device, button0, "beamNGCameraToggle();", "");
//%mm.bindCmd(%device, button10, "beamNGResetCamera();", "");

echo("PS 4 Controller mapping loaded");