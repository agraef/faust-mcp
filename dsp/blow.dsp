
import("stdfaust.lib");

declare nvoices "16";

fc = hslider("/freq", 440, 20, 20000, 0.01);
gain = hslider("/gain", 1, 0, 10, 0.01);
vol = hslider("/h:/v:/volume[midi:ctrl 6]", 3, 0, 10, 0.01);
gate = button("/gate");
bw = hslider("/h:/v:/bandwidth[midi:ctrl 5]", 0.3, 0, 10, 0.01)/100;

a = hslider("/h:/v:adsr/[1]attack[midi:ctrl 1]", 0.01, 0, 1, 0.001);	// sec
d = hslider("/h:/v:adsr/[2]decay[midi:ctrl 2]", 0.3, 0, 1, 0.001);	// sec
s = hslider("/h:/v:adsr/[3]sustain[midi:ctrl 3]", 0.5, 0, 1, 0.01);	// %
r = hslider("/h:/v:adsr/[4]release[midi:ctrl 4]", 0.2, 0, 1, 0.001);	// sec

random = +(12345) ~*(1103515245) ;
noise = random/2147483647.0;

process = noise : fi.bandpass(1, fl, fu)*en.adsr(a,d,s,r,gate)*gain*vol*100 with {
  fl = fc-bw*fc/2; fu = fc+bw*fc/2;
};
