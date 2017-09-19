;+
; Routine for producing graphics of spatial spectra as 
; a function of time.
;
; NOTES
; -- This function should not require a project dictionary.
;
; TO DO
; -- Implement panel-specific colorbars
;-
function fft_kw_graphics, data, $
                          dx=dx,dy=dy, $
                          colorbar_type=colorbar_type

  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  imgsize = size(data)
  xsize = imgsize[1]
  ysize = imgsize[2]
  xdata = (2*!pi/(xsize*dx))*(findgen(xsize) - 0.5*xsize)
  ydata = (2*!pi/(ysize*dy))*(findgen(ysize) - 0.5*ysize)

  return, img
end
