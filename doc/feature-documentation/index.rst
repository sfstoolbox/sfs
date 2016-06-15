.. _sec-feature-documentation:

Feature Documentation
=====================

Add an overview of the Toolbox here. What you can do in general: mono-frquent,
time domain, binaura simulations, secondary sources and then present links to
all of the subfolders.

All of the coming sections can maybe put into subfolders.

Secondary sources
-----------------

The Toolbox comes with a function which can generate different common
shapes of loudspeaker arrays for you. At the moment linear, circular,
box shaped and spherical arrays are supported.

Before showing the different geometries, we start with some common
settings. First we get a configuration struct and set the array
size/diameter to 3 m.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.size = 3;

Linear array
~~~~~~~~~~~~

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.geometry = 'line'; % or 'linear'
    conf.secondary_sources.number = 21;
    x0 = secondary_source_positions(conf);
    figure;
    figsize(conf.plot.size(1),conf.plot.size(2),conf.plot.size_unit);
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2 1]);
    %print_png('img/secondary_sources_linear.png');

.. figure:: img/secondary_sources_linear.png
   :align: center

   Linear loudspeaker array with a length of 3m consiting of 21 loudspeakers.

Circular array
~~~~~~~~~~~~~~

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.geometry = 'circle'; % or 'circular'
    conf.secondary_sources.number = 56;
    x0 = secondary_source_positions(conf);
    figure;
    figsize(540,404,'px');
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2 2]);
    %print_png('img/secondary_sources_circle.png');

.. figure:: img/secondary_sources_circle.png
   :align: center

   Circular loudspeaker array with a diameter of 3m consiting of 56
   loudspeakers.

Box shaped array
~~~~~~~~~~~~~~~~

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.geometry = 'box';
    conf.secondary_sources.number = 84;
    x0 = secondary_source_positions(conf);
    figure;
    figsize(540,404,'px');
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2 2]);
    %print_png('img/secondary_sources_box.png');

.. figure:: img/secondary_sources_box.png
   :align: center

   Box shaped loudspeaker array with a diameter of 3m consisting of 84
   loudspeakers.

Box shaped array with rounded edges
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``conf.secondary_sources.edge_radius`` defines the bending radius of the
corners. It can be chosen in a range between ``0.0`` and the half of
``conf.secondary_sources.size``. While the prior represents a square box
the latter yields a circle. Note that the square box behaves it little
bit different than the Box Shaped Array since loudspeakers might also be
place directly in the corners of the box.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.geometry = 'rounded-box';
    conf.secondary_sources.number = 84;
    conf.secondary_sources.corner_radius = 0.3;
    x0 = secondary_source_positions(conf);
    figure;
    figsize(540,404,'px');
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2 2]);
    %print_png('img/secondary_sources_rounded-box.png');

.. figure:: img/secondary_sources_rounded-box.png
   :align: center

   Box shaped loudspeaker array with rounded edges. It has again a diameter of
   3m, consists of 84 loudspeakers and has a edge bending factor of 0.3.

Spherical array
~~~~~~~~~~~~~~~

For a spherical array you need a grid to place the secondary sources on the
sphere. At the moment we provide grids with the Toolbox, that can be found in
the `corresponding folder of the data repository`_.  You have to specify your
desired grid, for example ``conf.secondary_sources.grid =
'equally_spaced_points'``. The ``secondary_source_positions()`` functions will
then automatically download the desired grid from that web page and stores it
under ``<$SFS_MAIN_PATH>/data``. If the download is not working (which can
happen especially under Matlab and Windows) you can alternatively checkout or
download the whole `data repository`_ to the data folder.

.. _corresponding folder of the data repository: http://github.com/sfstoolbox/data/tree/master/spherical_grids
.. _data repository: http://github.com/sfstoolbox/data

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.size = 3;
    conf.secondary_sources.geometry = 'sphere'; % or 'spherical'
    conf.secondary_sources.grid = 'equally_spaced_points';
    conf.secondary_sources.number = 225;
    x0 = secondary_source_positions(conf);
    figure;
    figsize(540,404,'px');
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2 2]);
    %print_png('img/secondary_sources_sphere.png');

.. figure:: img/secondary_sources_sphere.png
   :align: center

   Spherical loudspeaker array with a diameter of 3m consiting of 225
   loudspeakers arranged on a grid with equally spaced points.

Arbitrary shaped arrays
~~~~~~~~~~~~~~~~~~~~~~~

You can create arbitrarily shaped arrays by setting
``conf.secondary_sources.geometry`` to ``'custom'`` and define the values of the
single loudspeaker directly in the ``conf.secondary_sources.x0`` matrix. The
rows of the matrix contain the single loudspeakers and the six columns are ``[x
y z nx ny nz w]``, the position and direction and weight of the single
loudspeakers. The weight ``w`` is a factor the driving function of this
particular loudspeaker is multiplied with in a function that calculates the
sound field from the given driving signals and secondary sources. For |WFS|
``w`` could include the tapering window, a spherical grid weight, and the
:math:`r^2 \cos(\theta)` weights for integration on a sphere.

.. sourcecode:: matlab

    conf = SFS_config;
    % create a stadium like shape by combining two half circles with two linear
    % arrays
    % first getting a full circle with 56 loudspeakers
    conf.secondary_sources.geometry = 'circle';
    conf.secondary_sources.number = 56;
    conf.secondary_sources.x0 = [];
    x0 = secondary_source_positions(conf);
    % store the first half cricle and move it up
    x01 = x0(2:28,:);
    x01(:,2) = x01(:,2) + ones(size(x01,1),1)*0.5;
    % store the second half circle and move it down
    x03 = x0(30:56,:);
    x03(:,2) = x03(:,2) - ones(size(x03,1),1)*0.5;
    % create a linear array
    conf.secondary_sources.geometry = 'line';
    conf.secondary_sources.number = 7;
    conf.secondary_sources.size = 1;
    x0 = secondary_source_positions(conf);
    % rotate it and move it left
    R = rotation_matrix(pi/2);
    x02 = [(R*x0(:,1:3)')' (R*x0(:,4:6)')'];
    x02(:,1) = x02(:,1) - ones(size(x0,1),1)*1.5;
    x02(:,7) = x0(:,7);
    % rotate it the other way around and move it right
    R = rotation_matrix(-pi/2);
    x04 = [(R*x0(:,1:3)')' (R*x0(:,4:6)')'];
    x04(:,1) = x04(:,1) + ones(size(x0,1),1)*1.5;
    x04(:,7) = x0(:,7);
    % combine everything
    conf.secondary_sources.geometry = 'custom';
    conf.secondary_sources.x0 = [x01; x02; x03; x04];
    % if we gave the conf.x0 to the secondary_source_positions function it will
    % simply return the defined x0 matrix
    x0 = secondary_source_positions(conf);
    figure;
    figsize(540,404,'px');
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2.5 2.5]);
    %print_png('img/secondary_sources_arbitrary.png');

.. figure:: img/secondary_sources_arbitrary.png
   :align: center

   Custom arena shaped loudspeaker array consiting of 70 loudspeakers.

Plot loudspeaker symbols
~~~~~~~~~~~~~~~~~~~~~~~~

For two dimensional setups you can plot the secondary sources with
loudspeaker symbols, for example the following will replot the last
array.

.. sourcecode:: matlab

    conf.plot.realloudspeakers = true;
    figure;
    figsize(540,404,'px');
    draw_loudspeakers(x0,conf);
    axis([-2 2 -2.5 2.5]);
    %print_png('img/secondary_sources_arbitrary_realloudspeakers.png');

.. figure:: img/secondary_sources_arbitrary_realloudspeakers.png
   :align: center

   Custom arena shaped loudspeaker array consiting of 70 loudspeakers, plotted
   using loudspeaker symbols instead of circles for the single loudspeakers.

Simulate monochromatic sound fields
-----------------------------------

With the files in the folder ``SFS_monochromatic`` you can simulate a
monochromatic sound field in a specified area for different techniques like
|WFS| and NFC-HOA. The area can be a 3D cube, a 2D plane, a line or only one
point. This depends on the specification of ``X,Y,Z``. For example ``[-2 2],[-2
2],[-2 2]`` will be a 3D cube; ``[-2 2],0,[-2 2]`` the xz-plane; ``[-2 2],0,0``
a line along the x-axis; ``3,2,1`` a single point. If you present a range like
``[-2 2]`` the Toolbox will create automatically a regular grid from this
ranging from -2 to 2 with ``conf.resolution`` steps in between. Alternatively
you could apply a :ref:`custom grid <sec-custom-grid>` by providing a matrix
instead of the ``[min max]`` range for all active axes.

For all 2.5D functions the configuration ``conf.xref`` is important as it
defines the point for which the amplitude is corrected in the sound
field. The default entry is

.. sourcecode:: matlab

    conf.xref = [0 0 0];

Wave Field Synthesis
~~~~~~~~~~~~~~~~~~~~

The following will simulate the field of a virtual plane wave with a
frequency of 800 Hz going into the direction of (0 -1 0) synthesized
with 3D |WFS|.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.dimension = '3D';
    conf.secondary_sources.size = 3;
    conf.secondary_sources.number = 225;
    conf.secondary_sources.geometry = 'sphere';
    % [P,x,y,z,x0,win] = sound_field_mono_wfs(X,Y,Z,xs,src,f,conf);
    sound_field_mono_wfs([-2 2],[-2 2],0,[0 -1 0],'pw',800,conf);
    %print_png('img/sound_field_wfs_3d_xy.png');
    sound_field_mono_wfs([-2 2],0,[-2 2],[0 -1 0],'pw',800,conf);
    %print_png('img/sound_field_wfs_3d_xz.png');
    sound_field_mono_wfs(0,[-2 2],[-2 2],[0 -1 0],'pw',800,conf);
    %print_png('img/sound_field_wfs_3d_yz.png');

.. figure:: img/sound_field_wfs_3d_xy.png
   :align: center

   Sound pressure of a mono-chromatic plane wave synthesized by 3D |WFS|. The
   plane wave has a frequency of 800Hz and is travelling into the direction
   (0,-1,0). The plot shows the xy-plane.

.. figure:: img/sound_field_wfs_3d_xz.png
   :align: center

   The same as in the figure before, but now showing the xz-plane.

.. figure:: img/sound_field_wfs_3d_yz.png
   :align: center

   The same as in the figure before, but now showing the yz-plane.

You can see that the Toolbox is now projecting all the secondary source
positions into the plane for plotting them. In addition the axis are
automatically chosen and labeled.

It is also possible to simulate and plot the whole 3D cube, but in this
case no secondary sources will be added to the plot.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.dimension = '3D';
    conf.secondary_sources.size = 3;
    conf.secondary_sources.number = 225;
    conf.secondary_sources.geometry = 'sphere';
    conf.resolution = 100;
    sound_field_mono_wfs([-2 2],[-2 2],[-2 2],[0 -1 0],'pw',800,conf);
    %print_png('img/sound_field_wfs_3d_xyz.png');

.. figure:: img/sound_field_wfs_3d_xyz.png
   :align: center

   Sound pressure of a mono-chromatic plane wave synthesized by 3D |WFS|. The
   plane wave has a frequency of 800Hz and is travelling into the direction
   (0,-1,0). All three dimensions are shown.

In the next plot we use a two dimensional array, 2.5D |WFS| and a virtual
point source located at (0 2.5 0) m. The 3D example showed you, that the
sound fields are automatically plotted if we specify now output
arguments. If we specify one, we have to explicitly say if we want also
plot the results, by ``conf.plot.useplot = true;``.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.dimension = '2.5D';
    conf.plot.useplot = true;
    conf.plot.normalisation = 'center';
    % [P,x,y,z,x0] = sound_field_mono_wfs(X,Y,Z,xs,src,f,conf);
    [P,x,y,z,x0] = sound_field_mono_wfs([-2 2],[-2 2],0,[0 2.5 0],'ps',800,conf);
    %print_png('img/sound_field_wfs_25d.png');

.. figure:: img/sound_field_wfs_25d.png
   :align: center

   Sound pressure of a mono-chromatic point source synthesized by 2.5D |WFS|. The
   point source has a frequency of 800Hz and is placed at (0 2.5 0)m. Only the
   active loudspeakers of the array are plotted.

If you want to plot the whole loudspeaker array and not only the active
secondary sources, you can do this by adding these commands. First we
store all sources in an extra variable ``x0_all``, then we get the active
ones ``x0`` and the corresponding indices of these active ones in ``x0_all``.
Afterwards we set all sources in ``x0_all`` to zero, which is inactive and
only the active ones to ``x0(:,7)``.

FIXME: correct this section. Use real loudspeakers and show weights or simplify
the example!

.. sourcecode:: matlab

    x0_all = secondary_source_positions(conf);
    [x0,idx] = secondary_source_selection(x0_all,[0 2.5 0],'ps');
    x0_all(:,7) = zeros(1,size(x0_all,1));
    x0_all(idx,7) = x0(:,7);
    plot_sound_field(P,x,y,z,x0_all,conf);
    %print_png('img/sound_field_wfs_25d_with_all_sources.png');

.. figure:: img/sound_field_wfs_25d_with_all_sources.png
   :align: center

   Image

Near-Field Compensated Higher Order Ambisonics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the following we will simulate the field of a virtual plane wave with
a frequency of 800 Hz traveling into the direction (0 -1 0), synthesized
with 2.5D |NFC-HOA|.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.dimension = '2.5D';
    % sound_field_mono_nfchoa(X,Y,Z,xs,src,f,conf);
    sound_field_mono_nfchoa([-2 2],[-2 2],0,[0 -1 0],'pw',800,conf);
    %print_png('img/sound_field_nfchoa_25d.png');

.. figure:: img/sound_field_nfchoa_25d.png
   :align: center

   Sound pressure of a monochromatic plane wave synthesized by 2.5D |NFC-HOA|. The
   plane wave has a frequency of 800 Hz and is traveling into the direction
   (0,-1,0).

Local Wave Field Synthesis
~~~~~~~~~~~~~~~~~~~~~~~~~~

In |NFC-HOA| the aliasing frequency in a small region inside the listening
area can be increased by limiting the used order. A similar outcome can
be achieved in |WFS| by applying so called local Wave Field Synthesis. In
this case the original loudspeaker array is driven by |WFS| to create a
virtual loudspeaker array consisting of focused sources which can then
be used to create the desired sound field in a small area. The settings
are the same as for |WFS|, but a new struct ``conf.localsfs`` has to be filled
out, which for example provides the settings for the desired position
and form of the local region with higher aliasing frequency, have a look
into ``SFS_config.m`` for all possible settings.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.resolution = 1000;
    conf.dimension = '2D';
    conf.secondary_sources.geometry = 'box';
    conf.secondary_sources.number = 4*56;
    conf.secondary_sources.size = 2;
    conf.localsfs.vss.size = 0.4;
    conf.localsfs.vss.center = [0 0 0];
    conf.localsfs.vss.geometry = 'circular';
    conf.localsfs.vss.number = 56;
    % sound_field_mono_localwfs(X,Y,Z,xs,src,f,conf);
    sound_field_mono_localwfs([-1 1],[-1 1],0,[1.0 -1.0 0],'pw',7000,conf);
    axis([-1.1 1.1 -1.1 1.1]);
    %print_png('img/sound_field_localwfs_2d.png');

.. figure:: img/sound_field_localwfs_2d.png
   :align: center

   Sound pressure of a monochromatic plane wave synthesized by 2D local |WFS|. The
   plane wave has a frequency of 7000 Hz and is traveling into the direction
   (1,-1,0). The local |WFS| is created by using focused sources to create a
   virtual circular loudspeaker array in he center of the actual loudspeaker
   array.

Stereo
~~~~~~

The Toolbox includes not only |WFS| and |NFC-HOA|, but also some generic
sound field functions that are doing only the integration of the driving
signals of the single secondary sources to the resulting sound field.
With these function you can for example easily simulate a stereophonic
setup. In this example we set the
``conf.plot.normalisation = 'center';`` configuration manually as the
amplitude of the sound field is too low for the default ``'auto'``
setting to work.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.plot.normalisation = 'center';
    x0 = [-1 2 0 0 -1 0 1;1 2 0 0 -1 0 1];
    % [P,x,y,z] = sound_field_mono(X,Y,Z,x0,src,D,f,conf)
    sound_field_mono([-2 2],[-1 3],0,x0,'ps',[1 1],800,conf)
    %print_png('img/sound_field_stereo.png');

.. figure:: img/sound_field_stereo.png
   :align: center

   Sound pressure of a monochromatic phantom source generated by stereophony.
   The phantom source has a frequency of 800 Hz and is placed at (0,2,0) by
   amplitude panning.

Simulate time snapshots of sound fields
---------------------------------------

With the files in the folder ``SFS_time_domain`` you can simulate snapshots in time
of an impulse originating from your |WFS| or |NFC-HOA| system.

In the following we will create a snapshot in time after 200 samples for
a broadband virtual point source placed at (0 2 0) m for 2.5D |NFC-HOA|.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.dimension = '2.5D';
    conf.plot.useplot = true;
    % sound_field_imp_nfchoa(X,Y,Z,xs,src,t,conf)
    [p,x,y,z,x0] = sound_field_imp_nfchoa([-2 2],[-2 2],0,[0 2 0],'ps',200,conf);
    %print_png('img/sound_field_imp_nfchoa_25d.png');

.. figure:: img/sound_field_imp_nfchoa_25d.png
   :align: center

   Sound pressure of a broadband impulse point source synthesized by 2.5D
   |NFC-HOA|. The point source is placed at (0,2,0) m and the time snapshot is
   shown 200 samples after the first secondary source was active.

The output can also be plotted in dB by setting ``conf.plot.usedb = true;``.
In this case the default color map is changed and a color bar is plotted
in the figure. For none dB plots no color bar is shown in the plots. In
these cases the color coding goes always from -1 to 1, with clipping of
larger values.

.. sourcecode:: matlab

    conf.plot.usedb = true;
    plot_sound_field(p,[-2 2],[-2 2],0,x0,conf);
    %print_png('img/sound_field_imp_nfchoa_25d_dB.png');

.. figure:: img/sound_field_imp_nfchoa_25d_dB.png
   :align: center

   Sound pressure in decibel of the same broadband impulse point source as in
   the figure above.

You could change the color map yourself doing the following before the
plot command.

.. sourcecode:: matlab

    conf.plot.colormap = 'jet'; % Matlab rainbow color map

If you want to simulate more than one virtual source, it is a good idea
to set the starting time of your simulation to start with the activity
of your virtual source and not with the secondary sources, which is the
default behavior. You can change this by setting
``conf.wfs.t0 = 'source'``.

.. sourcecode:: matlab

    conf.plot.useplot = false;
    conf.wfs.t0 = 'source';
    t_40cm = round(0.4/conf.c*conf.fs); % in samples
    [p_ps,~,~,~,x0_ps] = ...
        sound_field_imp_wfs([-2 2],[-2 2],0,[1.9 0 0],'ps',20+t_40cm,conf);
    [p_pw,~,~,~,x0_pw] = ...
        sound_field_imp_wfs([-2 2],[-2 2],0,[1 -2 0],'pw',20-t_40cm,conf);
    [p_fs,~,~,~,x0_fs] = ...
        sound_field_imp_wfs([-2 2],[-2 2],0,[0 -1 0 0 1 0],'fs',20,conf);
    plot_sound_field(p_ps+p_pw+p_fs,[-2 2],[-2 2],0,[x0_ps; x0_pw; x0_fs],conf)
    hold;
    scatter(0,0,'kx');   % origin of plane wave
    scatter(1.9,0,'ko'); % point source
    scatter(0,-1,'ko');  % focused source
    hold off;
    %print_png('sound_field_imp_multiple_sources_dB.png');

.. figure:: img/sound_field_imp_multiple_sources_dB.png
   :align: center

   Sound pressure in decibel of a boradband impulse plane wave, point source,
   and focused source synthesized all by 2.5D |WFS|. The plane wave is traveling
   into the direction (1,-2,0) and shown 31 samples before it starting point
   at (0,0,0). The point source is placed at (1.9,0,0) m and shown 71 samples
   after its start. The focused source is placed at (0,-1,0) m and shown 20
   samples after its start.

.. _sec-custom-grid:

Custom grid for sound field simulations
---------------------------------------

As stated earlier you can provide the sound field simulation functions a
custom grid instead of the ``[min max]`` ranges. Again, you can provide
it for one dimension, two dimensions, or all three dimensions.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.dimension = '3D';
    conf.secondary_sources.number = 225;
    conf.secondary_sources.geometry = 'sphere';
    conf.resolution = 100;
    conf.plot.normalisation = 'center';
    X = randi([-2000 2000],125000,1)/1000;
    Y = randi([-2000 2000],125000,1)/1000;
    Z = randi([-2000 2000],125000,1)/1000;
    sound_field_mono_wfs(X,Y,Z,[0 -1 0],'pw',800,conf);
    %print_png('img/sound_field_wfs_3d_xyz_custom_grid.png');
    conf.plot.usedb = true;
    conf.dimension = '2.5D';
    conf.secondary_sources.number = 64;
    conf.secondary_sources.geometry = 'circle';
    sound_field_imp_nfchoa(X,Y,0,[0 2 0],'ps',200,conf);
    %print_png('img/sound_field_imp_nfchoa_25d_dB_custom_grid.png');

.. figure:: img/sound_field_wfs_3d_xyz_custom_grid.png
   :align: center

   Sound pressure of a monochromatic point source synthesized by 3D |WFS|. The
   plane wave has a frequency of 800 Hz and is travelling into the direction
   (0,-1,0). The sound pressure is calculated only at the explicitly provided
   grid points.

.. figure:: img/sound_field_imp_nfchoa_25d_dB_custom_grid.png
   :align: center

   Sound pressure in decibel of a broadband impulse point source synthesized by
   2.5D |NFC-HOA|. The point source is placed at (0,2,0) m and a time snapshot
   after 200 samples of the first active secondary source is shown. The sound
   pressure is calculated only at the explicitly provided grid points.

Make binaural simulations of your systems
-----------------------------------------

If you have a set of |HRTF|\ s or |BRIR|\ s you can simulate the ear signals
reaching a listener sitting at a given point in the listening area for different
spatial audio systems.

In order to easily use different |HRTF| or |BRIR| sets the Toolbox uses the
`SOFA file format <http://sofaconventions.org>`_. In order to use it you have to
install the `SOFA API for Matlab/Octave
<https://github.com/sofacoustics/API_MO>`_ and run ``SOFAstart`` before you can
use it inside the SFS Toolbox. If you are looking for different |HRTF|\ s and
|BRIR|\ s, a large set of different impulse responses is available:
http://www.sofaconventions.org/mediawiki/index.php/Files.

The files dealing with the binaural simulations are in the folder
``SFS_binaural_synthesis``. Files dealing with |HRTF|\ s and |BRIR|\ s are in
the folder ``SFS_ir``. If you want to extrapolate your |HRTF|\ s to plane waves
you may also want to have a look in the folder ``SFS_HRTF_extrapolation``.

In the following we present some examples of binaural simulations. For their
auralization an anechoic recording of a cello is used, which can be downloaded
from `anechoic\_cello.wav
<https://dev.qu.tu-berlin.de/projects/twoears-database/repository/revisions/master/raw/stimuli/anechoic/instruments/anechoic_cello.wav>`__.

Binaural simulation of arbitrary loudspeaker arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: img/tu_berlin_hrtf.jpg
   :align: center

   Setup of the |KEMAR| and a loudspeaker during a |HRTF| measurement.

If you use an |HRTF| data set, it has the advantage that it was recorded in
anechoic conditions and the only parameter that matters is the relative position
of the loudspeaker to the head during the measurement.  This advantage can be
used to create every possible loudspeaker array you can imagine, given that the
relative locations of all loudspeakers are available in the |HRTF| data set. The
above picture shows an example of a |HRTF| measurement. You can download the
corresponding `QU_KEMAR_anechoic_3m.sofa`_ |HRTF| set, which we can directly use
with the Toolbox.

.. _QU_KEMAR_anechoic_3m.sofa: https://github.com/sfstoolbox/data/raw/master/HRTFs/QU_KEMAR_anechoic_3m.sofa

The following example will load the |HRTF| data set and extracts a single
impulse response for an angle of 30° from it. If the desired angle of
30° is not available, a linear interpolation between the next two
available angles will be applied. Afterwards the impulse response will
be convolved with the cello recording by the ``auralize_ir()`` function.

.. sourcecode:: matlab

    conf = SFS_config;
    hrtf = SOFAload('QU_KEMAR_anechoic_3m.sofa');
    ir = get_ir(hrtf,[0 0 0],[0 0],[rad(30) 0 3],'spherical',conf);
    cello = wavread('anechoic_cello.wav');
    sig = auralize_ir(ir,cello,1,conf);
    sound(sig,conf.fs);

To simulate the same source as a virtual point source synthesized by |WFS|
and a circular array with a diameter of 3 m, you have to do the
following.

.. sourcecode:: matlab

    conf = SFS_config;
    conf.secondary_sources.size = 3;
    conf.secondary_sources.number = 56;
    conf.secondary_sources.geometry = 'circle';
    conf.dimension = '2.5D';
    hrtf = SOFAload('QU_KEMAR_anechoic_3m.sofa');
    % ir = ir_wfs(X,phi,xs,src,hrtf,conf);
    ir = ir_wfs([0 0 0],pi/2,[0 3 0],'ps',hrtf,conf);
    cello = wavread('anechoic_cello.wav');
    sig = auralize_ir(ir,cello,1,conf);

If you want to use binaural simulations in listening experiments, you should not
only have the |HRTF| data set, but also a corresponding headphone compensation
filter, which was recorded with the same dummy head as the |HRTF|\ s and the
headphones you are going to use in your test.  For the |HRTF|\ s we used in the
last example and the AKG K601 headphones you can download
`QU_KEMAR_AKGK601_hcomp.wav`_.  If you want to redo the last simulation with
headphone compensation, just add the following lines before calling
``ir_wfs()``.

.. _QU_KEMAR_AKGK601_hcomp.wav: https://raw.githubusercontent.com/sfstoolbox/data/master/headphone_compensation/QU_KEMAR_AKGK601_hcomp.wav

.. sourcecode:: matlab

    conf.ir.usehcomp = true;
    conf.ir.hcompfile = 'QU_KEMAR_AKGK601_hcomp.wav';
    conf.N = 4096;

The last setting ensures that your impulse response will be long enough
for convolution with the compensation filter.

Binaural simulation of a real setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: img/university_rostock_loudspeaker_array.jpg
   :align: center

   Boxed shaped loudspeaker array at the University Rostock.

Besides simulating arbitrary loudspeaker configurations in an anechoic space,
you can also do binaural simulations of real loudspeaker setups.  In the
following example we use |BRIR|\ s from the 64-channel loudspeaker array of the
University Rostock as shown in the panorama photo above.  The |BRIR|\ s and
additional information on the recordings are available for download, see
`doi:10.14279/depositonce-87.2`_.  For such a measurement the |SOFA| file format
has the advantage to be able to include all loudspeakers and head orientations
in just one file.

.. _doi:10.14279/depositonce-87.2: http://dx.doi.org/10.14279/depositonce-87.2

.. sourcecode:: matlab

    conf = SFS_config;
    brir = 'BRIR_AllAbsorbers_ArrayCentre_Emitters1to64.sofa';
    conf.secondary_sources.geometry = 'custom';
    conf.secondary_sources.x0 = brir;
    conf.N = 44100;
    ir = ir_wfs([0 0 0],0,[3 0 0],'ps',brir,conf);
    cello = wavread('anechoic_cello.wav');
    sig = auralize_ir(ir,cello,1,conf);

In this case, we don't load the |BRIR|\ s into the memory with
``SOFAload()`` as the file is too large. Instead, we make use of the
ability that |SOFA| can request single impulse responses from the file by
just passing the file name to the ``ir_wfs()`` function. In addition, we
have to set ``conf.N`` to a reasonable large value as this determines
the length of the impulse response ``ir_wfs()`` will return, which has
to be larger as for the anechoic case as it should now include the room
reflections. Note, that the head orientation is chosen to be ``0``
instead of ``pi/2`` as in the |HRTF| examples due to a difference in the
orientation of the coordinate system of the |BRIR| measurement.

Frequency response of your spatial audio system
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Binaural simulations are also a nice way to investigate the frequency
response of your reproduction system. The following code will
investigate the influence of the pre-equalization filter in |WFS| on the
frequency response. For the red line the pre-filter is used and its
upper frequency is set to the expected aliasing frequency of the system
(above these frequency the spectrum becomes very noise as you can see in
the figure).

.. sourcecode:: matlab

    conf = SFS_config;
    conf.ir.usehcomp = false;
    conf.wfs.usehpre = false;
    hrtf = dummy_irs(conf);
    [ir1,x0] = ir_wfs([0 0 0],pi/2,[0 2.5 0],'ps',hrtf,conf);
    conf.wfs.usehpre = true;
    conf.wfs.hprefhigh = aliasing_frequency(x0,conf);
    ir2 = ir_wfs([0 0 0],pi/2,[0 2.5 0],'ps',hrtf,conf);
    [a1,p,f] = easyfft(norm_signal(ir1(:,1)),conf);
    a2 = easyfft(norm_signal(ir2(:,1)),conf);
    figure;
    figsize(540,404,'px');
    semilogx(f,20*log10(a1),'-b',f,20*log10(a2),'-r');
    axis([10 20000 -80 -40]);
    set(gca,'XTick',[10 100 250 1000 5000 20000]);
    legend('w/o pre-filter','w pre-filter');
    xlabel('frequency / Hz');
    ylabel('magnitude / dB');
    %print_png('img/impulse_response_wfs_25d.png');

.. figure:: img/impulse_response_wfs_25d.png
   :align: center

   Sound pressure in decibel of a point source synthesized by 2.5D |WFS| for
   different frequencies. The 2.5D |WFS| is performed with and without the
   pre-equalization filter. The calculation is performed in the time domain.

The same can be done in the frequency domain, but in this case we are
not able to set a maximum frequency of the pre-equalization filter and
the whole frequency range will be affected.

.. sourcecode:: matlab

    freq_response_wfs([0 0 0],[0 2.5 0],'ps',conf);
    axis([10 20000 -40 0]);
    %print_png('img/impulse_response_wfs_25d_mono.png');

.. figure:: img/impulse_response_wfs_25d_mono.png
   :align: center

   Sound pressure in decibel of a point source synthesized by 2.5D |WFS| for
   different frequencies. The 2.5D |WFS| is performed only with the
   pre-equalization filter active at all frequencies. The calculation is
   performed in the frequency domain.

Using the SoundScape Renderer with the SFS Toolbox
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to binaural synthesis, you may want to apply dynamic binaural
synthesis, which means you track the position of the head of the listener and
switches the used impulse responses regarding the head position. The `SoundScape
Renderer (SSR)`_ is able to do this. The SFS Toolbox provides functions to
generate the needed wav files containing the impulse responses used by the
SoundScape Renderer. All functions regarding the |SSR| are stored in folder
``SFS_ssr``.

.. sourcecode:: matlab

    conf = SFS_config;
    brs = ssr_brs_wfs(X,phi,xs,src,hrtf,conf);
    wavwrite(brs,fs,16,'brs_set_for_SSR.wav');

.. _SoundScape Renderer (SSR): http://spatialaudio.net/ssr/

Small helper functions
----------------------

The Toolbox provides you also with a set of useful small functions. Here the
highlights are angle conversion with ``rad()`` and ``deg()``, |FFT| calculation
and plotting ``easyfft()``, rotation matrix ``rotation_matrix()``, multi-channel
fast convolution ``convolution()``, nearest neighbour search
``findnearestneighbour()``, even or odd checking ``iseven()`` ``isodd()``,
spherical Bessel functions ``sphbesselh()`` ``sphbesselj()`` ``sphbessely()``.

Plotting with Matlab/Octave or gnuplot
--------------------------------------

The Toolbox provides you with a function for plotting your simulated sound
fields (``plot_sound_field()``) and adding loudspeaker symbols to the figure
(``draw_loudspeakers()``). If you have gnuplot installed, you can use the
functions ``gp_save_matrix()`` and ``gp_save_loudspeakers()`` to save your data
in a way that it can be used with gnuplot. An example use case can be found `at
this plot of a plane wave`_ which includes the Matlab/Octave code to generate
the data and the gnuplot script for plotting it.

.. _at this plot of a plane wave: https://github.com/hagenw/phd-thesis/tree/master/02_theory_of_sound_field_synthesis/fig2_04

.. vim: filetype=rst spell:
