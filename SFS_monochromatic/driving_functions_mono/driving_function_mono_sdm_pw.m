function D = driving_function_mono_sdm_pw(x0,nk,f,conf)
%DRIVING_FUNCTION_MONO_SDM_PW returns the driving signal D for a plane wave in
%SDM
%
%   Usage: D = driving_function_mono_sdm_pw(x0,nk,f,conf)
%
%   Input parameters:
%       x0          - position of the secondary sources / m [nx3]
%       nk          - direction of plane wave / m [nx3]
%       f           - frequency of the monochromatic source / Hz
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   DRIVING_FUNCTION_MONO_SDM_PW(x0,nk,f,conf) returns SDM driving signals
%   for the given secondary sources, the virtual plane wave direction and the
%   frequency f.
%
%   References:
%       H. Wierstorf, J. Ahrens, F. Winter, F. Schultz, S. Spors (2015) -
%       "Theory of Sound Field Synthesis"
%       J. Ahrens and S. Spors (2010) - "Sound Field Reproduction Using Planar
%       and Linear Arrays of Loudspeakers", Transactions on Audio, Speech and
%       Language Processing, Volume 18(8), p. 2038-2050
%
%   See also: driving_function_mono_wfs, driving_function_imp_wfs_ps

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
nargmin = 4;
nargmax = 4;
narginchk(nargmin,nargmax);
isargmatrix(x0,nk);
isargpositivescalar(f);
isargstruct(conf);


%% ===== Configuration ==================================================
xref = conf.xref;
c = conf.c;
dimension = conf.dimension;
driving_functions = conf.driving_functions;


%% ===== Computation ====================================================
% Calculate the driving function in time-frequency domain

% Frequency
omega = 2*pi*f;


if strcmp('2D',dimension)

    % === 2-Dimensional ==================================================

    % Ensure 2D
    x0 = x0(:,1:2);
    nk = nk(:,1:2);
    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        to_be_implemented;
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2D plane wave.'],upper(mfilename),driving_functions);
    end


elseif strcmp('2.5D',dimension)

    % === 2.5-Dimensional ================================================

    % Reference point
    xref = repmat(xref,[size(x0,1) 1]);
    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % D_2.5D using a plane wave as source model
        %
        %                   e^(-i w/c nky*xrefy)
        % D_2.5D(x0,w) = 4i ---------------------- e^(-i w/c nk x0)
        %                     (2) /w          \
        %                    H0  | - nky*xrefy |
        %                         \c          /
        %
        % see Wierstorf et al. (2015), eq.(#D:sdm:pw:2.5D) and
        % Ahrens and Spors (2010), eq.(17)
        %
        D = 4*1i.*exp(-1i*omega/c.*nk(:,2).*xref(:,2)) ./ ...
            besselh(0,2,omega/c.*nk(:,2).*xref(:,2)) .* ...
            exp(-1i*omega/c.*vector_product(nk,x0,2));
        %
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2.5D plane wave.'],upper(mfilename),driving_functions);
    end


elseif strcmp('3D',dimension)

    % === 3-Dimensional ==================================================

    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        to_be_implemented;
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 3D plane wave.'],upper(mfilename),driving_functions);
    end

else
    error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end
