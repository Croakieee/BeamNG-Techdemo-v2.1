// Product Name: Logitech Momo Racing Force Feedback Wheel)
// GUID: {CA03046D-0000-0000-0000-504944564944}
// axes: 

//%device = "{CA03046D-0000-0000-0000-504944564944}-" @ %joyNum;
%device = "joystick" @ %joyNum;

// camera
%mm.bindCmd(%device, button2, "np_x(1);", "np_x(0);");
%mm.bindCmd(%device, button3, "np_x(-1);", "np_x(0);");

// movement
%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, rzaxis,"RI", brake_direct);
%mm.bind(%device, yaxis, "RI", accelerate_direct);

%mm.bind(%device, button9, toggleShifterMode);

// paddle - left
%mm.bind(%device, button0, shiftDown);
// paddle - right
%mm.bind(%device, button1, shiftUp);


%mm.bindCmd(%device, button7, "beamNGResetPhysics();", "");
//%mm.bindCmd(%device, button7, "beamNGTogglePhysics();", "");
%mm.bind(%device, button8, parkingbrake_toggle);
%mm.bindCmd(%device, button6, "beamNGSwitchVehicle();", "");
//%mm.bindCmd(%device, button6, "beamNGZoom(-1);", "");
//%mm.bindCmd(%device, button7, "beamNGZoom(1);", "");
%mm.bindCmd(%device, button5, "beamNGResetCamera();", "");
%mm.bindCmd(%device, button4, "beamNGCameraToggle();", "");
%mm.bind(%device, xaxis, steer_direct);
//%mm.bind(%device, btn_back, beamNGControl);
//%mm.bind(%device, btn_x, toggleFirstPerson);

echo("Momo FFB mapping loaded");