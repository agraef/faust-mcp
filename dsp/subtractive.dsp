declare name "subtractive";
declare nvoices "16";

import("stdfaust.lib");

process = os.sawtooth(freq)
  : ((env,freq,_) : filter) : *(env * gain)
  : (*(vol:dezipper(0.99))  : sp.panner(pan:dezipper(0.99)))
with {
  env = gate : en.adsr(attack, decay, sustain, release);
  filter(env,freq) =
    lowpass(env*res, ma.fmax(1/cutoff, env)*freq*cutoff);
  dezipper(c) = *(1-c) : +~*(c);
};

// control variables
attack	= hslider("[1] attack [midi:ctrl 1]", 0.01, 0, 1, 0.001); // sec
decay	= hslider("[2] decay [midi:ctrl 2]", 0.3, 0, 1, 0.001);	  // sec
sustain = hslider("[3] sustain [midi:ctrl 3]", 0.5, 0, 1, 0.01);  // %
release = hslider("[4] release [midi:ctrl 4]", 0.2, 0, 1, 0.001); // sec

res	= hslider("[5] resonance (dB) [midi:ctrl 5]", 3, 0, 20, 0.1);
cutoff	= hslider("[6] cutoff (harmonic) [midi:ctrl 6]", 6, 1, 20, 0.1);

vol	= hslider("[7] vol [midi:ctrl 7]", 0.3, 0, 1, 0.01);	// %
pan	= hslider("[8] pan [midi:ctrl 8]", 0.5, 0, 1, 0.01);	// %

// voice controls
freq	= nentry("freq", 440, 20, 20000, 1);	        // Hz
gain	= nentry("gain", 1, 0, 10, 0.01);	        // %
gate	= button("gate");			        // 0/1

// Tweaked Butterworth filter by David Werner and Patrice Tarrabia,
// see http://www.musicdsp.org/showArchiveComment.php?ArchiveID=180.
lowpass(res,freq) = f : (+ ~ g) : *(a) with {
  f(x)	= a0*x+a1*x'+a2*x'';
  g(y)	= -b1*y-b2*y';
  // calculate the filter coefficients
  a	= 1/ba.db2linear(0.5*res);
  c	= 1/tan(ma.PI*(freq/ma.SR));
  c2	= c*c;
  r	= 1/ba.db2linear(2*res);
  q	= sqrt(2)*r;
  a0	= 1/(1+(q*c)+(c2));
  a1	= 2*a0;
  a2	= a0;
  b1	= 2*a0*(1-c2);
  b2	= a0*(1-q*c+c2);
};
