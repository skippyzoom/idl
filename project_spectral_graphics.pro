;+
; Routines for producing spectral graphics of data.
; Originally created for EPPIC simulation data.
;-
pro project_spectral_graphics, prj
@load_eppic_params

  ;;==Spatial power as a function of time
  if ndim_space eq 2 then smooth_widths = [0.1/dx,0.1/dx,1] $
  else smooth_widths = [0.1/dx,0.1/dx,0.1/dx,1]
  name = prj.data.keys()
  for ik=0,prj.data.count()-1 do begin
     img = fft_kt_graphics(smooth(prj.data[name[ik]],smooth_widths,/edge_wrap), $
                           plotindex = prj.plotindex, $
                           plotlayout = prj.plotlayout, $
                           colorbar_type = prj.colorbar_type)
     filename = name[ik]+'-fft_kt'+prj.filetype
     image_save, img,filename = filename,/landscape
  endfor

  ;;==Full k-w spectrum
end
