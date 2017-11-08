;+
; Routines for producing spectral graphics of data.
; Originally created for EPPIC simulation data.
;-
pro project_spectral_graphics, context

  ;;==Get data names
  name = context.data.keys()

  ;;==Smooth data in space
  if context.params.ndim_space eq 2 then $
     smooth_widths = [0.1/context.params.dx, $
                      0.1/context.params.dy, $
                      1] $
  else $
     smooth_widths = [0.1/context.params.dx, $
                      0.1/context.params.dy, $
                      0.1/context.params.dz, $
                      1]

  ;; ;;==Take spatial FFT
  ;; for ik=0,context.data.count()-1 do begin
  ;;    ;; datasize = size(context.data[name[ik]])
  ;;    ;; n_dims = datasize[0]
  ;;    ;; nkx = next_power2(datasize[1])
  ;;    ;; nky = next_power2(datasize[2])
  ;;    ;; nw = next_power2(datasize[n_dims])
  ;;    ;; fftdata = complexarr(nkx,nky,nw)
  ;;    ;; fftdata[*,*,0:datasize[n_dims]-1] = complex(context.data[name[ik]])
  ;;    ;; for iw=0,nw-1 do fftdata[*,*,iw] = fft(fftdata[*,*,iw],/center)
  ;;    datadims = size(context.data[name[ik]],/dim)
  ;;    nt = datadims[context.params.ndim_space]
  ;;    fftdata = complex(context.data[name[ik]])
  ;;    for it=0,nt-1 do fftdata[*,*,it] = fft(fftdata[*,*,it],/center)
  ;; endfor  

  ;;==Spatial power as a function of time
  for ik=0,context.data.count()-1 do begin
     datadims = size(context.data[name[ik]],/dim)
     nt = datadims[context.params.ndim_space]
     fftdata = complex(smooth(context.data[name[ik]],smooth_widths,/edge_wrap))
     for it=0,nt-1 do fftdata[*,*,it] = fft(fftdata[*,*,it],/center)
     img = kxyzt_images(fftdata, $
                        dx = context.params.dx, $
                        dy = context.params.dy, $
                        plot_index = context.plot_index, $
                        plot_layout = context.plot_layout, $
                        colorbar_type = context.colorbar_type)
     filename = name[ik]+'-kxyzt'+context.img_type
     image_save, img,filename = context.path+path_sep()+filename,/landscape
  endfor

  ;;==RMS spatial power
  ;; for ik=0,context.data.count()-1 do begin
  ;;    img = fft_rms_graphics(smooth(context.data[name[ik]],smooth_widths,/edge_wrap), $
  ;;                           dx = context.params.dx, $
  ;;                           dy = context.params.dy, $
  ;;                           colorbar_type = context.colorbar_type)
  ;;    filename = name[ik]+'-fft_rms'+context.img_type
  ;;    image_save, img,filename = context.path+path_sep()+filename,/landscape
  ;; endfor

                                ;--> Use xyz_rtp.pro to plot power at a given |k| over time

  ;;==Full k-w spectrum
  ;; for ik=0,context.data.count()-1 do begin
  ;;    img = kxyzw_images(smooth(context.data[name[ik]],smooth_widths,/edge_wrap), $
  ;;                       dx = context.params.dx*context.params.nout_avg, $
  ;;                       dy = context.params.dy*context.params.nout_avg, $
  ;;                       dt = context.params.dt*context.params.nout, $
  ;;                       colorbar_type = context.colorbar_type)
  ;;    filename = name[ik]+'-kxyzw'+context.img_type
  ;;    image_save, img,filename = context.path+path_sep()+filename,/landscape
  ;; endfor

end
