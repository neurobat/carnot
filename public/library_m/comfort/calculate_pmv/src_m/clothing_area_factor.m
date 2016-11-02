function f_cl = clothing_area_factor(i_cl)
% $Revision$
% $Author$
% $Date$
% $HeadURL$
% /* calculation of the clothing area factor - equation (4) of DIN EN ISO 7730:2005 */
%  original name: calculate_f_cl
if (i_cl<=0.078)
	f_cl = 1.00+1.290*i_cl;
else
	f_cl = 1.05+0.645*i_cl;
end