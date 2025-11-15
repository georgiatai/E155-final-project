import numpy as np

# -------------------------------
# Parameters
# -------------------------------
N = 512               # FFT points
BIT_WIDTH = 16        # input bit width
MAX_VAL = 2**15 - 1   # max 16-bit signed
MIN_VAL = -2**15      # min 16-bit signed

fs = 8000             # sampling frequency
f_note = 440          # desired note frequency (A4)

# -------------------------------
# Compute FFT bin for 440 Hz
# -------------------------------
k_bin = int(round(f_note * N / fs))
print(f"Desired frequency {f_note} Hz -> FFT bin {k_bin}")

# -------------------------------
# Generate sine wave aligned to FFT bin
# -------------------------------
n = np.arange(N)
x_real = np.sin(2 * np.pi * k_bin * n / N) * MAX_VAL
x_real = np.round(x_real).astype(np.int16)  # 16-bit signed
x_imag = np.zeros(N, dtype=np.int16)

# -------------------------------
# Write fft_input.txt (16-bit hex)
# -------------------------------
with open("fft_input.txt", "w") as f_in:
    for r in x_real:
        # Convert to unsigned 16-bit for hex representation
        r_hex = np.uint16(r) & 0xFFFF
        f_in.write(f"{r_hex:04x}\n")  # 4 hex digits = 16 bits

print("fft_input.txt generated (16-bit hex).")

# -------------------------------
# Compute FFT
# -------------------------------
x_complex = x_real + 1j*x_imag
X = np.fft.fft(x_complex)

X_real = np.round(np.real(X)).astype(np.int16)
X_imag = np.round(np.imag(X)).astype(np.int16)

# -------------------------------
# Write fft_expected.txt (32-bit hex: upper 16 = real, lower 16 = imag)
# -------------------------------
with open("fft_expected.txt", "w") as f_out:
    for r, i in zip(X_real, X_imag):
        r_hex = np.uint16(r) & 0xFFFF  # upper 16 bits
        i_hex = np.uint16(i) & 0xFFFF  # lower 16 bits
        combined = (r_hex << 16) | i_hex
        f_out.write(f"{combined:08x}\n")  # 8 hex digits = 32 bits

print("fft_expected.txt generated (32-bit hex: upper 16 real, lower 16 imag).")

# -------------------------------
# Optional: print first few samples
# -------------------------------
print("First 10 input samples (hex):")
for r in x_real[:10]:
    print(f"{np.uint16(r) & 0xFFFF:04x}")

print("First 10 FFT output samples (hex):")
for r, i in zip(X_real[:10], X_imag[:10]):
    combined = ((np.uint16(r) & 0xFFFF) << 16) | (np.uint16(i) & 0xFFFF)
    print(f"{combined:08x}")
