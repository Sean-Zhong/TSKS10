%Main is the mainprogram for TSKS10 lab
%   Main samples input audio files
%   Then audio files are sent into sender
%   From sender into channel and from channel
%   into reciever.
%   Finally some control calculations are performed

% Read audio files
[xI,fs] = audioread('xI.wav');
[xQ,fs] = audioread('xQ.wav');

% Input audio files into sender
x = sender(xI,xQ);

% Input output from sender into provided communication channel
y = TSKS10channel(x);

% Input output from channel into reciever
[zI,zQ,A,tau] = receiver(y);

% Plot zI and xI, should resemble a straight line
plot(zI, xI)

% Given control equations, should result in values greater than 25 db.
SNRzI = 20*log10(norm(xI)/norm(zI-xI))
SNRzQ = 20*log10(norm(xQ)/norm(zQ-xQ))