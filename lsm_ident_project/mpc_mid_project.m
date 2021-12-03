clc; close all; clear
%% identifikace amplitudy pro vstupni signal PRBS
% identification of the amplitude for the PRBS input signal
id = 111111; % use own id

T = 3000; 
Ts = 0.01; 
t = 0:Ts:T-1;
k = 0.001;
u = k*t;

y = odezva_2021(id, u, t);
t = t/1000;
figure
plot(t,y)

% amplituda podle grafu - amplitude according to graph
a = 0.8;
%% setup
Ts = 2; 
T = 3000;
t = 0:Ts:T-1;
u = idinput(length(t),'prbs',[0 0.04],[-a a]);
y = odezva_2021(id, u, t');

%% Metoda nejmensich ctvercu - zpozdene pozorovani
% Least-Square method - delayed observation
d = 2; % zpozdeni - delay
ord = 3;
param = d + ord + 1;
k = param:length(u);
PHI = [-y(k-1), -y(k-2) -y(k-3), u(k-1), u(k-2) u(k-3)];     % vektor pozorovani
DZ = [-y(k-1-d), -y(k-2-d) -y(k-3-d), u(k-1), u(k-2) u(k-3)];     % vektor zpozdenych pozorovani
Y = y(k);
[Y,PHI,DZ] = skrkani(Y,PHI,DZ,3);

TH = (DZ'*PHI)\(DZ'*Y)

first_row = ord+1;
y3 = zeros(size(u));
y3(2) = TH(4)*u(1) - TH(1)*y3(1);
y3(3) = TH(4)*u(2) + TH(5)*u(2) - TH(1)*y3(2) - TH(2)*y3(2);
for k = first_row:length(u)
    y3(k) = TH(4)*u(k-1) + TH(5)*u(k-2) + TH(6)*u(k-3) - TH(1)*y3(k-1) - TH(2)*y3(k-2) - TH(3)*y3(k-3);
end

figure
hold on
plot(t,y,'b',t,y3,'r')