function Anm = sphexp_mono_pw(npw,Nse,f,xq,conf)
%SPHEXP_MONO_PW computes the regular spherical expansion of plane wave
%
%   Usage: Anm = sphexp_mono_pw(npw,Nse,f,xq,conf)
%
%   Input parameters:
%       npw         - unit vector propagation direction of plane wave
%       Nse         - maximum order of spherical basis functions
%       f           - frequency / Hz [Nf x 1] or [1 x Nf]
%       xq          - optional expansion coordinate
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       Anm         - regular Spherical Expansion Coefficients [(Nse+1)^2 x Nf]
%
%   SPHEXP_MONO_PW(npw,Nse,f,xq,conf) computes the regular spherical
%   expansion coefficients for a plane wave. The expansion will be done around
%   the expansion coordinate xq:
%
%              \~~ oo  \~~   n   m  m
%   p  (x,f) =  >       >       A  R  (x-x )
%    pw        /__ n=0 /__ m=-n  n  n     q
%
%   with the expansion coefficients (Gumerov, p. 74, eq. 2.3.6):
%
%    m        -n  -m
%   A  = 4pi i   Y   (theta  , phi  )
%    n            n       pw     pw
%
%   The coefficients are stored in linear arrays with index l resulting from
%   m and n:
%
%         m                 2
%   A  = A  ; with l = (n+1)  - (n - m)
%    l    n
%
%   References:
%       Gumerov,Duraiswami (2004) - "Fast Multipole Methods for the
%                                    Helmholtz Equation in three
%                                    Dimensions", ELSEVIER
%
%   see also: sphexp_mono_ls sphexp_mono_ps

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
isargposition(npw);
isargstruct(conf);
isargposition(xq);
isargpositivescalar(Nse);
isargvector(f);

%% ===== Configuration ==================================================
c = conf.c;

%% ===== Computation ====================================================
% convert npw into spherical coordinates
phi = atan2(npw(2),npw(1));
theta = asin(npw(3));

% phase shift due to expansion coordinate
phase = exp(-1j*2*pi*row_vector(f)/c*(npw*xq.'));
Nf = length(phase);

Anm = zeros((Nse + 1).^2,Nf);
for n=0:Nse
    cn = 4*pi*(1j)^(-n);
    for m=0:n
        % spherical harmonics: conj(Y_n^m) = Y_n^-m (Gumerov2004, eq. 2.1.59)
        Ynm = sphharmonics(n,m,theta,phi);
        % -m
        v = sphexp_index(-m,n);
        Anm(v,:) = cn.*Ynm.*phase;
        % +m
        v = sphexp_index(m,n);
        Anm(v,:) = cn.*conj(Ynm).*phase;
    end
end
