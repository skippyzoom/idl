;+
; Routines for producing spectral graphics of data.
; Originally created for EPPIC simulation data.
;-
pro project_spectral_graphics, target
;; @load_eppic_params

  ;;==Spatial power as a function of time
  if target.params.ndim_space eq 2 then smooth_widths = [0.1/target.params.dx, $
                                                         0.1/target.params.dy, $
                                                         1] $
  else smooth_widths = [0.1/target.params.dx, $
                        0.1/target.params.dy, $
                        0.1/target.params.dz, $
                        1]
  name = target.data.keys()
  for ik=0,target.data.count()-1 do begin
     img = fft_kt_graphics(smooth(target.data[name[ik]],smooth_widths,/edge_wrap), $
                           dx = target.params.dx, $
                           dy = target.params.dy, $
                           plotindex = target.plotindex, $
                           plotlayout = target.plotlayout, $
                           colorbar_type = target.colorbar_type)
     filename = name[ik]+'-fft_kt'+target.filetype
     image_save, img,filename = target.path+path_sep()+filename,/landscape
  endfor

  ;;==RMS spatial power

  ;;==Full k-w spectrum
  for ik=0,target.data.count()-1 do begin
     img = fft_kw_graphics(smooth(target.data[name[ik]],smooth_widths,/edge_wrap), $
                           dx = target.params.dx*target.params.nout_avg, $
                           dy = target.params.dy*target.params.nout_avg, $
                           dt = target.params.dt*target.params.nout, $
                           colorbar_type = target.colorbar_type)
     filename = name[ik]+'-fft_kw'+target.filetype
     image_save, img,filename = target.path+path_sep()+filename,/landscape
  endfor

end
