close all;
clear all;

%% init output folder
output_folder = 'HalfOutput';

if not(isfolder(output_folder))
    mkdir(output_folder)
end

%% get calibration signal, direct path
calibration_file_name      = 'mulyipath_full_011.csv';
[t_ns, signal]             = import.get_measurement(calibration_file_name);
[t_ns, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.922, 2.169]);

plot_calibration_pulse(t_ns, signal, calibration_signal, 'Calibration signal (direct path)');
plot_calibration_spectrum(t_ns, calibration_signal, 'Calibration signal spectrum (direct path)');

[f, cal_spectrum] = analysis.get_spectrum(t_ns, calibration_signal);
cal_spectrum = 20*log10(abs(cal_spectrum));
cal_spectrum = cal_spectrum - max(cal_spectrum);
csvwrite([output_folder '/Sidewards-direct-raw_spectrum.csv'], [f;cal_spectrum].');
cal_spectrum_direct = cal_spectrum;

%% get calibration signal, only reflected pulse
calibration_file_name      = 'mulyipath_nodirect_012.csv';
[t_ns, signal]             = import.get_measurement(calibration_file_name);
[t_ns, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25]);

plot_calibration_pulse(t_ns, signal, calibration_signal, 'Calibration signal (reflection)');
plot_calibration_spectrum(t_ns, calibration_signal, 'Calibration signal spectrum (reflection)');

%% export spectra
[f, cal_spectrum] = analysis.get_spectrum(t_ns, calibration_signal);
cal_spectrum = 20*log10(abs(cal_spectrum));
cal_spectrum = cal_spectrum - max(cal_spectrum);
csvwrite([output_folder '/Sidewards-nodirect-raw_spectrum.csv'], [f;cal_spectrum].');
cal_spectrum_indirect = cal_spectrum;

%% normalised spectrum
csvwrite([output_folder '/Sidewards-calibration-comparison.csv'], [f;cal_spectrum_direct - cal_spectrum_indirect].');

%% helper functions
function plot_calibration_pulse(t_ns, signal, calibration_signal, title_str)
  figure;
  hold on;
  plot(t_ns, signal);
  plot(t_ns, calibration_signal);
  legend('Raw', 'Calibration pulse')

  xlabel('t (ns)');
  ylabel('y');
  
  title(title_str);
end

function plot_calibration_spectrum(t_ns, calibration_signal, title_str)
  [f, cal_spectrum] = analysis.get_spectrum(t_ns, calibration_signal);

  figure;
  plot(f, 20*log(abs(cal_spectrum)), 'Color', [0.8500 0.3250 0.0980]);
  xlabel('f (GHz)');
  ylabel('Y (dB)');
  title(title_str);
end