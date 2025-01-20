// Product Name: SpaceMouse Pro

// scale the movement as its too fast otherwise
$absTranslateAxisFactorX = 0.01;
$absTranslateAxisFactorY = 0.01;
$absTranslateAxisFactorZ = 0.01;

$absRotateAxisFactorYaw   = 0.0003;
$absRotateAxisFactorPitch = 0.0003;
$absRotateAxisFactorRoll  = 0.0003;

%mm.bind(%device, zaxis, zAxisAbs);
%mm.bind(%device, xaxis, "I", xAxisAbs);
%mm.bind(%device, yaxis, yAxisAbs);

%mm.bind(%device, rzaxis, "I", yawAbs);
%mm.bind(%device, rxaxis, pitchAbs);
%mm.bind(%device, ryaxis, rollAbs);

echo("SpaceMouse Pro mapping loaded");
