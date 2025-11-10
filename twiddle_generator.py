# python file that generates twiddle factor LUT for 512-point FFT

import math

N = 512
for k in range(N//2):
    c = math.cos(2*math.pi*k/N)
    s = math.sin(2*math.pi*k/N)
    c16 = int(round(c * 32767))
    s16 = int(round(s * 32767))
    print(f"assign twiddle_cos[{k}] = 16'h{c16 & 0xFFFF:04X};      assign twiddle_sin[{k}] = 16'h{s16 & 0xFFFF:04X}; // cos: {c:.6f}, sin:{s:.6f}") 
