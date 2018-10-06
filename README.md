
# faust-mcp

This package provides an abstraction mcp.pd (along with some helper abstractions and Pure externals) which interfaces [pd-faust][] to Mackie MCU devices and compatible equipment such as Behringer's X-Touch (which was the actual device used for testing).

To use the abstraction, you'll need to have the latest versions of [pd-pure][] and [pd-faust][] installed and enabled in Pd. These extensions are part of the Pure programming system. Ready-made packages are available for Linux (Arch and Ubuntu), Mac and Windows, please see https://agraef.github.io/pure-lang/ for details. For the "Purr Data" flavor of Pd, suitable packages can be found at https://agraef.github.io/purr-data/#jgu-packages. This guide assumes that you already have pd-pure and pd-faust up and running, and know how to use pd-faust in Pd.

[pd-faust]: https://agraef.github.io/pure-docs/pd-faust.html
[pd-pure]: https://agraef.github.io/pure-docs/pd-pure.html

To compile your Faust sources, you'll also need Grame's Faust compiler, which can be found at http://faust.grame.fr/. Grame only distributes the compiler sources, but ready-made packages are available for Linux (Arch and Ubuntu), Mac (via MacPorts) and Windows, please check the following Wiki page for details:

https://github.com/agraef/pure-lang/wiki/Faust#getting-faust

## Description

The purpose of this abstraction is to equip pd-faust applications with an interface to control surfaces utilizing the Mackie Control Protocol (MCP). The MCP device can then be used to control your Faust dsps via MIDI. No manual setup is required; once the device is connected to Pd (see below), the mcp.pd patch keeps track of all the MIDI controls in all Faust dsps and configures itself accordingly in a fully automatic fashion.

The faders and encoders of the MCP device are linked to the MIDI controls of your Faust dsps, so moving them changes the controls of the dsp accordingly. Conversely, changing the controls in the Pd GUI sets the controls of the device (if it supports feedback). Note that to make this work, the Faust controls to be operated need to be assigned to corresponding MIDI controllers; *only* controls with MIDI bindings will show on the MCP surface. The [pd-faust][] manual explains how to create such bindings, and you can also look at the included Faust examples to see how this is done.

Scribble strips are also supported; they will show the name of the controls assigned to each fader and encoder, and also display the corresponding parameter values. Also, if you're using the included midiosc.pd abstraction, the transport keys of the device can be used to control playback.

## Usage

Some examples are included which can be run straight away from the source directory. A few sample Faust instruments and effects can be found in the dsp directory. Before running any of the examples, you'll have to compile these; a Makefile is included, so you can just type `make` in the dsp folder to do this.

### Device connections

The provided examples have all been set up so that the MCP device is expected to be connected to Pd's *second* MIDI port, so you'll have to configure your Pd MIDI connections accordingly. E.g., on Linux, make sure that Pd is configured for (at least) two MIDI input and output ports, and use a patchbay utility like QjackCtl to connect your MCP device to Pd's second MIDI input *and* output. Note that the incoming connection is used to transmit the data from the device to the mcp abstraction, while the outgoing connection transmits feedback data from the abstraction back to the device.

You want to have these connections set up beforehand, so that the mcp.pd patch can initialize the fader positions and scribble strips of the device when the patch gets loaded (i.e., at loadbang time).

### Running the examples

Once you've compiled the Faust sources and set up the MIDI connections, you can open the simple.pd or synth.pd example in Pd and kick the tires. Both examples contain some Faust units and the corresponding pd-faust GUIs. The included mcp instance will display the scribble strips for the first bank of controls; if your MCP device is connected properly and has a scribble strip display, the strips will also be shown on the device. Also, if your device has motor faders, launching the patch will set them to the initial values of the corresponding Faust controls. When you move the faders and/or encoders of your MCP device, you should see the controls change accordingly in the GUIs of the `faust~` objects in the patch.

The synth.pd example also includes a modified version of pd-faust's midiosc player, which can be used for MIDI file playback and will be wired up to the MCP device, so that you can use the transport controls of the device to start and stop playback. The simple.pd example only provides live MIDI input; connect your MIDI keyboard (or MIDI player app) to Pd's first MIDI input port and start jamming.

### Using the abstraction in your own patches

To use the abstraction in your own patches, it's enough to copy the mcp folder to the directory containing your patch. If you prefer, you can also install the abstraction by dropping the mcp folder into one of the locations on Pd's library search path, such as ~/.pd-externals on Linux; please check your local Pd documentation for details.

To insert an instance of the abstraction into your patch, create an object (Ctrl+1) and type `mcp` followed by the MIDI port number to which the MCP device is connected, e.g.:

    mcp 2

This will connect to the device on Pd's second MIDI port. In principle any of Pd's MIDI ports can be used there (if you don't specify any then port 1 will be used by default). But you should make sure that live MIDI input to the Faust dsps is kept separate from the MCP data, because MCP uses note and control data in its own peculiar way, which will sound funny if played back by an instrument.

## Features

The primary purpose of the mcp abstraction is to take controller input from the faders and encoders of your device and translate them to the corresponding MIDI control changes of the Faust units in your patch. It also provides feedback to the MCP device (moving the faders or lighting up LEDs) if you change the Faust controls directly in the patch.

In addition, the abstraction also offers the following features:

- **Bank changes:** The bank/channel left/right buttons can be used to switch between different banks of faders. The patch provides as many banks as needed to represent the MIDI controls of your Faust dsps.

- **Scribble strips:** Instance/unit and control names are shown in the scribble strips of the device, and touching the faders or pushing the encoders toggles the value display in the top line of each scribble strip. The scribble strips are also shown in the abstraction, in case your MCP device doesn't have a display.

- **Playback and transport:** When used with the included (modified) version of the pd-faust midiosc player, the transport controls will work as follows: the "rewind" key moves the playhead to the beginning of the MIDI file, "fast forward" moves it to the end; "stop" stops, and "play" toggles playback; "record" toggles the player's OSC automation recording; "cycle" toggles the player's loop function; and the big jog wheel and the cursor left/right keys move the playhead in smaller and larger increments, respectively.

- **Timecode:** When used with the midiosc player, the timecode display shows the time (in h/m/s/tenths of seconds) of the current playhead position.

- **Function keys:** The abstraction also has bindings for the following function keys on the MCP device: F1 switches the scribble strips between instance and unit name of the Faust dsps; F2 switches the encoder display style (i.e., the way the LEDs light up around the encoders); F3 tells the abstraction to update its internal state and redisplay the scribble strips after changes to the Faust dsps. These functions are also available through the "unitname" and "encoder" toggles and the "reset" bang control shown in the abstraction.

Obviously, some of these features may or may not be available depending on the MCP device that you have. Both Mackie MCU and X-Touch should enable all features, but some cheaper MCP devices may not offer transport or function keys, push encoders, fader touch detection, scribble strips, or a timecode display.

## TODO

- At present it's necessary to manually invoke "reset" (F3) to update the MCP state after changes which affect the collection of loaded Faust units. This should preferably be automatic, but pd-faust currently doesn't offer any notifications about such changes.

- There's no musical time display right now. This requires non-trivial changes in pd-faust itself, as its built-in sequencer currently doesn't provide musical timing information to the player abstraction.

- We might want to rewrite the patch to use OSC instead of MIDI for communicating with the Faust dsps, so that all controls become accessible. But then again, restricting access to controls with MIDI bindings gives you better control over which parameters should be visible on the control surface.
