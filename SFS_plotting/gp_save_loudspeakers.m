function gp_save_loudspeakers(file,x0)
% GP_SAVE_LOUDSPEAKERS save x0 as a text file in a Gnuplot compatible format
%
%   Usage: gp_save_loudspeakers(file,x0)
%
%   Input parameters:
%       file        - filename of the data file
%       x0          - secondary sources [nx7]
%
%   GP_SAVE_LOUDSPEAKERS(file,x0) saves x0(:,1:2) as positions of the
%   loudspeakers, an orientation value calculated from x0(:,4:6), and the
%   activity x0(:,7) of the loudspeakers in a text file useable by gnuplot.
%
%   See also: gp_save, gp_save_matrix

%*****************************************************************************
% The MIT License (MIT)                                                      *
%                                                                            *
% Copyright (c) 2010-2016 SFS Toolbox Team                                   *
%                                                                            *
% Permission is hereby granted,  free of charge,  to any person  obtaining a *
% copy of this software and associated documentation files (the "Software"), *
% to deal in the Software without  restriction, including without limitation *
% the rights  to use, copy, modify, merge,  publish, distribute, sublicense, *
% and/or  sell copies of  the Software,  and to permit  persons to whom  the *
% Software is furnished to do so, subject to the following conditions:       *
%                                                                            *
% The above copyright notice and this permission notice shall be included in *
% all copies or substantial portions of the Software.                        *
%                                                                            *
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR *
% IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF MERCHANTABILITY, *
% FITNESS  FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT. IN NO EVENT SHALL *
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
% LIABILITY, WHETHER  IN AN  ACTION OF CONTRACT, TORT  OR OTHERWISE, ARISING *
% FROM,  OUT OF  OR IN  CONNECTION  WITH THE  SOFTWARE OR  THE USE  OR OTHER *
% DEALINGS IN THE SOFTWARE.                                                  *
%                                                                            *
% The SFS Toolbox  allows to simulate and  investigate sound field synthesis *
% methods like wave field synthesis or higher order ambisonics.              *
%                                                                            *
% http://sfstoolbox.org                                 sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input  parameters ==================================
nargmin = 2;
nargmax = 2;
narginchk(nargmin,nargmax);
isargchar(file);
isargsecondarysource(x0);


%% ===== Main ============================================================
% Write header to the file
fid = fopen(file,'w');
fprintf(fid,'# Loudspeaker file generated by gp_save_loudspeakers.m\n');
fprintf(fid,'# x0 y0 phi ls_activity\n');
fclose(fid);

% Calculate phi
loudspeaker(:,1:2) = x0(:,1:2);
[loudspeaker(:,3),~,~] = cart2sph(x0(:,4),x0(:,5),x0(:,6));
loudspeaker(:,4) = x0(:,7);


% Append the data to the file using tabulator as a delimiter between the data
if isoctave
    dlmwrite(file,loudspeaker,'\t','-append');
else
    dlmwrite(file,loudspeaker,'delimiter','\t','-append');
end
