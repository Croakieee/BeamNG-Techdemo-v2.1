// Product Name: Thrustmaster TX F458

%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, yaxis,"I", brake_direct);
%mm.bind(%device, rzaxis, "I", accelerate_direct);
%mm.bind(%device, slider, "", clutch_direct);

echo("TX F458 mapping loaded");
