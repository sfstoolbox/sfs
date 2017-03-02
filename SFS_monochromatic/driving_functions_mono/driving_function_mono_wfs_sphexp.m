function D = driving_function_mono_wfs_sphexp(x0,n0,Pnm,mode,f,xq,conf)
%computes the wfs driving functions for a sound field expressed by spherical
%expansion coefficients.
%
%   Usage: D = driving_function_mono_wfs_sphexp(x0,n0,Pnm,mode,f,xq,conf)
%
%   Input parameters:
%       x0          - position of the secondary sources / m [nx3]
%       n0          - directions of the secondary sources / m [nx3]
%       Pnm         - singular spherical expansion coefficients of sound field
%       mode        - 'R' for regular expansion, 'S' for singular expansion
%       f           - frequency in Hz
%       xq          - expansion center coordinates / m [1x3]
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   DRIVING_FUNCTION_MONO_WFS_SPHEXP(x0,n0,Pnm,mode,f,xq,conf)
%
%   see also: driving_function_mono_wfs_cylexp
%
%   References:
%     Spors2011 - "Local Sound Field Synthesis by Virtual Acoustic Scattering
%       and Time-Reversal" (AES131)
%     Gumerov,Duraiswami (2004) - "Fast Multipole Methods for the Helmholtz
%       Equation in three Dimensions", ELSEVIER

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
isargmatrix(x0,n0);
isargvector(Pnm);
isargpositivescalar(f);
isargchar(mode);
isargposition(xq);
isargstruct(conf);

%% ===== Configuration ==================================================
c = conf.c;
dimension = conf.dimension;
driving_functions = conf.driving_functions;

%% ===== Variables ======================================================
Nse = sqrt(size(Pnm, 1))-1;

% apply shift to the center of expansion xq
x = x0(:,1)-xq(1);
y = x0(:,2)-xq(2);
z = x0(:,3)-xq(3);

% conversion to spherical coordinates
r0 = sqrt(x.^2 + y.^2 + z.^2);
phi0 = atan2(y,x);
theta0 = asin(z./r0);

% frequency depended stuff
omega = 2*pi*f;
k = omega/c;
kr = k.*r0;

% gradient in spherical coordinates
Gradr = zeros(size(x0,1),1);
Gradphi = zeros(size(x0,1),1);
Gradtheta = zeros(size(x0,1),1);

% directional weights for conversion spherical gradient into carthesian
% coordinates + point product with normal vector n0 (directional derivative
% in cartesian coordinates)
Sn0r     =  cos(theta0).*cos(phi0).*n0(:,1)...
  +  cos(theta0).*sin(phi0).*n0(:,2)...
  +  sin(theta0)          .*n0(:,3);
Sn0phi   = -sin(phi0)            .*n0(:,1)...
  +  cos(phi0)            .*n0(:,2);
Sn0theta =  sin(theta0).*cos(phi0).*n0(:,1)...
  +  sin(theta0).*sin(phi0).*n0(:,2)...
  -  cos(theta0)          .*n0(:,3);

% select suitable basis function
if strcmp('R', mode)
  sphbasis = @sphbesselj;
  sphbasis_derived = @sphbesselj_derived;
elseif strcmp('S', mode)
  sphbasis = @(nu,z) sphbesselh(nu,2,z);
  sphbasis_derived = @(nu,z) sphbesselh_derived(nu,2,z);
else
  error('unknown mode:');
end

%% ===== Computation ====================================================
% Calculate the driving function in time-frequency domain

% indexing the expansion coefficients
l = 0;

switch dimension
  case {'3D'}
    
    if (strcmp('default',driving_functions))
      % --- SFS Toolbox ------------------------------------------------
      %
      %                 d
      % D(x0, w) = -2 ------ P(x0,w)
      %                d n0
      % with regular/singular spherical expansion of the sound field:
      %          \~~   N \~~   n   m  m
      % P(x,w) =  >       >       B  F (x-xq)
      %          /__ n=0 /__ m=-n  n  n
      %
      % where F = {R,S}.
      %
      % regular spherical basis functions:
      %  m                  m
      % R  (x) = j (kr)  . Y  (theta, phi)
      %  n        n         n
      % singular spherical basis functions:
      %  m        (2)         m
      % S  (x) = h   (kr)  . Y  (theta, phi)
      %  n        n           n
      
      for n=0:Nse
        cn_prime = k.*sphbasis_derived(n,kr);
        cn = sphbasis(n, kr);
        for m=-n:n
          l = l + 1;
          Ynm = sphharmonics(n,m, theta0, phi0);
          Gradr   = Gradr       + Pnm(l).*cn_prime.*Ynm;
          Gradphi = Gradphi     + 1./r0.*Pnm(l).*cn.*1j.*m.*Ynm;
          Gradtheta = Gradtheta + 1./(r0.*cos(theta0).^2).*cn.*Pnm(l).*...
            ( (n+1).*sin(theta0).*Ynm - ...
            sqrt((2*n+1)./(2*n+3).*((n+1).^2-m^2)).* ...
            sphharmonics(n+1,m, theta0, phi0) );
        end
      end
      % directional gradient
      D = -2*( Sn0r.*Gradr + Sn0phi.*Gradphi + Sn0theta.*Gradtheta );
    else
      error(['%s: %s, this type of driving function is not implemented ', ...
        'for 3D'],upper(mfilename),driving_functions);
    end
    
  case {'2D', '2.5D'}
    if (strcmp('default',driving_functions))
      % approximate spherical expansion with circular expansion
      Pm = circexp_convert_sphexp(Pnm);
      % compute driving function for circular expansion
      D = driving_function_mono_wfs_circexp(x0,n0,Pm,mode,f,xq,conf);
    else
      error(['%s: %s, this type of driving function is not implemented ', ...
        'for 2D/2.5D'],upper(mfilename),driving_functions);
    end    
  otherwise
    error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end
