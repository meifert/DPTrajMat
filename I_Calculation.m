function [sys,x0,str,ts]=I_Calculation(t,x,u,flag)
%
% I_Calculation berechnet aus der Kondensatorspannung den Strom im 
% nicht-linearen Widerstand R1 und ersetzt R=a+b*tanh(c*(I+d))
% Version 1.0 Stephan Buller 03.05.2002

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0         
    [sys,x0,str,ts] = mdlInitializeSizes;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Update, Derivatives and Terminate %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case {1, 2, 4, 9}
    sys = []; % do nothing

  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3
    sys = mdlOutputs(t,x,u); 

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

% end I_Calculation

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(lb,ub,xi)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1; 
sizes.NumInputs      = 5;
sizes.DirFeedthrough = 1;  % has direct feedthrough
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = [];
ts  = [-1 0];   % inherited sample time

% end mdlInitializeSizes

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)

Uc = u(1);
a = u(2);
b = u(3);
c = u(4);
d = u(5);

if ((-b-d*c)/c >=0)
    if (Uc <=(-b+a)*(-b-c*d)/c)
        sys = Uc/(a-b);
    elseif (Uc >(-b+a)*(-b-c*d)/c) & (Uc <=(-b+a)*(b-d*c)/c+2*b*b/c)
        p = -2*(-b-d*c)/c+2*(a-b)/c;
        q = ((-b-c*d)/c)*((-b-c*d)/c)-2*Uc/c;
        sys = -p/2+sqrt((p/2)*(p/2)-q);
    elseif (Uc >(-b+a)*(b-d*c)/c+2*b*b/c)
        sys = (Uc-2*b*d)/(a+b);
    end
elseif ((-b-c*d)/c <0) & ((b-c*d)/c >=0)
    if (Uc <= -0.5*((-b-c*d)/c)*(-b-c*d)+((-b-c*d)/c)*(a-b))
        sys = (Uc+0.5*((-b-c*d)/c)*(-b-c*d))/(a-b);
    elseif (Uc > -0.5*((-b-c*d)/c)*(-b-c*d)+((-b-c*d)/c)*(a-b)) & (Uc <= ((b-c*d)/c)*(a+b)-0.5*((b-c*d)/c)*(b-c*d))
        p = 2*(a+c*d)/c;
        q = -2*Uc/c;
        sys = -p/2+sqrt((p/2)*(p/2)-q);
    elseif (Uc > ((b-c*d)/c)*(a+b)-0.5*((b-c*d)/c)*(b-c*d))
        sys = (Uc+0.5*((-b-c*d)/c)*(-b-c*d))/(a+b);
    end    
elseif ((b-c*d)/c <0)
    if (Uc >= ((b-c*d)/c)*(a+b))
        sys = Uc/(a+b);
    elseif (Uc < ((b-c*d)/c)*(a+b)) & (Uc >=(a+b)*(-b-c*d)/c+2*b*b/c)
        p = 2*(a+c*d)/c;
        q = ((b-c*d)/c)*((b-c*d)/c)-2*Uc/c;
        sys = -p/2+sqrt((p/2)*(p/2)-q);
    elseif (Uc < (a+b)*(-b-c*d)/c+2*b*b/c)
        sys = (Uc-(a+b)*(-b-c*d)/c-2*b*b/c)/(a-b)+(-b-c*d)/c;     
    end    
end
% end mdlOutputs

