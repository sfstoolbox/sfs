function [x0,idx] = secondary_source_selection(x0,xs,src)
%SECONDARY_SOURCE_SELECTION selects which secondary sources are active
%
%   Usage: [x0,idx] = secondary_source_selection(x0,xs,src)
%
%   Input options:
%       x0          - secondary source positions, directions and weights / m [nx7]
%       xs          - position and for focused sources also direction of the
%                     desired source model / m [1x3] or [1x6] or [mx6]
%       src         - source type of the virtual source
%                       'pw'  - plane wave (xs is the direction of the
%                               plane wave in this case)
%                       'ps'  - point source
%                       'ls'  - line source
%                       'fs'  - focused source
%                       'vss' - distribution of focused sources for local WFS
%
%   Output options:
%       x0          - secondary sources / m, containing only the active
%                     ones [mx7]
%       idx         - index of the selected sources from the original x0
%                     matrix [mx1]
%
%   SECONDARY_SOURCE_SELECTION(x0,xs,src) returns only the active secondary
%   sources for the given geometry and virtual source. In addition the index of
%   the chosen secondary sources is returned.
%
%   References:
%       H. Wierstorf, J. Ahrens, F. Winter, F. Schultz, S. Spors (2015) -
%       "Theory of Sound Field Synthesis"
%
%   See also: secondary_source_positions, secondary_source_tapering

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
nargmin = 3;
nargmax = 3;
narginchk(nargmin,nargmax);
isargsecondarysource(x0);
isargchar(src);

if strcmp('vss', src) && size(xs,2)~=6
    error(['%s: you have chosen "vss" as source type, then xs has ', ...
           'to be [nx6] including the direction of each virtual secondary', ...
           'source.'], upper(mfilename));
    isargmatrix(xs);
elseif ~strcmp('vss', src)
    isargxs(xs);
end
if strcmp('fs',src) && size(xs,2)~=6
    error(['%s: you have chosen "fs" as source type, then xs has ', ...
           'to be [1x6] including the direction of the focused source.'], ...
        upper(mfilename));
elseif ~strcmp('fs',src) && ~strcmp('vss',src) && ~strcmp('ls',src) && size(xs,2)~=3
    error(['%s: for all source types beside "fs", "ls" and "vss", ', ...
           'the size of xs has to be [1x3].'],upper(mfilename));
end


%% ===== Calculation ====================================================
% Position and direction of secondary sources
x0_tmp = x0;
nx0 = x0(:,4:6);
x0 = x0(:,1:3);

if strcmp('pw',src)
    % === Plane wave ===
    % direction of the plane wave
    nk = xs;  % the length of the vector is not relavant for the selection
    % Secondary source selection
    %
    %      / 1, if nk nx0 > 0
    % a = <
    %      \ 0, else
    %
    % see Wierstorf et al. (2015), eq.(#wfs:pw:selection)
    %
    % Direction of plane wave (nk) is set above
    idx = nx0*nk(:) >= eps;

elseif strcmp('ps',src)
    % === Point source ===
    % Secondary source selection
    %
    %      / 1, if (x0-xs) nx0 > 0
    % a = <
    %      \ 0, else
    %
    % see Wierstorf et al. (2015), eq.(#wfs:ps:selection) and
    % eq.(#wfs:ls:selection)
    %
    idx = sum(nx0.*x0,2) - nx0*xs(1:3).' >= -2*eps;

elseif strcmp('ls',src)
    % === Line source ===
    % Secondary source selection
    %
    %      / 1, if v nx0 > 0
    % a = <
    %      \ 0, else
    %
    % where v = x0-xs - <x0-xs,nxs > nxs,
    % and |nxs| = 1.
    %
    % see Wierstorf et al. (2015), eq.(#wfs:ps:selection) and
    % eq.(#wfs:ls:selection)
    %
    %NOTE: We don't check if we are in a 2D or 3D scenario and use xs(4:6)
    % whenever it is present. This can only provide problems if you use the
    % 2D or 2.5D case together with x0(:,6) ~= 0.
    % If you want to avoid this from happening, you have to add conf as a
    % parameter to this function and use the following code instead of the
    % if-esle-statement:
    %[xs,nxs] = get_position_and_orientation_ls(xs,conf);
    if size(xs,2)~=6
        nxs = [0 0 1];
    else
        nxs = xs(4:6) / norm(xs(4:6),2);
    end
    v = (x0 - repmat(xs(1:3),[size(x0,1),1]))*(eye(3) - nxs'*nxs);
    idx = (vector_product(v,nx0,2) >= -2*eps);

elseif strcmp('fs',src)
    % === Focused source ===
    % Secondary source selection
    % NOTE: (xs-x0) nx0 > 0 is always true for a focused source
    %
    %      / 1, nxs (xs-x0) > 0
    % a = <
    %      \ 0, else
    %
    % see Wierstorf et al. (2015), eq.(#wfs:fs:selection)
    %
    nxs = xs(4:6);  % vector for orientation of focused source
    xs = xs(1:3);  % vector for position of focused source
    idx = xs*nxs(:) - x0*nxs(:) >= eps;

elseif strcmp('vss', src)
    % === Virtual secondary sources ===
    % Multiple focussed source selection
    idx = false(size(x0_tmp,1),1);
    for xi=xs'
        % ~idx tests only the x0, which have not been selected before
        idx(~idx) = xi(1:3).'*xi(4:6) - x0(~idx,:)*xi(4:6) >= eps;
    end
else
    error('%s: %s is not a supported source type!',upper(mfilename),src);
end

x0 = x0_tmp(idx,:);

if size(x0,1)==0
    warning('%s: 0 secondary sources were selected.',upper(mfilename));
end
