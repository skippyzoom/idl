;+
; This function takes the FFT of some data and calculates the
; array of power as a function of k value (k), look angle (theta), 
; frequency (omega), and, optionally, aspect angle (alpha).
;
; TO DO
; -- Keywords: Pass in separate structs for fft_custom() and 
;    kmag_interpolate()? Just handle a few and hardcode the
;    rest?
;-
function calc_kmag, data, $
                    overwrite=overwrite, $
                    skip_time_fft=skip_time_fft, $
                    alpha=alpha, $
                    nTheta=nTheta, $
                    nAlpha=nAlpha, $
                    shape=shape

@load_eppic_params

  ;;==Defaults and guards
  if n_elements(nTheta) eq 0 then nTheta = 360
  if n_elements(nAlpha) eq 0 then nAlpha = 1
  if n_elements(alpha) eq 0 then alpha = 0.0

  ;;==Calculate FFT
  if keyword_set(skip_time_fft) then begin
     data = fft_custom(data, $
                       overwrite = overwrite, $
                       /center, $
                       /normalize, $
                       /skip_time, $
                       /verbose)
  endif else begin
     data = fft_custom(data, $
                       overwrite = overwrite, $
                       /center, $
                       alpha = alpha, $
                       /normalize, $
                       /swap_time, $
                       /zero_dc, $
                       /verbose)
  endelse

  ;;==Interpolate FFT from Cartesian to spherical
  kmag = kmag_interpolate_loop(data, $
                               dx = dx*nout_avg, $
                               dy = dy*nout_avg, $
                               dz = dz*nout_avg, $
                               aspect = alpha, $
                               shape = shape, $
                               nTheta = nTheta, $
                               nAlpha = nAlpha)

  ;;==Free memory
  data = !NULL

  ;;==Return kmag struct
  return, kmag
end
