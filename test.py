import numpy as np
import matplotlib.pyplot as plt

# ----------- Helper function -----------
def hex32_to_complex(h):
    """Convert 32-bit hex string into signed int16 real and imag, return complex number."""
    val = int(h, 16)
    r = (val >> 16) & 0xFFFF
    i = val & 0xFFFF
    # Convert from unsigned to signed
    if r >= 2**15:
        r -= 2**16
    if i >= 2**15:
        i -= 2**16
    return np.complex64(r + 1j*i)

# ----------- Read FFT Expected File -----------
fft_complex = []

with open("fft_expected.txt", "r") as f:
    for line in f:
        h = line.strip()
        fft_complex.append(hex32_to_complex(h))

fft_complex = np.array(fft_complex, dtype=np.complex64)

# ----------- Compute magnitude -----------
magnitude = np.abs(fft_complex)

# ----------- Frequency axis -----------
N = len(magnitude)           # e.g., 512
fs = 8000                    # Sampling rate used when generating the input
freqs = np.fft.fftfreq(N, d=1/fs)

# ----------- Find dominant frequency -----------
max_index = np.argmax(magnitude[:N//2])   # only positive frequencies
dominant_frequency = freqs[max_index]
print("Dominant Frequency:", dominant_frequency, "Hz")

# ----------- Plot -----------
plt.figure(figsize=(10,5))
plt.plot(freqs[:N//2], magnitude[:N//2])
plt.title("FFT Magnitude Spectrum")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.grid(True)
plt.show()
