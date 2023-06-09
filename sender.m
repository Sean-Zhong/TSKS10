% Sender takes two sampled audio files and returns a signal that is:
%   1. Upsampled to 400 kHz
%   2. I/Q-Modulated
%   3. a chirp pulse shape for the first 5 seconds of the signal
function signal = sender(xI, xQ)

% Constants
signal_len = 2e6; 
f_upsampled = 400e3; 
% Given params in parametrar.txt
lower_band = 35e3;
upper_band = 55e3;
% Carrier frequency in between lower_band and upper_band
f_carrier = (lower_band + upper_band) / 2;
% Used when generating chirp to prevent distrubing otherb freq bands
chirp_offset = 7000;

% init signal
signal = zeros(length(xQ), 1);
t = linspace(0, ((signal_len-1)/f_upsampled), signal_len);

% Saves the energy in xI and xQ before upsampling
xI_pre_energy = norm(xI)^2;
xQ_pre_energy = norm(xQ)^2;

% Upsampling to 400 kHz
xI = upsample(xI, 20);
xQ = upsample(xQ, 20);
   
% Fir filtration of the signals
[b, a] = fir1(200, 0.05, 'low');
xI = filter(b, a, xI);
xQ = filter(b, a, xQ);

% Energy in xI and xQ after upsampling and filtration
xI_post_energy = norm(xI)^2;
xQ_post_energy = norm(xQ)^2;

% Compensate for the shifting introduced by the fir filter
xI = [xI(101:length(xI))' zeros(1, 100)];
xQ = [xQ(101:length(xQ))' zeros(1, 100)];

% Correct signal energy
xI = xI*(xI_pre_energy/xI_post_energy);
xQ = xQ*(xQ_pre_energy/xQ_post_energy);

%I I/Q-Modulation
for i = 1:length(xI)
    signal(i) = xI(i)*cos(2*pi*f_carrier*t(i)) - xQ(i)*sin(2*pi*f_carrier*t(i));
end

% Chirp is added to the signal
generated_chirp = chirp(t, lower_band+chirp_offset, 3, upper_band-chirp_offset); %started later and ended early to not interfere with other freq bands

% Write generated chirp and signal into one final signal
signal = [generated_chirp signal']';

end