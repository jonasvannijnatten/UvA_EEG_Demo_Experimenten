function out = isdivby4(x)
% returns logical 1 for true if the input argument is divisible by 4, or
% logical 0 is not divisible by 4
% format of call: isdivby4
% returns to logical 1 or 0
out =~ rem(x,4)
end
