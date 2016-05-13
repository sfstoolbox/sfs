function D = driving_function_mono_wfs_ps(x0,nx0,xs,f,conf)
%DRIVING_FUNCTION_MONO_WFS_PS returns the driving signal D for a point source in
%WFS
%
%   Usage: D = driving_function_mono_wfs_ps(x0,nx0,xs,f,conf)
%
%   Input parameters:
%       x0          - position of the secondary sources / m [nx3]
%       nx0         - directions of the secondary sources / m [nx3]
%       xs          - position of virtual point source / m [nx3]
%       f           - frequency of the monochromatic source / Hz
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   DRIVING_FUNCTION_MONO_WFS_PS(x0,xs,f,src,conf) returns WFS driving signals
%   for the given secondary sources, the virtual point source position and the
%   frequency f.
%
%   References:
%       H. Wierstorf, J. Ahrens, F. Winter, F. Schultz, S. Spors (2015) -
%       "Theory of Sound Field Synthesis"
%       S. Spors, R. Rabenstein, J. Ahrens (2008) - "The Theory of Wave Field
%       Synthesis Revisited", AES124
%       E. Verheijen (1997) - "Sound Reproduction by Wave Field Synthesis", PhD
%       thesis, TU Delft
%       D. Opperschall (2002) - "Realisierung eines Demonstrators für
%       Punktquellen und ebene Wellen für ein Wellenfeldsynthese-System",
%       Master thesis, Universität Erlangen-Nürnberg
%       F. Völk (2010) - "Psychoakustische Experimente zur Distanz mittels
%       Wellenfeldsynthese erzeugter Hörereignisse", DAGA, p.1065-66
%       S. Spors, J. Ahrens (2010) - "Analysis and Improvement of
%       Pre-equalization in 2.5-Dimensional Wave Field Synthesis", AES128
%
%   See also: driving_function_mono_wfs, driving_function_imp_wfs_ps

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
nargmin = 5;
nargmax = 5;
narginchk(nargmin,nargmax);
isargmatrix(x0,nx0,xs);
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


if strcmp('2D',dimension) || strcmp('3D',dimension)

    % === 2- or 3-Dimensional ============================================

    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % D using a point sink and large distance approximation
        %
        %            1  i w  (x0-xs) nx0
        % D(x0,w) = --- --- ------------- e^(-i w/c |x0-xs|)
        %           2pi  c  |x0-xs|^(3/2)
        %
        % see Wierstorf et al. (2015), eq.(#D:wfs:ps)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = 1/(2*pi) .* (1i*omega)/c .* ...
            vector_product(x0-xs,nx0,2) ./ r.^(3/2) .* exp(-1i*omega/c.*r);
        %
    elseif strcmp('point_source',driving_functions)
        % D using a point source as source model
        %
        %            1  / i w      1    \  (x0-xs) nx0
        % D(x0,w) = --- | --- - ------- |  ----------- e^(-i w/c |x0-xs|)
        %           2pi \  c    |x0-xs| /   |x0-xs|^2
        %
        % see Wierstorf et al. (2015), eq.(#D:wfs:ps:woapprox)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = 1/(2*pi) .* ( (1i*omega)/c - 1./r ) .* ...
            vector_product(x0-xs,nx0,2) ./ r.^2 .* exp(-1i*omega/c.*r);
        %
    elseif strcmp('line_source',driving_functions)
        % D using a line source as source model (truly 2D model)
        %
        %             1  i w (x0-xs) nx0  (2)/ w         \
        % D(x0,x) = - -- --- ----------- H1  | - |x0-xs| |
        %             2c  c    |x0-xs|       \ c         /
        %
        % see Spors et al. (2008), eq.(23)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = -1/(2*c) .* 1i*omega/c * vector_product(x0-xs,nx0,2) ./ r .* besselh(1,2,omega/c*r);
        %
        %
    elseif strcmp('delft1988',driving_functions)
        % --- Delft 1988 -------------------------------------------------
        to_be_implemented;
        %
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a point source.'],upper(mfilename),driving_functions);
    end


elseif strcmp('2.5D',dimension)

    % === 2.5-Dimensional ================================================

    % Reference point
    xref = repmat(xref,[size(x0,1) 1]);
    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % 2.5D correction factor
        %        _____________
        % g0 = \| 2pi |xref-x0|
        %
        g0 = sqrt(2*pi*vector_norm(xref-x0,2));
        %
        % D_2.5D using a point source and large distance approximation
        %                       ___
        %                g0    |i w  (x0-xs) nx0
        % D_2.5D(x0,w) = --- _ |--- ------------- e^(-i w/c |x0-xs|)
        %                2pi  \| c  |x0-xs|^(3/2)
        %
        % see Wierstorf et al. (2015), eq.(#D:wfs:ps:2.5D)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = g0/(2*pi) .* sqrt(1i*omega/c) .* ...
            vector_product(x0-xs,nx0,2) ./ r.^(3/2) .* exp(-1i*omega/c.*r);
        %
    elseif strcmp('point_source',driving_functions)
        % 2.5D correction factor
        %        ______________
        % g0 = \| 2pi |xref-x0|
        %
        g0 = sqrt(2*pi*vector_norm(xref-x0,2));
        %
        % D_2.5D using a point source as source model
        %
        % D_2.5D(x0,w) =
        %           ___       ___
        %  g0  /   |i w      | c      1    \  (x0-xs) nx0
        % ---  | _ |---  - _ |---  ------- |  ----------- e^(-i w/c |x0-xs|)
        % 2pi  \  \| c      \|i w  |x0-xs| /   |x0-xs|^2
        %
        % see Wierstorf et al. (2015), eq.(#D:wfs:ps:woapprox:2.5D)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = g0/(2*pi) .* ( sqrt(1i*omega/c) - sqrt(c/(1i*omega) ./ r ) ) .* ...
            vector_product(x0-xs,nx0,2) ./ r.^2 .* exp(-1i*omega/c .* r);
        %
    elseif strcmp('delft1988',driving_functions)
        % --- Delft 1988 -------------------------------------------------
        % D_2.5 using a point source as source model (after Delft)
        %
        % 2.5D correction factor
        %        _______________________
        % g0 = \| -y_ref / (y_s - y_ref)
        %
        g0 = sqrt(- xref(1,2) / (xs(1,2) - xref(1,2)));
        %                      _____
        %                     |i w   (x0-xs) nx0
        % D_2.5D(x0,w) = g0 _ |----- ------------  e^(-i w/c |x0-xs|)
        %                    \|2pi c |x0-xs|^(3/2)
        %
        % see Verheijen (1997), p.41 eq.(2.27)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = sqrt(1i*omega/(2*pi*c)) * g0 * vector_product(x0-xs,nx0,2) ./ r.^(3/2) .* exp(-1i*omega/c .* r);
        %
    elseif strcmp('opperschall',driving_functions)
        % --- Opperschall -------------------------------------------------
        % Driving function with only one stationary phase
        % approximation, reference to one point in field
        %
        % 2.5D correction factor
        %         _____________________
        %        |      |xref-x0|
        % g0 = _ |---------------------
        %       \| |x0-xs| + |xref-x0|
        %
        g0 = sqrt( vector_norm(x0-xref,2) ./ (vector_norm(xs-x0,2) + vector_norm(x0-xref,2)) );
        %                      ______
        %                     | i w    (x0-xs) nx0
        % D_2.5D(x0,w) = g0 _ |------ ------------- e^(-i w/c |x0-xs|)
        %                    \|2pi c  |x0-xs|^(3/2)
        %
        % see Opperschall (2002), p.14 eq.(3.1), eq.(3.14), eq.(3.15)
        %
        % r = |x0-xs|
        r = vector_norm(x0-xs,2);
        % Driving signal
        D = sqrt(1i*omega/(2*pi*c)) * g0 .* vector_product(x0-xs,nx0,2) ./ r.^(3/2) .* exp(-1i*omega/c .* r);
        %
    elseif strcmp('volk2010',driving_functions)
        % --- Voelk 2010 --------------------------------------------------
        %         _____________________
        %        |      |xref-x0|
        % g0 = _ |---------------------
        %       \| |x0-xs| + |xref-x0|
        %
        g0 = sqrt( vector_norm(xref-x0,2) ./ (vector_norm(xs-x0,2) + vector_norm(x0-xref,2)) );
        %
        % D_2.5D(x0,w) =
        %       ___    ___
        %      | 1    |i w (x0-xs) nx0
        % g0 _ |--- _ |--- ------------- e^(-i w/c |x0-xs|)
        %     \|2pi  \| c  |x0-xs|^(3/2)
        %
        % see Völk (2010), eq.(3)
        %
        r = vector_norm(x0-xs,2);
        D = g0/sqrt(2*pi) * sqrt(1i*omega/c) * ...
            vector_product(x0-xs,nx0,2)./r.^(3/2) .* exp(-1i*omega/c.*r);
        %
    elseif strcmp('SDMapprox',driving_functions)
        % --- Spors 2010 --------------------------------------------------
        % Driving function derived by approximation of the SDM
        %
        % 2.5D correction factor
        %        _______________________
        % g0 = \| -y_ref / (y_s - y_ref)
        %
        g0 = sqrt(- xref(1,2) / (xs(1,2) - xref(1,2)));
        %
        %                1 i w       ys    (2)/w       \
        % D_2.5D(x0,w) = - --- g0 ------- H1 | -|x0-xs| |
        %                2  c     |x0-xs|     \c       /
        %
        % see Spors and Ahrens (2010), eq.(24)
        %
        r = vector_norm(x0-xs,2);
        D = 1/2 * 1i*omega/c * g0 * xs(1,2)./r .* besselh(1,2,omega/c*r);
        %
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2.5D point source.'],upper(mfilename),driving_functions);
    end

else
    error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end
