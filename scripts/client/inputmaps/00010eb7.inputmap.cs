// fanatec wheelbase v2

%mm.bind(%device, xaxis, steer_direct);
%mm.bind(%device, rzaxis,"I", brake_direct);
%mm.bind(%device, yaxis, "I", accelerate_direct);
%mm.bind(%device, slider, "", clutch_direct);
