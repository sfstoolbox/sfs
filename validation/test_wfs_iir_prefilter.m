function boolean = test_wfs_iir_prefilter()
%TEST_WFS_IIR_PREFILTER tests the IIR WFS pre-equalization filter
%
%   Usage: boolean = test_wfs_iir_prefilter()
%
%   Output parameters:
%       booelan - true or false
%
%   TEST_WFS_IIR_PREFILTER() test the WFS pre-euqalization IIR filter
%   design. This works only in Matlab as the Signal Processing Toolbox is used.
%   See wfs_iir_prefilter.m for details

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



%% ===== Configuration ===================================================
boolean = false;
conf = SFS_config;


%% ===== Calculation =====================================================
% call with default values
hpre1 = wfs_iir_prefilter(conf)
conf.fs = 44100;
conf.hpreflow = 200;
conf.hprefhigh = 1500;
conf.hpreBandwidth_in_Oct = 2;
conf.hpreIIRorder = 4;
hpre2 = wfs_iir_prefilter(conf)
boolean = true;
