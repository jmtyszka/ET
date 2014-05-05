function string=stringfromnumber(i,ndigits)

if nargin<2
    ndigits=4;
end

tmpstring=num2str(i);
string=[repmat('0',1,ndigits-length(tmpstring)),tmpstring];
    