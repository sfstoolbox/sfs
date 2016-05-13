function outsig = easyifft(amplitude,phase)
%EASYIFFT calculates the inverse FFT
%
%   Usage: outsig = easyifft(amplitude,phase)
%
%   Input parameters:
%       amplitude   - the amplitude spectrum
%       phase       - the phase spectrum / rad
%
%   Output parameters:
%       outsig      - a one channel signal
%
%   EASYIFFT(amplitude,phase) generates the corresponding waveform from the
%   amplitude and phase spectra using ifft.
%
%   See also: easyfft, ifft

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


%% ===== Checking input arguments ========================================
nargmin = 2;
nargmax = 2;
narginchk(nargmin,nargmax);
[amplitude,phase] = column_vector(amplitude,phase);


%% ===== Regenerating wave form from spectrum ============================
% Length of the signal to generate
samples = 2 * (length(amplitude)-1);

% Rescaling (see easyfft)
amplitude = amplitude/2 * samples;

% Mirror the amplitude spectrum
amplitude = [ amplitude; amplitude(end-1:-1:2) ];

% Mirror the phase spectrum and build the inverse (why?)
phase = [ phase; -1*phase(end-1:-1:2) ];

% Convert to complex spectrum
compspec = amplitude .* exp(1i*phase);

% Build the inverse fft and use only the real part
outsig = real( ifft(compspec) );
