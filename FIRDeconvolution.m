calibration_file_name      = 'mulyipath_nodirect_012.csv';
[t_ns, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25], 'Length', 'nonzero');
n1 = 41;
d1 = (n1-1)/2;
[h,err] = analysis.spike(calibration_signal,d1,n1);

% figure;
% plot(calibration_signal);
% 
% figure;
% plot(h);

calibration_file_name      = 'experiment2_006.csv';%'mulyipath_full_011.csv';
[t_ns, signal] = import.get_measurement(calibration_file_name);
y = filter(h,1,signal);


n2 = 81;
Wn = 0.2;
b = fir1(n2,Wn);
y2 = filter(b,1,abs(y));
d2 = (n2-1)/2;

ts = mean(diff(t_ns));

figure;
hold on;
out = 20*log10(abs(y));
out = out-max(out);
plot(t_ns-ts*d1, out);

%[t, reflections] = get_fir_deconvolution(t_ns, signal, calibration_signal)
n1 = length(calibration_signal);
out2 = 20*log10(abs(y2));
out2 = out2-max(out2);
plot(t_ns-ts*(d2+d1), out2);


[t_ns, signal] = import.get_measurement(file_name);
[t2, reflections2] = analysis.get_fir_deconvolution(t_ns, signal, calibration_signal);
csvwrite([output_folder '/' out_names{trialnum} '-fir_impulse.csv'], [t2*physconst('LightSpeed')*1e-9*100;20*log(abs(reflections2))].');

figure;
plot(t2*physconst('LightSpeed')*1e-9*100, reflections2);