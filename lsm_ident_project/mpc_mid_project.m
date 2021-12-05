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
title('Urceni amplitudy PRBS')

% amplituda podle grafu - amplitude accordping to graph
a = 0.8;
%% setup
% vytvoreni dat pro modelovani a testovani - creating data for modelling
% and testing
Ts = 2; % cca 10 % nabehove hrany
T_mod = 3000;
t_mod = 0:Ts:T_mod-1;
u_mod = idinput(length(t_mod),'prbs',[0 0.05],[-a a]);

T_zeros = 500;
t_zeros = T_mod:Ts:T_mod+T_zeros-1;
u_zeros = zeros(length(t_zeros),1);

T_test = 1000;
t_test = T_mod+T_zeros:Ts:T_mod+T_zeros+T_test-1;
u_test = ones(length(t_test),1)*a;

u = [u_mod; u_zeros; u_test]; 
t = [t_mod'; t_zeros'; t_test'];
y = odezva_2021(id, u, t);

t_mod = t(1:T_mod/Ts);
t_test = t((T_mod+T_zeros)/Ts+1:end);

y_mod = y(1:T_mod/Ts);
y_test = y((T_mod+T_zeros)/Ts+1:end);

%% Metoda nejmensich ctvercu - zpozdene pozorovani
% Least-Square method - delayed observation

d = 2; % zpozdeni - delay
ord_zp = 2;
param_zp = d + ord_zp + 1;
k_zp = param_zp:length(u_mod);

PHI = [-y_mod(k_zp-1), -y_mod(k_zp-2), u_mod(k_zp-1), u_mod(k_zp-2)];     % vektor pozorovani
DZ = [-y_mod(k_zp-1-d), -y_mod(k_zp-2-d), u_mod(k_zp-1), u_mod(k_zp-2)];     % vektor zpozdenych pozorovani
Y = y_mod(k_zp);
[Y,PHI,DZ] = skrkani_mnc_zp(Y,PHI,DZ,3);

TH = (DZ'*PHI)\(DZ'*Y)

first_row_zp = ord_zp+1;
y3 = zeros(size(u_mod));
y3(2) = TH(3)*u_mod(1) - TH(1)*y3(1);
for k = first_row_zp:length(u_mod)
    y3(k) = TH(3)*u_mod(k-1) + TH(4)*u_mod(k-2) - TH(1)*y3(k-1) - TH(2)*y3(k-2);
end

%% Metoda nejmensich ctvercu s dodatecnym modelem
% Least-Square method with the additional model

ord_dm = 2;
param_dm = ord_dm + 1;
k_dm = param_dm:length(u_mod);

% Dodatecny model pomoci klasicke MNC
PHIivm = [-y_mod(k_dm-1) -y_mod(k_dm-2), u_mod(k_dm-1) u_mod(k_dm-2)];
Yivm = y_mod(k_dm);
[Yivm, PHIivm] = skrkani_mnc(Yivm,PHIivm,param_dm);
THivm = PHIivm \ Yivm

yivm = zeros(size(u_mod));
first_row_dm = ord_dm+1;
yivm(2) = THivm(3)*u_mod(1) - THivm(1)*yivm(1);
for k=first_row_dm:length(u_mod)
    yivm(k) = THivm(3)*u_mod(k-1) + THivm(4)*u_mod(k-2) - THivm(1)*yivm(k-1) - THivm(2)*yivm(k-2);
end

% Vlastni metoda pomocnych promennych s dodatecnym modelem
PHI2 = [-y_mod(k_dm-1) -y_mod(k_dm-2), u_mod(k_dm-1) u_mod(k_dm-2)];      % vektor pozorovani
DZ2 = [-yivm(k_dm-1) -yivm(k_dm-2), u_mod(k_dm-1) u_mod(k_dm-2)];
Y2 = y_mod(k_dm);
[Y2,PHI2,DZ2] = skrkani_mnc_zp(Y2,PHI2,DZ2,param_dm);
TH2 = (DZ2'*PHI2)\(DZ2'*Y2)

y4 = zeros(size(u_mod));
y4(2) = TH2(3)*u_mod(1) - TH2(1)*y4(1);
for k = first_row_dm:length(u_mod)
    y4(k) = TH2(3)*u_mod(k-1) + TH2(4)*u_mod(k-2) - TH2(1)*y4(k-1) - TH2(2)*y4(k-2);
end

%% Vykresleni graphu srovnani metod se ziskanou vystupni hodnotou
% 
figure
subplot(2,1,1);
plot(t_mod,y_mod,'b',t_mod,y3,'r')
legend('Puvodni','Odhad','Location','NorthEast')
title('MNC se zpozdenym pozorovanim')

subplot(2,1,2); 
plot(t_mod,y_mod,'b',t_mod,y4,'r')
legend('Puvodni','Odhad','Location','NorthEast')
title('MNC s dodatecnym modelem')

%% Testovani modelu na skokovou zmenu

y5 = zeros(size(u_test));
y5(2) = TH(4)*u_test(1) - TH(1)*y5(1);
for k = first_row_zp:length(u_test)
    y5(k) = TH(3)*u_test(k-1) + TH(4)*u_test(k-2) - TH(1)*y5(k-1) - TH(2)*y5(k-2);
end

y6 = zeros(size(u_test));
y6(2) = TH2(3)*u_test(1) - TH2(1)*y6(1);
for k = first_row_dm:length(u_test)
    y6(k) = TH2(3)*u_test(k-1) + TH2(4)*u_test(k-2) - TH2(1)*y6(k-1) - TH2(2)*y6(k-2);
end

figure
subplot(2,1,1);
plot(t_test,y_test,'b',t_test,y5,'r')
legend('Odezva systemu','Odezva modelu','Location','NorthEast')
title('MNC se zpozdenym pozorovanim')

subplot(2,1,2); 
plot(t_test,y_test,'b',t_test,y6,'r')
legend('Odezva systemu','Odezva modelu','Location','NorthEast')
title('MNC s dodatecnym modelem')