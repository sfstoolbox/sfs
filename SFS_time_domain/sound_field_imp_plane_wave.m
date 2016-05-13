function varargout = sound_field_imp_plane_wave(X,Y,Z,xs,t,conf)
%SOUND_FIELD_IMP_PLANE_WAVE simulates a sound field of a plane wave
%
%   Usage: [p,x,y,z] = sound_field_imp_plane_wave(X,Y,Z,xs,t,conf)
%
%   Input parameters:
%       X           - x-axis / m; single value or [xmin,xmax] or nD-array
%       Y           - y-axis / m; single value or [ymin,ymax] or nD-array
%       Z           - z-axis / m; single value or [zmin,zmax] or nD-array
%       xs          - direction of the plane wave / m
%       t           - time / samples
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       p           - Simulated sound field
%       x           - corresponding x values / m
%       y           - corresponding y values / m
%       z           - corresponding z values / m
%
%   SOUND_FIELD_IMP_PLANE_WAVE(X,Y,Z,xs,t,conf) simulates a sound
%   field of a plane wave going in the direction xs at time t.
%
%   To plot the result use:
%   plot_sound_field(p,X,Y,Z,conf);
%   or simple call the function without output argument:
%   sound_field_imp_plane_wave(X,Y,Z,xs,t,conf)
%   For plotting you may also consider to display the result in dB, by setting
%   the following configuration option before:
%   conf.plot.usedB = true;
%
%   See also: sound_field_imp, plot_sound_field, sound_field_mono_plane_wave

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
nargmin = 6;
nargmax = 6;
narginchk(nargmin,nargmax);
isargxs(xs);
isargstruct(conf);


%% ===== Computation ====================================================
% Disable the plotting of a source, because we have a plane wave
conf.plot.loudspeakers = 0;
[varargout{1:nargout}] = sound_field_imp(X,Y,Z,[xs 0 1 0 1],'pw',1,t,conf);
