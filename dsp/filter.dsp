
g = hslider("gain [midi:ctrl 7]", 0.5, 0, 2, 0.01);
a = hslider("a1 [midi:ctrl 1]", 0, -1, 1, 0.01);
b = hslider("b1 [midi:ctrl 2]", 0, -1, 1, 0.01);

process = F : (+ ~ G) : *(g) with {
  F(x) = x+a*x';
  G(y) = b*y;
};
