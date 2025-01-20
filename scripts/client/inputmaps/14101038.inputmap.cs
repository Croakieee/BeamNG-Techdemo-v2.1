// Product Name: Simraceway SRW-S1
// GUID: {14101038-0000-0000-0000-504944564944}
//  - 21 objects: xaxis (axis), slider (axis), rzaxis (axis), button0 (button), button1 (button), button2 (button), button3 (button), button4 (button), button5 (button), button6 (button), button7 (button), button8 (button), button9 (button), button10 (button), button11 (button), button12 (button), button13 (button), button14 (button), button15 (button), button16 (button)


// 0 deadzone
$gp_deadzone = "-0.15 0.15";

// 5% deadzone: 
// $gp_deadzone = "-0.05 0.05";

//movement

// Gyro motion sensor steering
%mm.bind(%device, xaxis, "D", "-0.05 0.05", steer);

// Right bottom Lever for acceleration
%mm.bind(%device, slider, "R", accelerate);

// Left bottom Lever for braking and reversing, triggers button6 too
%mm.bind(%device, rzaxis, "R", brake);



//Lights button functionality
%mm.bindVLuaCmd(%device, button3, "electrics.toggle_lights()", "");
%mm.bindVLuaCmd(%device, dpov, "electrics.toggle_warn_signal()", "");

%mm.bindVLuaCmd(%device, lpov, "electrics.toggle_left_signal()", "");
%mm.bindVLuaCmd(%device, rpov, "electrics.toggle_right_signal()", "");
//D-PAD functionality: ends

//Handbrake denoted by F.Brake balance
%mm.bind(%device, button6, parkingbrake_toggle);

//L1 Clutch
//%mm.bind(%device, button4, clutch);

//Camera 
%mm.bind(%device, upov  , "D", $gp_deadzone, gamepadPitch);
//%mm.bind(%device, rzaxis  , "D", $gp_deadzone, gamepadYaw);

%mm.bind(%device, button8, shiftUp);
%mm.bind(%device, button16, shiftDown);

//Zooming in and out
%mm.bindCmd(%device, button12, "gamepadZoom(-0.1);", "gamepadZoom(0);");
%mm.bindCmd(%device, button13, "gamepadZoom(0.1);", "gamepadZoom(0);");

//CAMERA TOGGLE
%mm.bindCmd(%device, button9, "beamNGCameraToggle();", "");

//LOOK RIGHT
%mm.bindCmd(%device, button10, "np_x(1);", "np_x(0);");
//LOOK LEFT
%mm.bindCmd(%device, button2, "np_x(-1);", "np_x(0);");
//LOOK BACK
%mm.bindCmd(%device, button4, "beamNGCameraLookback();", "");

//Exit to menu
%mm.bindCmd(%device, button1, "", "handleEscape();");

//%mm.bindCmd(%device, button0, "beamNGCameraToggle();", "");
//%mm.bindCmd(%device, button10, "beamNGResetCamera();", "");

echo("Simraceway SRW-S1 Steering Wheel mapping loaded");