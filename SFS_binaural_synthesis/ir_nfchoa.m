function [ir,x0] = ir_nfchoa(X,phi,xs,src,sofa,conf)
%IR_NFCHOA generates a binaural simulation of NFCHOA
%
%   Usage: [ir,x0] = ir_nfchoa(X,phi,xs,src,sofa,conf)
%
%   Input parameters:
%       X       - listener position / m
%       phi     - listener direction [head orientation] / rad
%                 0 means the head is oriented towards the x-axis.
%       xs      - virtual source position [ys > Y0 => focused source] / m
%       src     - source type: 'pw' -plane wave
%                              'ps' - point source
%       sofa    - impulse response data set for the secondary sources
%       conf    - configuration struct (see SFS_config)
%
%   Output parameters:
%       ir      - impulse response for the desired HOA synthesis (nx2 matrix)
%       x0      - secondary sources
%
%   IR_NFCHOA(X,phi,xs,src,L,sofa,conf) calculates a binaural room impulse
%   response for a virtual source at xs for a virtual NFCHOA array and a
%   listener located at X.
%
%   See also: ssr_brs_nfchoa, ir_nfchoa, ir_point_source, auralize_ir

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
if conf.debug
    isargposition(X);
    isargxs(xs);
    isargscalar(phi);
    isargpositivescalar(L);
    isargchar(src);
    isargstruct(config);
end


%% ===== Variables ======================================================
% Loudspeaker positions
x0 = secondary_source_positions(conf);


%% ===== BRIR ===========================================================
% Calculate driving function
d = driving_function_imp_nfchoa(x0,xs,src,conf);
% Generate the impulse response for NFCHOA
ir = ir_generic(X,phi,x0,d,sofa,conf);
