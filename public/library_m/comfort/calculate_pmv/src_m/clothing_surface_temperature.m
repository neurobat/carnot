function result = clothing_surface_temperature(m, w, i_cl, v_ar, t_a, t_r, t_cl)
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% /* target function
%  * surface temperature of the clothing - equation (2) of DIN EN ISO 7730:2005
%  * minus t_cl in order to get a value of zero
%  origonal name: calculate_t_cl_tf

f_cl = clothing_area_factor(i_cl);
h_c = heat_transfer_clothing(v_ar, t_cl, t_a);
aux1 = 3.96e-8 * f_cl * ((t_cl+273.0).^4 - (t_r+273.0).^4);
aux2 = f_cl * h_c * (t_cl-t_a);
% result = 35.7 - 0.028*(m-w) - i_cl*(aux1 + aux2) - t_cl;
% use square of original equation for fminsearch
result = (35.7 - 0.028*(m-w) - i_cl*(aux1 + aux2) - t_cl).^2;