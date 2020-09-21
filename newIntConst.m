function res = newIntConst
%{
Used to initialize and update global vars
%}
global x
if isempty(x) == true
    initIntConst();
end
x = updateIntConst(x);
res = sym("C" + string(x));
end