function data_out = align_data_frames(data_in)
  data_len = size(data_in);
  data_len = data_len(1);

  max_shift = 0;
  
  data_out(1,:) = data_in(1,:);
  for i = 2:data_len
    [r, lags]  = xcorr(data_in(1,:), data_in(i,:));
    [M,I]      = max(r);
    to_shift   = lags(I);
    max_shift  = max(abs(to_shift), max_shift);
    
    data_out(i, :) = circshift(data_in(i,:), to_shift);
    
    data_out(i, 1:max_shift)       = 0;
    data_out(i, end-max_shift:end) = 0;
  end
end