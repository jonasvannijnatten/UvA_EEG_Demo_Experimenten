function out = pickone(x)
%creates a vector and returns with one random element from the vector
%format of call:pickone(x)
%returns single random element of vector
len = length(x);
if iscell(x)
    out= x {randi([1, len])};
else
    out= x (randi([1, len]));
end
end

