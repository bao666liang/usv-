function [sys,x0,str,ts] = ship_plant(t,x,u,flag)

switch flag,

  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;

  case 1,
    sys=mdlDerivatives(t,x,u);

  case 2,
    sys=mdlUpdate(t,x,u);

  case 3,
    sys=mdlOutputs(t,x,u);

  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  case 9,
    sys=mdlTerminate(t,x,u);

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 6;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 12;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

str = [];

ts  = [0 0];
x0=[0 0 0 -50 20 0];%u v r x y psi_d

function sys=mdlDerivatives(t,x,u)

m11=1.2*10^5;m22=1.779*10^5;m33=6.36*10^7;
d11=2.15*10^4;d22=1.47*10^5;d33=8.02*10^6;
du2=0.2*d11;dv2=0.2*d22;dr2=0.2*d33;
du3=0.1*d11;dv3=0.1*d22;dr3=0.2*d33;
% twu=1*10^4*(sin(0.2*t)+cos(0.2*t+pi/4)+sin(0.2*t+pi/6));
% twv=5*10^3*(sin(0.2*t)+cos(0.2*t+pi/4)+sin(0.2*t+pi/6));
% twr=1*10^4*(sin(0.2*t)+cos(0.2*t+pi/4)+sin(0.2*t+pi/6));
twu=1*10^5*(sin(0.2*t)+cos(0.5*t));
twv=1*10^2*(sin(0.1*t)+cos(0.4*t));
twr=1*10^6*(sin(0.5*t)+cos(0.3*t));

tau_1=u(1);
tau_3=u(2);
ut=x(1);v=x(2);r=x(3);
psi=x(6);

deta_fu=du2*abs(ut)*ut+du3*(abs(ut))^2*ut;
deta_fv=dv2*abs(v)*v+dv3*(abs(v))^2*v;
deta_fr=dr2*abs(r)*r+dr3*(abs(r))^2*r;

fu=m22*v*r-d11*ut-deta_fu;
fv=-m11*ut*r-d22*v-deta_fv;
fr=(m11-m22)*ut*v-d33*r-deta_fr;


sys(1)=fu/m11+(tau_1+twu)/m11;
sys(2)=fv/m22+twv/m22;
sys(3)=fr/m33+(tau_3+twr)/m33;
sys(4)=ut*cos(psi)-v*sin(psi);
sys(5)=ut*sin(psi)+v*cos(psi);
sys(6)=r;

function sys=mdlUpdate(t,x,u)

sys = [];

function sys=mdlOutputs(t,x,u)
m11=1.2*10^5;m22=1.779*10^5;m33=6.36*10^7;
d11=2.15*10^4;d22=1.47*10^5;d33=8.02*10^6;
du2=0.2*d11;dv2=0.2*d22;dr2=0.2*d33;
du3=0.1*d11;dv3=0.1*d22;dr3=0.2*d33;

twu=1*10^5*(sin(0.2*t)+cos(0.5*t));
twv=1*10^2*(sin(0.1*t)+cos(0.4*t));
twr=1*10^6*(sin(0.5*t)+cos(0.3*t));

ut=x(1);v=x(2);r=x(3);
psi=x(6);

deta_fu=du2*abs(ut)*ut+du3*(abs(ut))^2*ut;
deta_fv=dv2*abs(v)*v+dv3*(abs(v))^2*v;
deta_fr=dr2*abs(r)*r+dr3*(abs(r))^2*r;

fu=m22*v*r-d11*ut-deta_fu;
fv=-m11*ut*r-d22*v-deta_fv;
fr=(m11-m22)*ut*v-d33*r-deta_fr;

dv=fv/m22+twv/m22;

sys(1)=x(1);
sys(2)=x(2);
sys(3)=x(3);
sys(4)=x(4);
sys(5)=x(5);
sys(6)=x(6);
sys(7)=twu;
sys(8)=twr;
sys(9)=deta_fu;%真实的不确定项 用于画图
sys(10)=deta_fv;
sys(11)=deta_fr;
sys(12)=dv;

function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;   
sys = t + sampleTime;

function sys=mdlTerminate(t,x,u)

sys = [];


