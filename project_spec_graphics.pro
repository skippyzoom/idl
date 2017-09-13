;+
; Routines for producing spectral graphics of data.
; Originally created for EPPIC simulation data.
;-
pro project_spec_graphics, prj, $
                           filetype = filetype, $
                           plotindex=plotindex, $
                           plotlayout=plotlayout, $
                           global_colorbar=global_colorbar
@load_eppic_params

  fft_sw = 0.1/dx
  help, fft_sw
  name = prj.data.keys()
  for ik=0,prj.data.count()-1 do begin
     img = fft_kt_graphics(smooth(prj.data[name[ik]],[fft_sw,fft_sw,1]), $
                           plotindex = plotindex, $
                           plotlayout = plotlayout, $
                           global_colorbar = global_colorbar)
     filename = name[ik]+'-fft_kt'+filetype
     image_save, img,filename = filename,/landscape
  endfor
end
