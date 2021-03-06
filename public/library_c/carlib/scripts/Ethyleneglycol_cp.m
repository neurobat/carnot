%Ethyleneglycol_cp

%Quelle: Thermophysikals properties of Brines - M.Code Engineering Zurich 2011
%General Equation for Density, thermal conductivity, specific thermal capacity: 
%Px = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Dynamic Viscosoty, Prandl Number
%LN(Px) = A1 + A2*Z + A3*273.15/T + A4*Z*273.15/T + A5*(273.15/T)^2
%Freezing Temperature Equation:
%T_f/273.15 = A0 + A1*Z + A2*Z^2

%Z[%]=Concetration; T[K]; rho[kg/m^3]; cp[kJ/kg K]; lambda[W/mK]
Water_cp

Tcp_PG = [-50:5:150]+273.15;
T=Tcp_PG';
Z=0;
cp_PG_F0 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;
Z=0.1;
cp_PG_F01 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;
Z=0.2;
cp_PG_F02 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;
Z=0.3;
cp_PG_F03 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;
Z=0.4;
cp_PG_F04 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;
Z=0.5;
cp_PG_F05 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;
Z=0.6;
cp_PG_F06 = 5.36449 + 0.78863*Z + (-2.59001)*273.15./T + (-2.73187)*Z*273.15./T + 1.43759*(273.15./T).^2;

%%CARLIB
xi = 60;     
t=T-273.15;
			c = t.*( 3.610080227640085e-002  + xi*(-2.471590456775278e-003 + xi*( 4.378416414199766e-005 + xi*(-2.206548881875750e-007))) + t.*(-1.058075689319986e-004  + xi*( 8.201126167829168e-006 + xi*(-1.630532655206974e-007 + xi*( 9.195676812116590e-010)))));
			c_06 = 4223.636919944118 + xi*(-11.53171347245531 + xi*(-2.499319374992276e-001 + xi*( 1.703052389430512e-003))) + t.*(-2.369140514594071 + xi*( 1.630272708066081e-001 + xi*( 5.273110167848944e-004 + xi*(-1.563214167040990e-005))) + c);
            c_06= c_06/1000;
xi = 0;     
			c = t.*( 3.610080227640085e-002  + xi*(-2.471590456775278e-003 + xi*( 4.378416414199766e-005 + xi*(-2.206548881875750e-007))) + t.*(-1.058075689319986e-004  + xi*( 8.201126167829168e-006 + xi*(-1.630532655206974e-007 + xi*( 9.195676812116590e-010)))));
			c_00 = 4223.636919944118 + xi*(-11.53171347245531 + xi*(-2.499319374992276e-001 + xi*( 1.703052389430512e-003))) + t.*(-2.369140514594071 + xi*( 1.630272708066081e-001 + xi*( 5.273110167848944e-004 + xi*(-1.563214167040990e-005))) + c);
            c_00= c_00/1000;

% Plot fit with data.
plot(Tcp_PG-273.15,cp_PG_F0,'r')
hold on
%plot(Tcp_PG-273.15,cp_PG_F01,'b')
%plot(Tcp_PG-273.15,cp_PG_F02,'g')
%plot(Tcp_PG-273.15,cp_PG_F03,'--r')
%plot(Tcp_PG-273.15,cp_PG_F04,'--b')
%plot(Tcp_PG-273.15,cp_PG_F05,'--g')
%plot(Tcp_PG-273.15,cp_PG_F06,'k')
plot(Tcp_PG-273.15,c_00,'r-o')
%plot(Tcp_PG-273.15,c_06,'k-o')
plot (T_water,cp_water,'o')
title('Propyleneglycole Source: M. Conde Engineering 2011');
%legend( 'Xi=0','Xi=0.1','Xi=0.2','Xi=0.3','Xi=0.4','Xi=0.5','Xi=0.6','Xi carlib=0','Xi carlib=0.6','Water');
legend( 'Xi=0','Xi carlib=0','Water');
% Label axes
xlabel( 'T [�C]' );
ylabel( 'cp [kJ/kg K]' );
grid on
