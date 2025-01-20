// Product Name: Logitech Dual Action
// GUID: {C216046D-0000-0000-0000-504944564944}
// axes: 4^V^Z^Y^X

// 0 deadzone
$gp_deadzone = "-0.15 0.15";

// 5% deadzone: 
// $gp_deadzone = "-0.05 0.05";

// camera
%mm.bindCmd(%device, rpov, "np_x(-1);", "np_x(0);");
%mm.bindCmd(%device, lpov, "np_x(1);", "np_x(0);");
%mm.bindCmd(%device, upov, "np_y(1);", "np_y(0);");
%mm.bindCmd(%device, dpov, "np_y(-1);", "np_y(0);");

//movement
%mm.bind(%device, xaxis, steer);
%mm.bind(%device, yaxis, "I", brake);
%mm.bind(%device, rzaxis, "I", accelerate);
%mm.bind(%device, button5, brake);
%mm.bind(%device, button7, parkingbrake);
%mm.bind(%device, button6, shiftDown);
%mm.bind(%device, button4, shiftUp);
%mm.bind(%device, button3, toggleShifterMode);
%mm.bindCmd(%device, button0, "beamNGCameraToggle();", "");
%mm.bindCmd(%device, button10, "beamNGResetCamera();", "");

echo("Logitech Dual Action mapping loaded");