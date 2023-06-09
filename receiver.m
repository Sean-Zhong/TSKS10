% Reciever recieves a signal from the channel and returns audio samples and
% the properties of the channel. The reciever will:
%   1. Filter out all information outside of its frequency band
%   2. Determine the scaling and delay introduced by the communication channel
%   3. I/Q-Demodulate the signal of the two sent audio files
%   4. Downsample the signal recieved to its original frequency.
function [zI, zQ, A, tau] = receiver(signal)

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
t = linspace(0, ((signal_len-1)/f_upsampled), signal_len);

% Filter out everything outside the given frequency band with a bandpass
% filter
[b, a] = fir1(200, [2*lower_band/f_upsampled 2*upper_band/f_upsampled]);
signal = filter(b, a, signal);
    
% Compensate for the shifting introduced by the fir filter
signal = [signal(101:length(signal))' zeros(1,100)]';

% Recreate the generated_chirp used by the sender to determine
% the delay(tau) and scaling(A) of the channel. 
generated_chirp = chirp(t, lower_band+chirp_offset, 3, upper_band-chirp_offset);

% Find delay introduced by the channel
delay = finddelay(generated_chirp, signal);
tau = delay / f_upsampled * 1e6;

res = ['tau: ', num2str(tau)];
if tau > 500
    res = ['ERROR, tau too large: ', num2str(tau)];
end
disp(res);

% Find the amplitude scaling introduced by the channel
max_val = max(xcorr(signal, generated_chirp));
min_val = min(xcorr(signal, generated_chirp));

peak = max_val;
if abs(min_val) > max_val
    peak = min_val;
end

% Determine the amplitude scaling of the channel
a_scaling = peak/(norm(generated_chirp)^2);
A = round(a_scaling, 1);
res = ['A: ', num2str(A)];
if a_scaling == 0
    res = 'Error: A is 0';
end
disp(res);

% Readjust signal according to the delay and remove chirp from signal
signal = [signal(delay+1:length(signal))' zeros(1, delay)]';
signal = signal(2000001:end);

% Readjust signal according to the amplitude scaling
signal = signal/a_scaling;

% I/Q-Demodulate signal
yI = zeros(signal_len, 1);
yQ = zeros(signal_len, 1);

% I/Q-Demodulation, In-phase part
for i = 1:signal_len
   yI(i) = signal(i)*2*cos(2*pi*f_carrier*t(i));
end

% I/Q-Demodulation, Quadrature part
for i = 1:signal_len
    yQ(i) = signal(i)*(-2)*sin(2*pi*f_carrier*t(i));
end

% Lowpass filter the samples
[b, a] = fir1(200, 0.05, "low");
zIsample = filter(b, a, yI);
zQsample = filter(b, a, yQ);

% Compensate for the shifting introduced by the fir filter
zIsample = [zIsample(101:length(zIsample))' zeros(1,100)]';
zQsample = [zQsample(101:length(zQsample))' zeros(1,100)]';

% Downsample back to 20 kHz
zI = downsample(zIsample, 20);
zQ = downsample(zQsample, 20);

end