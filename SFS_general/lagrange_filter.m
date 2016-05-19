function [b,li] = lagrange_filter(Norder,fdt)
%LAGRANGE_FILTER computes Lagrange interpolation filter for fractional delays
%
%   Usage: [b,[li]] = lagrange_filter(order,[fdt])
%
%   Input parameter:
%     order  - order N of Lagrange polynomials
%     fdt    - optional vector of fractional delays
%              0 <= fdt < 1 if order is odd,
%              -0.5 <= fdt < 0.5 if order is even
%
%   Output parameter:
%     b   - filter coefficients / [order+1 x Nfdt]
%     li  - optional matrix of lagrange polynomials l_i(x) with i = 0..N
%           l_i(x) = (x - x_0)/(x_i - x_0) * ...*  (x - x_i-1) /(x_i - x_i-1)
%                    * (x - x_i+1)/(x_i - x_i+1) * ... * (x - x_N)/(x_i - x_N)
%                  = c_{i,N} x^N + c_{i,N-1} x^(N-1) + ... + c_{i,0} x^(0)
%           where x_k = k with k = N..0. The i-th row of li stores the
%           coefficients c_{i,k}.
%
%   See also: delayline, thiran_filter

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


%% ===== Computation =====================================================
if nargin == 2
    D = fdt(:).' + floor(Norder/2);

    % aux = D, (D-1), (D-2),...,(D-N+1),(D-N)
    aux = bsxfun(@minus,D,(0:Norder).');
    
    % denom = n*(n-1)*...*(n-N+1)*(n-N) = n!*(N-n)!*(-1)^(N-n)
    denom = factorial(0:Norder);
    denom = denom.*denom(end:-1:1).*(-1).^(Norder:-1:0);
    
    b = zeros(Norder+1, length(D));
    for ndx=1:Norder+1
        b(ndx,:) = prod(aux([1:ndx-1,ndx+1:end],:),1)./denom(ndx);
    end
else
    b = [];
end

if nargout == 2
    % Each row contains [1 x_i] which is equivalent to m_i(x) = (x - x_i)
    mi = [ones(Norder,1), -(0:Norder).'];
    
    % l(x) = m_0(x) * m_1(x) .. * m_N(x) = (x - x_0) * (x - x_1) * .. * (x - x_N)
    l = 1;
    for idx=1:Norder
        % Convolution of coefficients means multiplication of polynoms
        l = conv(l,mi(idx,:));
    end

    li = zeros(Norder,Norder);
    for idx=1:N
        % nom_i(x) = l(x) / m_i(x)
        %          = (x - x_0) * .. * (x - x_{i-1}) * (x - x_{i+1}) * .. * (x - x_N)
        nominator = deconv(l,mi(idx,:));
        % denom_i = nom_i(x_i) evaluated with "polyval"
        denominator = polyval(nominator,xi(idx));
        % l_i(x) = nom_i(x) / denom_i;
        li(idx,:) = nominator./denominator;
    end
end
