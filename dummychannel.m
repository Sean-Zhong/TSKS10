function y = dummychannel(x,A,n,k)
%DUMMYCHANNEL is a dummy channel för TSKS10 labs
%   DUMMYCHANNEL(x) returns the signal x unchanged
%   DUMMYCHANNEL(x,A) returns the signal x, scaled by A
%   DUMMYCHANNEL(x,A,n) returns the signal x, scaled by A and delayed by n
%   samples.
%   DUMMYCHANNEL(x) returns the signal x, scaled by A, delayed by n samples
%   and with an additional k trailing zero.

if nargin<4
    k = 0;
end
if nargin<3
    n = 0;
end
if nargin<2
    A = 1;
end

y = A*[zeros(n,1);x;zeros(k,1)];