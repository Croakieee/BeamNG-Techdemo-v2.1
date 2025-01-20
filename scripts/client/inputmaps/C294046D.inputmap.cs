// Product Name: Logitech G25 Racing Wheel USB (with windows drivers)
// GUID: {C299046D-0000-0000-0000-504944564944}
// axes: 5^X^S^V^Y^S

// camera
%mm.bind(%device, button0, joystickYaw);
%mm.bind(%device, button1, joystickPitch);

// movement
%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, yaxis, brake_direct);
%mm.bind(%device, ryaxis, accelerate_direct);

%mm.bindCmd(%device, button2, "beamNGResetPhysics();", "");
%mm.bindCmd(%device, button3, "beamNGTogglePhysics();", "");
%mm.bind(%device, button4, parkingbrake_toggle);
%mm.bindCmd(%device, button5, "beamNGSwitchVehicle();", "");
%mm.bindCmd(%device, button6, "beamNGZoom(-1);", "");
%mm.bindCmd(%device, button7, "beamNGZoom(1);", "");
%mm.bindCmd(%device, button8, "beamNGResetCamera();", "");

%mm.bindCmd(%device, button9, "beamNGCameraToggle();", "");
//%mm.bind(%device, btn_back, beamNGControl);
//%mm.bind(%device, btn_x, toggleFirstPerson);

echo("G25 mapping loaded");
