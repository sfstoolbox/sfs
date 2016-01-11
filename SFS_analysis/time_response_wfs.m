function varargout = time_response_wfs(X,xs,src,conf)
%TIME_RESPONSE_WFS simulates the time response for WFS at the given
%listener position
%
%   Usage: [s,t] = time_response_wfs(X,xs,src,conf)
%
%   Input parameters:
%       X           - listener position / m
%       xs          - position of virtual source / m
%       src         - source type of the virtual source
%                         'pw' -plane wave
%                         'ps' - point source
%                         'fs' - focused source
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       s           - simulated time response
%       t           - corresponding time axis / s
%
%   TIME_RESPONSE_WFS(X,xs,src,conf) simulates the time response of the
%   sound field at the given position X. The sound field is simulated for the
%   given source type (src) using the sound_field_imp_wfs function.
%
%   See also: sound_field_imp_wfs, freq_response_wfs, time_response_nfchoa

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
isargposition(X);
isargxs(xs);
isargchar(src);
isargstruct(conf);


%% ===== Configuration ==================================================
% Plotting result
useplot = conf.plot.useplot;
fs = conf.fs;
showprogress = conf.showprogress;
% Disable progress bar for the sound field function
conf.showprogress = 0;
% Disable plotting, otherwise the sound_field_imp fails
conf.plot.useplot = 0;
% Select secondary source type
if strcmp('2D',conf.dimension)
    greens_function = 'ls';
else
    greens_function = 'ps';
end


%% ===== Computation ====================================================
% Get the position of the loudspeakers
x0 = secondary_source_positions(conf);
x0 = secondary_source_selection(x0,xs,src);
x0 = secondary_source_tapering(x0,conf);
% Generate time axis (0-500 samples)
t = (0:500)';
s = zeros(1,length(t));
d = driving_function_imp_wfs(x0,xs,src,conf);
% If desired a cosine shaped pulse instead of the default dirac pulse could be
% used
% d = convolution(d,hann_window(5,5,10));
for ii = 1:length(t)
    if showprogress, progress_bar(ii,length(t)); end
    % calculate sound field at the listener position
    p = sound_field_imp(X(1),X(2),X(3),x0,greens_function,d,t(ii),conf);
    s(ii) = real(p);
end

% Return parameter
if nargout>0, varargout{1}=s; end
if nargout>1, varargout{2}=t; end


%% ===== Plotting ========================================================
if nargout==0 || useplot
    figure;
    figsize(conf.plot.size(1),conf.plot.size(2),conf.plot.size_unit);
    plot(t/fs*1000,db(abs(s)));
    ylabel('amplitude / dB');
    xlabel('time / ms');
end
