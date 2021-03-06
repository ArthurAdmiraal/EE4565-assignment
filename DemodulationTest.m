close all;
clear all;

%% get calibration signal
% calibration_file_name = 'mulyipath_full_011.csv';
% cal_start = -1.922;
% cal_stop  =  2.169;

calibration_file_name = 'mulyipath_nodirect_012.csv';
cal_start = -1.25;
cal_stop  =  1.25;

[t_ns_cal, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25], 'length', 'nonzero');

f_mod = 3.014;

[t_ns, signal] = get_signal(3);
signal         = signal / max(signal);
zci            = find_zero_crossings(signal);
zci = 2*double(zci) - 1;
zci((t_ns < 0) | (t_ns > 20)) = 0;

Fs = 1/mean(diff(t_ns));

L  = length(zci);
n = 2^nextpow2(L);
Y  = fft(zci, n, 1);

P2 = abs(Y/L);
P1 = P2(1:n/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% .*cos(2*pi*f_mod*t_ns)
% figure;
% hold on;
% plot(t_ns, signal);
% plot(t_ns, zci);
% 
% figure;
% plot(0:(Fs/n):(Fs/2-Fs/n),P1(1:n/2));
% 
% figure;
% hold on;
% plot(t_ns, signal);
% plot(t_ns, signal.*cos(2*pi*f_mod*t_ns));

%% Demodulate signal
demodulated_signal = signal.*cos(2*pi*f_mod*t_ns) + 1j* signal.*sin(2*pi*f_mod*t_ns);

n2 = 11;
d2 = (n2-1)/2;
Wn = f_mod / Fs;
b  = fir1(n2,Wn);

demodulated_signal = filter(b, 1, demodulated_signal);

%% Demodulate calibration signal
% [t_ns_cal, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25]); % , 'length', 'nonzero'
% figure;
% hold on;
% plot(t_ns_cal, calibration_signal);
% 
% f_mod = 3.5;
% 
% calibration_signal = calibration_signal.*cos(2*pi*f_mod*t_ns_cal) + 1j*calibration_signal.*sin(2*pi*f_mod*t_ns_cal);
% calibration_signal = filter(b, 1, calibration_signal);
% 
% figure;
% hold on;
% plot(t_ns_cal, real(calibration_signal));
% plot(t_ns_cal, imag(calibration_signal));

%% Get FIR deconvolution of complex enveloped
% [t, reflections] = analysis.get_fir_deconvolution(t_ns, demodulated_signal, calibration_signal, true);
% 
% figure;
% plot(t,abs(reflections));

%% integrated solution
[t_ns_cal, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25], 'length', 'nonzero');
[t_ns, signal] = get_signal(3);
[t, reflections] = analysis.get_fir_envelope_deconvolution(t_ns, signal, t_ns_cal, calibration_signal, true);

x = t * physconst('LightSpeed')*1e-9*100;

figure;
hold on;
plot(t_ns*physconst('LightSpeed')*1e-9*100, abs(signal)/max(abs(signal)));
plot(x, reflections)

figure;
[t, reflections, t_raw, raw] = analysis.get_fir_deconvolution(t_ns, signal, calibration_signal, true);
figure;
plot(t_raw*physconst('LightSpeed')*1e-9*100, raw)

%% deconvolution test
f_mod = 3.7;
[t_ns_cal, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25]); % , 'length', 'nonzero'
[t_ns, signal] = get_signal(3);

% get complex envelopes - quadrature mix and filter
signal_envelope      = signal            .*cos(2*pi*f_mod*t_ns)     + 1j*signal            .*sin(2*pi*f_mod*t_ns);
calibration_envelope = calibration_signal.*cos(2*pi*f_mod*t_ns_cal) + 1j*calibration_signal.*sin(2*pi*f_mod*t_ns_cal);

signal_envelope      = filter(b, 1, signal_envelope);
calibration_envelope = filter(b, 1, calibration_envelope);

n1 = length(calibration_signal);
d1 = floor((n1-1)/2);
[h,err] = analysis.spike(calibration_signal,d1,n1);

[t_ns_cal, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25]);
%calibration_envelope = calibration_signal.*cos(2*pi*f_mod*t_ns_cal) + 1j*calibration_signal.*sin(2*pi*f_mod*t_ns_cal);

reflections = filter(b, 1, filter(h,1,signal));

figure;
hold on;
%plot(t_ns_cal, abs(filter(h,1,calibration_signal)));
plot(t_ns_cal, reflections);%filter(h,1,signal));
%plot(calibration_signal/max(abs(calibration_signal)))

%% data analysis
% load signals in pairs
% file_name_direct   = file_names  {2*trialnum_major - 1};
% file_name_nodirect = file_names  {2*trialnum_major - 0};
% 
% signal_aligned = analysis.align_to_signal(signal_full, signal_blocked);
% t_ns           = t_ns_full;

% [t_ns, signal_direct]   = get_signal(5);
% [~,    signal_nodirect] = get_signal(6);
% 
% signal_nodirect = analysis.align_to_signal(t_ns, signal_direct, signal_nodirect, [-1,4.5]);
% 
% [t,  reflections_full]   = analysis.get_fir_deconvolution(t_ns, signal_direct,   calibration_signal, false);
% [~, reflections_blocked] = analysis.get_fir_deconvolution(t_ns, signal_nodirect, calibration_signal, false);
% 
% reflections_blocked = reflections_blocked / max(reflections_full);
% reflections_full    = reflections_full    / max(reflections_full);

% figure;
% hold on;
% plot(t_ns, signal_direct);
% plot(t_ns, signal_nodirect);
% legend('Direct','Blocked');
% title('Aligned time data');
% 
% figure;
% hold on;
% x = t*physconst('LightSpeed')*1e-9*100;
% plot(x, 20*log10(abs(reflections_full)));
% plot(x, 20*log10(abs(reflections_blocked)));
% legend('Direct','Blocked');
% title('Side-by-side impulse responses');
  
function zci = find_zero_crossings(signal)
  zci = signal(:).*circshift(signal(:), [-1 0]) <= 0;
end

function [t_ns, signal, description] = get_signal(trialnum)
  descriptions = {'Empty',                           ... % experiment 2) 3 metre without people
                  'Empty (no direct)',               ... % experiment 5) only reflector blocking path
                  'Sidewards reflector',             ... % mulyipath_full_011
                  'Sidewards reflector (no direct)', ... % mulyipath_nodirect_012
                  'People',                          ... % experiment 3) 3 metre with people
                  'People (no direct)'                   % experiment 4) people with reflector
    };

  file_names = {'experiment2_006.csv',        ... % experiment 2) 3 metre without people
                'experiment5_009.csv',        ... % experiment 5) only reflector blocking path
                'mulyipath_full_011.csv',     ... % mulyipath_full_011
                'mulyipath_nodirect_012.csv', ... % mulyipath_nodirect_012
                'experiment3_007.csv',        ... % experiment 3) 3 metre with people
                'experiment4_008.csv'             % experiment 4) people with reflector
    };

  out_names = {'Empty',              ... % experiment 2) 3 metre without people
               'Empty_nodirect',     ... % experiment 5) only reflector blocking path
               'Sidewards',          ... % mulyipath_full_011
               'Sidewards_nodirect', ... % mulyipath_nodirect_012
               'People',             ... % experiment 3) 3 metre with people
               'People_nodirect'         % experiment 4) people with reflector
    };

  file_name   = file_names{trialnum};
  
  [t_ns, signal] = import.get_measurement(file_name);
  description    = descriptions{trialnum};
end