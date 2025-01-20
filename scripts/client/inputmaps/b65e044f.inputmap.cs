// Product Name: Thrustmaster RS500

%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, yaxis,"I", brake_direct);
%mm.bind(%device, rzaxis, "I", accelerate_direct);
%mm.bind(%device, slider, "", clutch_direct);

echo("RS500 mapping loaded");
