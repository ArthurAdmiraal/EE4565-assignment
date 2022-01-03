function signal_aligned = align_to_signal(t_ns, signal_ref, signal_to_align, mask_range)
  signal_ref( (t_ns >= mask_range(1)) & (t_ns <= mask_range(2)) ) = 0;
  [r, lags]  = xcorr(signal_ref, signal_to_align);
  [M,I]      = max(r);
  to_shift   = lags(I);

  signal_aligned = circshift(signal_to_align, to_shift);

  signal_aligned(1:to_shift)       = 0;
  signal_aligned(end-to_shift:end) = 0;
end