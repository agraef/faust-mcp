
# faust-mcp

This package provides an abstraction mcp.pd (along with some helper abstractions and Pure externals) which interfaces pd-faust to Mackie MCU devices and compatible equipment such as Behringer's X-Touch (which was the actual device used for testing). Some examples showing its use are provided, as well as a suitably modified version of pd-faust's midiosc player, and some Faust dsp examples and MIDI files in the dsp and midi subdirectories.

NOTE: This package requires the latest versions of pd-pure and pd-faust, which are part of the Pure programming system. Packages for Linux systems (Arch and Ubuntu) are available, please see https://agraef.github.io/pure-lang/ for details.

## Description

The purpose of this abstraction is to equip pd-faust applications with an interface to control surfaces utilizing the Mackie Control Protocol (MCP). The MCP device can then be used to control your Faust dsps via MIDI. No manual setup is required; once the device is connected to Pd (see below), the mcp.pd patch keeps track of all the MIDI controls in all Faust dsps and configures itself accordingly in a fully automatic fashion.

The faders and encoders of the MCP device are linked to the MIDI controls of your Faust dsps, so moving them changes the controls of the dsp accordingly. Conversely, changing the controls in the Pd GUI sets the controls of the device (if it supports feedback). Scribble strips are supported as well; they will show the name of the controls assigned to each fader and encoder, and also display the corresponding parameter values. If you're using the included midiosc.pd abstraction, the transport keys of the device can be used to control playback.

## Connection Setup

The first (and only) creation argument of the mcp abstraction denotes the Pd MIDI port number to which the control surface is connected. Port 1 is the default if none is specified, but we recommend to always specify a port number other than 1 there and connect your MCP device to that port, so that you can still connect other MIDI gear and applications to port 1 without having these get mixed up with the MCP input and output. The provided examples have all been set up so that the MCP device is to be connected to port 2.

Normally, you want to have the connections set up beforehand, so that the mcp.pd patch can initialize the fader positions and scribble strips of the device when the patch gets loaded (i.e., at loadbang time).

## Features

- The abstraction implements controller input and feedback via the faders and encoders of your device. The bank/channel left/right buttons can be used to switch between different banks of faders -- the patch provides as many banks as needed to represent the MIDI controls of your Faust dsps.

- Instance/unit and control names are shown in the scribble strips of the device, and touching the faders or pushing the encoders toggles the value display in the top line of each scribble strip. The scribble strips are also shown in the abstraction, in case your MCP device doesn't have a display.

- When used with the included (modified) version of the pd-faust midiosc player, the transport controls will work as follows: the "rewind" key moves the playhead to the beginning of the MIDI file, "fast forward" moves it to the end; "stop" stops, and "play" toggles playback; "record" toggles the player's OSC automation recording; "cycle" toggles the player's loop function; and the big jog wheel and the cursor left/right keys move the playhead in smaller and larger increments, respectively.

- When used with the midiosc player, the timecode display shows the time (in h/m/s/tenths of seconds) of the current playhead position.

- The abstraction also has bindings for the following function keys on the MCP device: F1 switches the scribble strips between instance and unit name of the Faust dsps; F2 switches the encoder display style (i.e., the way the LEDs light up around the encoders); F3 updates the internal state and redisplays the scribble strips after changes. These functions are also available through the "unitname" and "encoder" toggles and the "reset" bang control shown in the abstraction.

Obviously, some of these features may or may not work depending on the MCP device that you have. Both Mackie MCU and X-Touch should enable all features, but some cheaper MCP devices may not offer transport and function keys, push encoders, fader touch detection, scribble strips, or a timecode display.

## TODO

- At present it's necessary to manually invoke "reset" (F3) to update the MCP state after changes which affect the collection of loaded Faust units. This should preferably be automatic, but pd-faust currently doesn't offer any notifications about such changes.

- There's no musical time display right now. This requires non-trivial changes in pd-faust itself, as its built-in sequencer currently doesn't provide musical timing information to the player abstraction.

- The patch should maybe be rewritten to use OSC instead of MIDI for communicating with the Faust dsps, so that all controls become accessible. But then again, restricting access to controls with MIDI bindings gives you better control over which parameters should be visible on the control surface.
