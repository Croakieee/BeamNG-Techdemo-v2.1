// Product Name: Logitech G25 Racing Wheel USB (with logitech drivers)
// GUID: {C299046D-0000-0000-0000-504944564944}
// axes: 5^X^S^V^Y^S

// camera
%mm.bind(%device, button0, joystickYaw);
%mm.bind(%device, button1, joystickPitch);

// movement
%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, rzaxis,"RI", brake_direct);
%mm.bind(%device, yaxis, "RI", accelerate_direct);
%mm.bind(%device, slider, "RI", clutch_direct);


%mm.bind(%device, button0, toggleShifterMode);

// paddle - left
%mm.bind(%device, button5, shiftDown);
// paddle - right
%mm.bind(%device, button4, shiftUp);

// gears
%mm.bindCmd(%device, button14, "shiftToGear(-1);", "shiftToGear(0);");
%mm.bindCmd(%device, button8,  "shiftToGear(1);",  "shiftToGear(0);");
%mm.bindCmd(%device, button9,  "shiftToGear(2);",  "shiftToGear(0);");
%mm.bindCmd(%device, button10, "shiftToGear(3);",  "shiftToGear(0);");
%mm.bindCmd(%device, button11, "shiftToGear(4);",  "shiftToGear(0);");
%mm.bindCmd(%device, button12, "shiftToGear(5);",  "shiftToGear(0);");
%mm.bindCmd(%device, button13, "shiftToGear(6);",  "shiftToGear(0);");


// we should be able to activate stick shifting and wheel range functions with this device


//%mm.bindCmd(%device, button2, "beamNGResetPhysics();", "");
//%mm.bindCmd(%device, button3, "beamNGTogglePhysics();", "");
//%mm.bind(%device, button4, parkingbrake_toggle);
//%mm.bindCmd(%device, button5, "beamNGSwitchVehicle();", "");
//%mm.bindCmd(%device, button6, "beamNGZoom(-1);", "");
//%mm.bindCmd(%device, button7, "beamNGZoom(1);", "");
//%mm.bindCmd(%device, button8, "beamNGResetCamera();", "");
//%mm.bindCmd(%device, button9, "beamNGCameraToggle();", "");
//%mm.bind(%device, btn_back, beamNGControl);
//%mm.bind(%device, btn_x, toggleFirstPerson);

echo("G25 mapping loaded");
