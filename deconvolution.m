%deconvolution.m
%simple deconvolution of photon counting data to find temporal PSF of experiment.
%Michael Langford
%5-1-2022

data = load("photon_count_4_22_22.csv");

time = data(:,1);
counts = data(:,2);

%interpolate pulse
time_step = (0.1*10^-12);
time_fine = time(1):time_step:time(end);
counts_fine = interp1(time, counts, time_fine,'cubic');

%create pulse
%pulse should 5ps long
pulse_length = 5*10^-12;
pulse_intensity = 100;

pulse = gaussian(round(pulse_length*10/time_step), 2.3548*time_step/pulse_length)';
pulse = [pulse, zeros(1, length(time_fine) - length(pulse))].*pulse_intensity;

pulse_FFT = fft(pulse);
counts_FFT = fft(counts_fine);

counts_FFT_disp = counts_FFT;

% remove fft data where pulse is below 0.08% of max intensity to prevent division by very small numbers
% removes counts_fft high freq data
max_pulse_FFT = max(pulse_FFT);
counts_FFT(pulse_FFT<0.0008*max_pulse_FFT)=0;

%solve for PSF
% - not a very robust calculation, as much much better 
%   deconvolution methods exist
point_spread_FFT = counts_FFT./(pulse_FFT);

%remove inf / nan
point_spread_FFT(isinf(point_spread_FFT))=0;
point_spread_FFT(isnan(point_spread_FFT))=0;
point_spread = abs(ifft(point_spread_FFT));

w = linspace(-pi, pi, length(pulse_FFT));

figure()
subplot(4, 1, 1)
semilogy(w, abs(fftshift(0.001+pulse_FFT)));
xlabel("w [rad]");
ylabel("intensity");
title("pulse FFT");

subplot(4, 1, 2)
semilogy(w, abs(fftshift(0.001+counts_FFT_disp)));
xlabel("w [rad]");
ylabel("intensity");
title("photon count FFT");

subplot(4, 1, 3)
semilogy(w, abs(fftshift(0.001+counts_FFT)));
xlabel("w [rad]");
ylabel("intensity");
title("photon count FFT (sidelobes clipped)");

subplot(4, 1, 4)
semilogy(w, abs(fftshift(0.001+point_spread_FFT)));
xlabel("w [rad]");
ylabel("intensity");
title("PSF FFT");

figure()
plot(time_fine(1:(pulse_length/time_step)*10), pulse(1:(pulse_length/time_step)*10));
xlabel("t [s]");
ylabel("intensity");
title("simulated pulse shape, FWHM 5ps");

figure()

hold on
semilogy(time_fine, (point_spread));
semilogy(time_fine, (counts_fine));
semilogy(time_fine, (pulse+0.01));

xlabel("time [s]");
ylabel("photons [#]");

h = legend ("PSF", "photon counts", "simulated pulse photon counts");
legend (h, "location", "northeastoutside");

% calculate and print FWHM (uses interpolated data, so fewer 
%  sig figs than given are valid
fwhm_ns = fwhm(point_spread)*time_step*10^9
