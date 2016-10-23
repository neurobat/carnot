% m         /* metabolic rate [W/m²]; 1 met = 58.2 W/m² */
m = 1.0*58.2;

% w         /* effective mechanical power [W/m²] */
w = 0;

% I_CL      /* clothing isolation [m²*K/kW]; 1 clo = 0.155 K*m²/W */
i_cl = 1*0.155;

% #define T_A         (*u3[0])    /* air temperature [°C] */
% t_a = [23 23 26];
% t_a = [24 24 24];
t_a = 1:40


% #define T_R         (*u4[0])    /* mean radiant temperature [°C] */
t_r = t_a;

% #define V_AR        (*u5[0])    /* relative air velocity [m/s] */
v_air = 0.1;

figure
hold on
for n = 0:10
    i_cl = 0.155/10*n + 0.155/2; 
    % #define P_A         (*u6[0])    /* partial pressure of water [Pa] */
    % p_a = 1737;
    p_a = vapourpressure(t_a,2,rel_hum2x(t_a,1e5,60));

    pmv = calculate_pmv(m, w, i_cl, v_air, p_a, t_a, t_r)

    ppd = calculate_ppd(pmv)
    mean(ppd)
    plot(t_a,ppd)
end
hold off