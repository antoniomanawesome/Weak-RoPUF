import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load CSV
df = pd.read_csv("responses.csv")

# Extract only RO counts (columns starting with "count_")
count_cols = [c for c in df.columns if c.startswith("count_")]
counts = df[count_cols].values

# Convert 128 counts → 128-bit response per row
bit_responses = (counts > np.median(counts, axis=1, keepdims=True)).astype(int)

# --- RELIABILITY ---
# Compare each response with the FIRST response of same condition
conditions = df['condition'].unique()
for cond in conditions:
    cond_rows = df[df['condition'] == cond]
    bits = bit_responses[df['condition'] == cond]

    # First sample = golden response
    golden = bits[0]
    hd = np.sum(bits != golden, axis=1)

    print(f"\nReliability for condition = {cond}")
    print("Per-trial Hamming distances:", hd)

    # Plot reliability histogram
    plt.figure()
    plt.hist(hd, bins=20)
    plt.title(f"Reliability Hamming Distance ({cond})")
    plt.xlabel("Bit flips vs golden")
    plt.ylabel("Count")
    plt.show()

# --- UNIFORMITY ---
uniformity = np.mean(bit_responses, axis=1)
print("\nUniformity for each trial:", uniformity)

plt.figure()
plt.hist(uniformity, bins=20)
plt.title("Uniformity Distribution")
plt.xlabel("Fraction of 1s")
plt.ylabel("Count")
plt.show()
