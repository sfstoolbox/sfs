function varargout = sound_field_imp_localwfs(X,Y,Z,xs,src,t,conf)
%SOUND_FIELD_IMP_LOCALWFS returns the sound field in time domain of an impulse
%
%   Usage: [p,x,y,z,x0] = sound_field_imp_localwfs(X,Y,Z,xs,src,t,conf)
%
%   Input options:
%       X           - x-axis / m; single value or [xmin,xmax] or nD-array
%       Y           - y-axis / m; single value or [ymin,ymax] or nD-array
%       Z           - z-axis / m; single value or [zmin,zmax] or nD-array
%       xs          - position of point source / m
%       src         - source type of the virtual source
%                         'pw' - plane wave (xs, ys are the direction of the
%                                plane wave in this case)
%                         'ps' - point source
%       t           - time point t of the sound field / samples
%       conf        - configuration struct (see SFS_config)
%
%   Output options:
%       p           - simulated sound field
%       x           - corresponding x values / m
%       y           - corresponding y values / m
%       z           - corresponding z values / m
%       x0          - secondary sources / m
%
%   SOUND_FIELD_IMP_LOCALWFS(X,Y,Z,xs,src,t,conf) simulates a sound field of the
%   given source type (src) synthesized with local wave field synthesis at the
%   time t.
%
%   To plot the result use:
%   plot_sound_field(p,X,Y,Z,x0,conf);
%   or simple call the function without output argument:
%   sound_field_imp_localwfs(X,Y,Z,xs,src,t,conf)
%   For plotting you may also consider to display the result in dB, by setting
%   the following configuration option before:
%   conf.plot.usedB = true;
%
%   See also: driving_function_imp_localwfs, sound_field_mono_localwfs

%*****************************************************************************
% Copyright (c) 2010-2016 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2016 Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://github.com/sfstoolbox/sfs                      sfstoolbox@gmail.com *
%*****************************************************************************

%% ===== Checking of input  parameters ==================================
nargmin = 7;
nargmax = 7;
narginchk(nargmin,nargmax);
isargnumeric(X,Y,Z);
isargxs(xs);
isargchar(src);
isargscalar(t);
isargstruct(conf);


%% ===== Configuration ==================================================
if strcmp('2D',conf.dimension)
    greens_function = 'ls';
else
    greens_function = 'ps';
end
useplot = conf.plot.useplot;


%% ===== Computation =====================================================
% Get secondary sources
x0 = secondary_source_positions(conf);
% Get driving signals
[d, x0, xv] = driving_function_imp_localwfs(x0,xs,src,conf);
% Fix the time to account for sample offset of the pre-equalization filter
switch (conf.wfs.usehpre + conf.localsfs.wfs.usehpre)
  case 1
    t = t + 64;
  case 2
    t = t + 127;
end
% Calculate sound field
[varargout{1:min(nargout,4)}] = ...
    sound_field_imp(X,Y,Z,x0,greens_function,d,t,conf);
% Return secondary sources if desired
if nargout==5, varargout{5}=x0; end


% === Plotting ===
if nargout==0 || useplot
  hold on
    dimensions = xyz_axes_selection(X,Y,Z);
    draw_loudspeakers(xv, dimensions, conf);
  hold off
end
