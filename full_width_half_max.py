#full_width_half_max.py
#pulls in photon counting data file, processes and calculates FWHM, 
# and outputs raw data to .csv
#Michael Langford
#4-24-22

import numpy as np
import matplotlib.pyplot as plt

#pull in data
f = open('photon_count_4_22_22.dat', 'r')
lines = f.readlines()

#grab lines describing important data parameters
channels_per_curve__line = lines[2].strip()
ns_per_bin = float(lines[8].strip().split()[0])

#histogram bin counts start at line 10, pull them into separate array
counts = []
for line in lines[10:]:
    counts.append(int(line.strip().split()[0]))

counts = np.array(counts)

#calculate FWHM
max_count = np.max(counts)
half_max_count = 0.5*max_count

indices = np.where(counts > half_max_count)

min_index = indices[0][0]
max_index = indices[0][-1]

full_width_half_max = (max_index - min_index) * ns_per_bin

print("ns per bin:\t{} [ns]".format(ns_per_bin))
print("min_index:\t{}".format(min_index))
print("max_index:\t{}".format(max_index))
print("max_count:\t{}".format(max_count))
print("full_width_half_max:\t{} [ns]".format(full_width_half_max))

#print("sum: {}".format(np.sum(counts)))
#print("avg: {}".format(np.mean(counts)))

#meaningful data stops after 400 bins
stop_index = 400
time = np.arange(0, (stop_index*ns_per_bin), ns_per_bin)

#plot on log scale, adding small offset to prevent div/0
plt.plot(time, np.log10(counts[:stop_index] + 0.1))
plt.xlabel("time [ns]")
plt.ylabel("log10(counts) [photons]")

#open file to save raw data to
o = open("photon_count_4_22_22.csv", 'w')
#convert to timestamps to seconds and print timestamped count data
[o.write("{:.6e},{}\n".format(t, c)) for t,c in zip(time * (10**(-9)), counts[:stop_index])]

o.close()

#Fix axes display
from matplotlib.ticker import (AutoMinorLocator, MultipleLocator)
ax = plt.axes()

# Change major ticks to show every 20.
ax.xaxis.set_major_locator(MultipleLocator(0.2))
ax.yaxis.set_major_locator(MultipleLocator(0.5))

# Turn grid on for both major and minor ticks and style minor slightly
# differently.
ax.grid(which='major', color='#CCCCCC', linestyle='--')
ax.grid(which='minor', color='#CCCCCC', linestyle=':')

plt.show()