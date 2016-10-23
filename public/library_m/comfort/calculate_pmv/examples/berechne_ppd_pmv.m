
met = 58.2;  % metabolic rate [W/m�]; 1 met = 58.2 W/m� */
work = 0;           % effective mechanical power [W/m�] */
clo = 0.155; % clothing isolation [m�/kW]; 1 clo = 0.155 W/m� */
t_air = 5:35;       % air temperature [�C] */
t_rad = t_air;      % mean radiation temperature [�C] */
v_air = 0.1;        % air velocity [m/s] */
relhum = 60;        % relative humidity in %

meta = 1.0*met;
i_cl = clo*(0.5:0.1:1.5);

% partial pressure of water [Pa] */
p_h2o = vapourpressure(t_air,2,rel_hum2x(t_air,1.013e5,relhum)); 

pmv = zeros(length(t_air),length(i_cl));
ppd = pmv;

for n = 1:length(i_cl)
    pmv(:,n) = calculate_pmv(meta, work, i_cl(n), v_air, p_h2o, t_air, t_rad);
    ppd(:,n) = calculate_ppd(pmv(:,n));
end

figure(1)
plot(t_air,pmv)
figure(2)
plot(t_air,ppd)