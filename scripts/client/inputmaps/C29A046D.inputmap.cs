// Product Name: Logitech Driving Force GT USB
// GUID: {C29A046D-0000-0000-0000-504944564944}
// axes: 4^X^S^Y^V

// movement
%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, rzaxis,"IR", brake_direct);
%mm.bind(%device, yaxis,"IR", accelerate_direct);


%mm.bind(%device, button13, shiftDown);
%mm.bind(%device, button12, shiftUp);

%mm.bindCmd(%device, button1, "beamNGResetPhysics();", "");
%mm.bindCmd(%device, button3, "beamNGTogglePhysics();", "");
%mm.bind(%device, button2, parkingbrake_toggle);
%mm.bindCmd(%device, button5, "beamNGSwitchVehicle();", "");
%mm.bindCmd(%device, button6, "beamNGZoom(-1);", "");
%mm.bindCmd(%device, button7, "beamNGZoom(1);", "");
%mm.bindCmd(%device, button0, "beamNGResetCamera();", "");

%mm.bindCmd(%device, button9, "beamNGCameraToggle();", "");
//%mm.bind(%device, btn_back, beamNGControl);
//%mm.bind(%device, btn_x, toggleFirstPerson);

echo("Logitech DFGT mapping loaded");
