// Product Name: Fanatec Porsche 911 Turbo S Wheel
// GUID: {01970EB7-0000-0000-0000-504944564944}
// axes: 5^X^S^V^Y^S

//button0 = unmarked upper left left
//button1 = LSB
//button2 = unmarked upper left right
//button3 = RSB
//button4 = X
//button5 = A
//button6 = Y
//button7 = B
//button8 = left paddle
//button9 = right paddle
//button10 = back
//button11 = start
//button12-17 = gears 1-6
//button18 = reverse

// movement
%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, rzaxis, "IRD", "-0.02 0.02", brake_direct);
%mm.bind(%device, yaxis, "IRD", "-0.02 0.02", accelerate_direct);
%mm.bind(%device, slider, "IRD", "-0.02 0.02", clutch_direct);

%mm.bind(%device, button10, toggleShifterMode);

// paddle - left
%mm.bind(%device, button8, shiftDown);
// paddle - right
%mm.bind(%device, button9, shiftUp);

%mm.bind(%device, button6, parkingbrake_toggle);

//camera controls
%mm.bindCmd(%device, button4, "beamNGCameraToggle();", "");

%mm.bindCmd(%device, lpov, "np_x(-1);", "np_x(0);");
%mm.bindCmd(%device, rpov, "np_x(1);", "np_x(0);");
%mm.bindCmd(%device, upov, "np_y(1);", "np_y(0);");
%mm.bindCmd(%device, dpov, "np_y(-1);", "np_y(0);");

%mm.bindCmd(%device, button5, "beamNGResetCamera();", "");

//lights
%mm.bindVLuaCmd(%device, button0, "electrics.toggle_lights()", "");
%mm.bindVLuaCmd(%device, button2, "electrics.toggle_warn_signal()", "");

%mm.bindVLuaCmd(%device, button1, "electrics.toggle_left_signal()", "");
%mm.bindVLuaCmd(%device, button3, "electrics.toggle_right_signal()", "");

// gears
%mm.bindCmd(%device, button18, "shiftToGear(-1);", "shiftToGear(0);");
%mm.bindCmd(%device, button12,  "shiftToGear(1);",  "shiftToGear(0);");
%mm.bindCmd(%device, button13,  "shiftToGear(2);",  "shiftToGear(0);");
%mm.bindCmd(%device, button14, "shiftToGear(3);",  "shiftToGear(0);");
%mm.bindCmd(%device, button15, "shiftToGear(4);",  "shiftToGear(0);");
%mm.bindCmd(%device, button16, "shiftToGear(5);",  "shiftToGear(0);");
%mm.bindCmd(%device, button17, "shiftToGear(6);",  "shiftToGear(0);");

%mm.bindCmd(%device, button11, "beamNGTogglePhysics();", "");
