function signal_aligned = align_to_signal(signal_ref, signal_to_align)
  [r, lags]  = xcorr(signal_ref, signal_to_align);
  [M,I]      = max(r);
  to_shift   = lags(I);

  signal_aligned = circshift(signal_to_align, to_shift);

  signal_aligned(1:to_shift)       = 0;
  signal_aligned(end-to_shift:end) = 0;
end