function h_c = heat_transfer_clothing(v_ar, t_cl, t_a)
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% static double calculate_h_c(double v_ar, double t_cl, double t_a)
% /* calculation of the heat transfer coefficient - equation (3) of DIN EN ISO 7730:2005 */

h_c_1 = 2.38*sqrt(sqrt(abs(t_cl-t_a)));
h_c_2 = 12.1*sqrt(v_ar);
	
if (h_c_1 > h_c_2)
	h_c = h_c_1;
else
	h_c = h_c_2;
end
