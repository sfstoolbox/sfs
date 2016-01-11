function D = driving_function_mono_wfs_vss(x0,xv,Dv,f,conf)
%DRIVING_FUNCTION_MONO_WFS_VSS returns the driving signal D for a given set of
%virtual secondary sources and their driving signals
%
%   Usage: D = driving_function_mono_wfs_vss(x0,xv,Dv,f,conf)
%
%   Input parameters:
%       x0          - position, direction, and weights of the real secondary
%                     sources / m [nx7]
%       xv          - position, direction, and weights of the virtual secondary
%                     sources / m [mx7]
%       Dv          - driving functions of virtual secondary sources [mx1]
%       f           - frequency of the monochromatic source / Hz
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   References:
%       S. Spors, J.Ahrens (2010) - "Local Sound Field Synthesis by Virtual
%                                    Secondary Sources", 40th AES
%
%   See also: driving_function_mono_wfs, driving_function_mono_wfs_fs

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
nargmin = 5;
nargmax = 5;
narginchk(nargmin,nargmax);
isargvector(Dv);
isargpositivescalar(f);
isargsecondarysource(x0,xv);
isargstruct(conf);


%% ===== Configuration ==================================================
dimension = conf.dimension;


%% ===== Computation ====================================================
% Get driving signals
if strcmp('2.5D',dimension) || strcmp('3D',dimension)
    % === Focussed Point Sink ===
    conf.driving_functions = 'default';
elseif strcmp('2D',dimension)
    % === Focussed Line Sink ===
    % We have to use the driving function setting directly, because in opposite
    % to the case of a non-focused source where 'ps' and 'ls' are available as
    % source types, for a focused source only 'fs' is available.
    % Have a look at driving_function_mono_wfs_fs() for details on the
    % implemented focused source types.
    conf.driving_functions = 'line_sink';
else
    error('%s: %s is not a known source type.',upper(mfilename),dimension);
end

% Adjust weights of secondary sources in order to use the tapering
% correctly. Integration weights for the secondary sources will be applied
% later, when the sound field is computed
x0(:,7) = 1;

% Get driving signals for real secondary sources
%
% See Spors (2010), fig. 2 & eq. (12)
Ns = size(xv,1);
N0 = size(x0,1);

Dmatrix = zeros(N0,Ns);

for idx=1:Ns
  [xtmp, xdx] = secondary_source_selection(x0,xv(idx,1:6),'fs');
  if (~isempty(xtmp))
    xtmp = secondary_source_tapering(xtmp,conf);
    Dmatrix(xdx,idx) = ...
        driving_function_mono_wfs(xtmp,xv(idx,1:3),'fs',f,conf) .* xtmp(:,7);
  end
end

D = Dmatrix*(Dv.*xv(:,7));
