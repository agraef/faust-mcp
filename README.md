
# faust-mcp

This package provides a [Pd][pd] abstraction mcp.pd (along with some helper abstractions and externals) which lets you control your [Faust][] instruments and effects more conveniently with control surfaces utilizing the Mackie Control Protocol (MCP).

To use the abstraction, you'll need:

- [Pd][pd] by Miller Puckette, or [Purr Data][purr-data] by Jonathan Wilkes; mcp.pd was developed on the latter, which is a more user-friendly Pd version, but should also work with the former, "vanilla" Pd version.

- An MCP-compatible device, such as the [Mackie MCU][] or the Behringer [X-Touch][]. The abstraction has been tested on the X-Touch, the X-Touch ONE, the X-Touch Mini (in MCP mode), and the Korg nanoKONTROL2 (in Cubase/MCP mode). Note that you *can* use mcp.pd without a real MCP device, but that defeats the purpose, since the main idea behind the patch is to facilitate control of your Faust dsps with real hardware.

- The latest versions of [pd-pure][] and [pd-faust][] must be installed and enabled in Pd. These Pd extensions are part of the [Pure][] programming system. Ready-made packages are available for Linux (Arch and Ubuntu), Mac and Windows, please check the Pure website for details. For the [Purr Data][purr-data] flavor of Pd, see https://agraef.github.io/purr-data/#jgu-packages.

- To compile your Faust sources, you'll also need gcc, the GNU C/C++ compiler (readily available on most systems), and Grame's Faust compiler, which can be found at http://faust.grame.fr/. Grame only distributes the compiler sources, but ready-made packages are available for Linux (Arch and Ubuntu), Mac (via MacPorts) and Windows, please check the following Wiki page for details: https://github.com/agraef/pure-lang/wiki/Faust#getting-faust

[pd]: http://puredata.info/
[purr-data]: https://agraef.github.io/purr-data/
[pd-faust]: https://agraef.github.io/pure-docs/pd-faust.html
[pd-pure]: https://agraef.github.io/pure-docs/pd-pure.html
[Faust]: http://faust.grame.fr/
[Pure]: https://agraef.github.io/pure-lang/
[Mackie MCU]: https://mackie.com/products/mcu-pro-and-xt-pro
[X-Touch]: https://www.musictribe.com/Categories/Behringer/Computer-Audio/Desktop-Controllers/X-TOUCH/p/P0B1X

## Description

The purpose of this abstraction is to equip pd-faust applications with an interface to MCP control surfaces. Basically, it is a specialized MIDI mapper which translates MCP to standard MIDI control changes and vice versa. This allows the MCP device to be used to control your Faust dsps via MIDI. No manual setup is required; once the device is connected to Pd (see below), the mcp.pd patch keeps track of all the MIDI controls in all Faust dsps and configures itself accordingly in a fully automatic fashion.

The faders and encoders of the MCP device are linked to the MIDI controls of your Faust dsps, so moving them changes the controls of the dsp accordingly. Conversely, changing the controls in the Pd GUI sets the controls of the device (if it supports feedback). Note that to make this work, the Faust controls to be operated need to be assigned to corresponding MIDI controllers; *only* controls with MIDI bindings will show on the MCP surface. The [pd-faust][] manual explains how to create such bindings, and you can also look at the included Faust examples to see how this is done.

The controls are organized into banks of eight faders and encoders. The abstraction provides as many banks as needed to represent all MIDI controls of all Faust dsps. The usual bank and channel controls on the MCP device can be used to switch between different banks as needed, so that all controls with MIDI bindings become accessible.

Scribble strips are also supported; they will show the name of the Faust units and controls assigned to each fader and encoder, or display the corresponding parameter values. Also, if you're using the included midiosc.pd abstraction, the transport keys of the device can be used to control playback. There are a number of other useful features like these, which will be described in more detail below.

## Usage

This guide assumes that you already have pd-pure and pd-faust up and running, and know how to use pd-faust in Pd.

Some examples are included for illustration purposes and to help you get up and running quickly. You can run these straight from the source directory. The sources also include a few sample Faust instruments and effects in the dsp subdirectory. Before running any of the examples, you'll have to compile these with the Faust compiler. A Makefile is included, so you can just type `make` in the dsp folder to do this.

### Device connections

The provided examples have all been set up so that the MCP device is expected to be connected to Pd's *second* MIDI port, so you'll have to configure your Pd MIDI connections accordingly. E.g., on Linux, make sure that Pd is configured for (at least) two MIDI input and output ports, and use a patchbay utility like QjackCtl to connect your MCP device to Pd's second MIDI input *and* output. Note that the incoming connection is used to transmit the data from the device to the mcp abstraction, while the outgoing connection transmits feedback data from the abstraction back to the device.

You want to have these connections set up beforehand, so that the mcp.pd patch can initialize the fader positions and scribble strips of the device when the patch gets loaded (i.e., at loadbang time).

### Running the examples

Once you've compiled the Faust sources and set up the MIDI connections, you can open the simple.pd or synth.pd example in Pd and kick the tires. Both examples contain some Faust units and the corresponding pd-faust GUIs. The included mcp instance will display the scribble strips for the first bank of controls; if your MCP device is connected properly and has a scribble strip display, the strips will also be shown on the device. Also, if your device has motor faders, launching the patch will set them to the initial values of the corresponding Faust controls. When you move the faders and/or encoders of your MCP device, you should see the controls change accordingly in the GUIs of the `faust~` objects in the patch.

The synth.pd example also includes a modified version of pd-faust's midiosc player, which can be used for MIDI file playback and will be wired up to the MCP device, so that you can use the transport controls of the device to start and stop playback. The simple.pd example only provides live MIDI input; connect your MIDI keyboard (or MIDI player app) to Pd's first MIDI input port and start jamming.

### Using the abstraction

To use the abstraction in your own patches, it's enough to copy the mcp folder to the directory containing your patch. If you prefer, you can also install the abstraction by dropping the mcp folder into one of the locations on Pd's library search path, such as ~/.pd-externals on Linux; please check your local Pd documentation for details.

To insert an instance of the abstraction into your patch, create an object (Ctrl+1) and type `mcp` followed by the MIDI port number to which the MCP device is connected, e.g.:

    mcp 2

This will connect to the device on Pd's second MIDI port. In principle any of Pd's MIDI ports can be used there (if you don't specify any then port 1 will be used by default). But you should make sure that live MIDI input to the Faust dsps is kept separate from the MCP data, because MCP uses note and control data in its own peculiar way, which will sound funny if played back by an instrument.

The abstraction shows a mirror of the scribble strips, as they will render on the MCP device, as well as some buttons and toggles in the top row which can be used to control the most essential functions. All these functions are also available using corresponding controls on the MCP device, as described in the next section; in the following list we give the equivalent MCP functions in parentheses.

- The first two bang controls, labeled "<" and ">", switch to the previous and next bank of eight faders, respectively. (MCP: bank left/right keys)

- The "value" toggle, when engaged, shows the current values of the controls in the top row of the scribble strips. (MCP: touch a fader, or push an encoder)

- The "dspname" toggle switches the scribble strips between showing the instance and the dsp name of the Faust unit. (MCP: F1 key)

- The "encoder" toggle switches between two alternative display styles ("fan" and "pan") for the encoder LED rings. Fan style (the default) shows an arc from 0 to the current value, while pan style shows just a single tick between min and max markers. (MCP: F2 key)

- The bang control on the right resets the internal state of the abstraction and redisplays the scribble strips. (MCP: F3 key)

## Controller functions

The primary purpose of the mcp abstraction is to take controller input from the faders and encoders of your device and map them to the corresponding MIDI control changes of the Faust units in your patch. It also does the reverse translation, providing feedback to the MCP device (moving the faders or lighting up LEDs) if you change the Faust controls in the patch.

In addition, the abstraction also offers various other useful functions, mostly accessible through special keys on the MCP device:

- **Bank changes:** The bank left/right buttons can be used to switch between different banks, and the channel left/right buttons move by one control at a time.

- **Scribble strips:** Instance/dsp and control names are shown in the scribble strips of the device, and touching the faders or pushing the encoders toggles the value display in the top line of each scribble strip.

- **Faust unit controls:** The rec and mute buttons toggle the record and active controls of the corresponding Faust dsp, and pressing the select button resets the controls to their initial values.

- **Display options:** The following options are assigned to some of the function keys of the MCP device: F1 switches the scribble strips between instance and dsp name of the Faust units; F2 switches the encoder style (i.e., the way the LED rings light up around the encoders); and F3 tells the abstraction to update its internal state and redisplay the scribble strips (which can be used to force an update of the display after edits).

- **Playback and transport:** When used with the included (modified) version of the pd-faust midiosc player, the transport controls will work as follows: the "rewind" key moves the playhead to the beginning of the MIDI file, "fast forward" moves it to the end; "stop" stops, and "play" toggles playback; "record" toggles the player's OSC automation recording; "cycle" toggles the player's loop function; and the big jog wheel and the cursor left/right keys move the playhead in smaller and larger increments, respectively. In addition, the function keys F4, F5 and F6 are assigned to some special OSC recording functions ("save", "abort" and "clear"). Please check the description of the midosc abstraction in the [pd-faust][] documentation for the meaning of these operations.

- **Timecode:** When used with the midiosc player, the timecode display shows the time (in h/m/s/tenths of seconds) of the current playhead position.

Note that there's no musical time display right now. Implementing this would require non-trivial changes in pd-faust itself, as its built-in sequencer currently doesn't provide musical timing information to the player abstraction.

Obviously, some of these functions may or may not be available depending on the MCP device that you have. Both Mackie MCU and X-Touch should enable all features, but some cheaper MCP devices may not offer transport or function keys, push encoders, fader touch detection, scribble strips, or a timecode display.
