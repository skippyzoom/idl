;+
; Routines for producing spectral graphics of data.
; Originally created for EPPIC simulation data.
;-
pro project_spectral_graphics, target

  ;;==Get data names
  name = target.data.keys()

  ;;==Smooth data in space
  if target.params.ndim_space eq 2 then $
     smooth_widths = [0.1/target.params.dx, $
                      0.1/target.params.dy, $
                      1] $
  else $
     smooth_widths = [0.1/target.params.dx, $
                      0.1/target.params.dy, $
                      0.1/target.params.dz, $
                      1]

  ;;==Spatial power as a function of time
  for ik=0,target.data.count()-1 do begin
     img = kxyzt_images( $
           smooth(target.data[name[ik]],smooth_widths,/edge_wrap), $
           dx = target.params.dx, $
           dy = target.params.dy, $
           plotindex = target.plotindex, $
           plotlayout = target.plotlayout, $
           colorbar_type = target.colorbar_type $
                          )
     filename = name[ik]+'-kxyzt'+target.filetype
     image_save, img,filename = target.path+path_sep()+filename,/landscape
  endfor

  ;;==RMS spatial power
  for ik=0,target.data.count()-1 do begin
     img = fft_rms_graphics( $
           smooth(target.data[name[ik]],smooth_widths,/edge_wrap), $
           dx = target.params.dx, $
           dy = target.params.dy, $
           colorbar_type = target.colorbar_type $
                           )
     filename = name[ik]+'-fft_rms'+target.filetype
     image_save, img,filename = target.path+path_sep()+filename,/landscape
  endfor

  ;--> Use xyz_rtp.pro to plot power at a given |k| over time

  ;;==Full k-w spectrum
  for ik=0,target.data.count()-1 do begin
     img = kxyzw_images( $
           smooth(target.data[name[ik]],smooth_widths,/edge_wrap), $
           dx = target.params.dx*target.params.nout_avg, $
           dy = target.params.dy*target.params.nout_avg, $
           dt = target.params.dt*target.params.nout, $
           colorbar_type = target.colorbar_type $
                          )
     filename = name[ik]+'-kxyzw'+target.filetype
     image_save, img,filename = target.path+path_sep()+filename,/landscape
  endfor

end
