;+
; Routines for producing spectral graphics of data.
; Originally created for EPPIC simulation data.
;-
pro project_spectral_graphics, prj
@load_eppic_params

  ;;==Spatial power as a function of time
  fft_sw = 0.1/dx
  help, fft_sw
  name = prj.data.keys()
  for ik=0,prj.data.count()-1 do begin
     img = fft_kt_graphics(smooth(prj.data[name[ik]],[fft_sw,fft_sw,1]), $
                           plotindex = prj.plotindex, $
                           plotlayout = prj.plotlayout, $
                           colorbar_type = prj.colorbar_type)
     filename = name[ik]+'-fft_kt'+prj.filetype
     image_save, img,filename = filename,/landscape
  endfor

  ;;==Full k-w spectrum
end
