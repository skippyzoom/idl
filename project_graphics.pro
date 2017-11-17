;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
; -- Handle 3-D data. The imgdata array will 
;    still be logically (2+1)-D but there 
;    could be a loop over 2-D planes.
;-
pro project_graphics, context

  ;;==Build colorbar titles
  colorbar_title = context.data.label

  ;;==Scale normalized panel indices
  temp = floor(context.panel.index*context.params.nt_max)
  ge_max = where(temp ge context.params.nt_max,count)
  if count gt 0 then temp[ge_max] = context.params.nt_max-1
  scaled_index = temp

  ;;==Loop over all data quantities
  c_keys = context.graphics.class.keys()
  for ik=0,context.graphics.class.count()-1 do begin
     name = c_keys[ik]
     class = context.graphics.class[name]
     n_classes = n_elements(class)
     for ic=0,n_classes-1 do begin
        case 1B of 
           strcmp(class[ic],'space'): begin 
              ;;------------------;;
              ;; Spatial graphics ;;
              ;;------------------;;

              ;;==Set up data for graphics routines
              imgdata = context.data.array[name]
              imgdata = smooth(imgdata, $
                               [context.graphics.smooth[0], $
                                context.graphics.smooth[1], $
                                context.graphics.smooth[2], 1], $
                               /edge_wrap)
              imgdata = imgdata[context.data.xrng[0]:context.data.xrng[1], $
                                context.data.yrng[0]:context.data.yrng[1], $
                                *]*context.data.scale[name]
              xdata = context.data.xvec[context.data.xrng[0]:context.data.xrng[1]]
              ydata = context.data.yvec[context.data.yrng[0]:context.data.yrng[1]]
              colorbar_title = context.data.label[name]+" "+context.data.units[name]

              ;;==Create single- or multi-panel images
              img = data_image(imgdata,xdata,ydata, $
                               panel_index = scaled_index, $
                               panel_layout = context.panel.layout, $
                               rgb_table = context.graphics.rgb_table[name], $
                               min_value = -max(abs(imgdata)), $
                               max_value = max(abs(imgdata)), $
                               xtitle = "Zonal [m]", $
                               ytitle = "Vertical [m]", $
                               colorbar_type = context.graphics.colorbar.type, $
                               colorbar_title = colorbar_title)
              if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
                 filename = name+'_'+class[ic]+'-'+context.graphics.note+ $
                            context.graphics.image.type $
              else filename = name+'_'+class[ic]+context.graphics.image.type
              image_save, img,filename = context.path+path_sep()+filename,/landscape

              ;;==Create movies (if requested)
              if context.graphics.movie.make then begin
                 string_time = string(context.params.dt*context.params.nout* $
                                      1e3* $
                                      lindgen(context.params.nt_max), format='(f7.2)')
                 string_time = strcompress(string_time,/remove_all)+" ms"
                 if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
                    filename = name+'_'+class[ic]+'-'+context.graphics.note+ $
                               context.graphics.movie.type $
                 else filename = name+'_'+class[ic]+context.graphics.movie.type
                 data_movie, imgdata,xdata,ydata, $
                             filename = context.path+path_sep()+filename, $
                             title = string_time, $
                             rgb_table = context.graphics.rgb_table[name], $
                             dimensions = context.data.dimensions[0:1], $
                             expand = context.graphics.movie.expand, $
                             rescale = context.graphics.movie.rescale, $
                             colorbar_title = colorbar_title
              endif
           end

           strcmp(class[ic],'space-diff'): begin
              print, "PROJECT_GRAPHICS: No routine yet for graphics class (",class[ic],")"
              ;; background = rms(imgdata[*,*,0:3],dim=3)
              ;; for it=0,context.params.nt_max-1 do imgdata[*,*,it] -= background
           end

           strcmp(class[ic],'kxyzt'): begin
              ;;------------------------------------------;;
              ;; Spectral graphics without time transform ;;
              ;;------------------------------------------;;

              datadims = size(context.data.array[name],/dim)
              tsize = datadims[context.params.ndim_space]
              wsize = next_power2(tsize)
              fftdata = complexarr(context.grid.nx,context.grid.ny,wsize)*0.0
              fftdata[*,*,0:tsize-1] = complex(context.data.array[name])
              for iw=0,wsize-1 do fftdata[*,*,iw] = fft(fftdata[*,*,iw],/center)
              imgdata = abs(fftdata)
              for it=0,tsize-1 do imgdata[*,*,it] /= max(imgdata[*,*,it])
              where_ne0 = where(imgdata ne float(0))
              imgdata[where_ne0] = 10*alog10(imgdata[where_ne0]^2)
              xlen = context.grid.nx*context.params.nout_avg*context.grid.dx
              ylen = context.grid.ny*context.params.nout_avg*context.grid.dy
              xdata = (2*!pi/xlen)*(findgen(context.grid.nx) - 0.5*context.grid.nx)
              ydata = (2*!pi/ylen)*(findgen(context.grid.ny) - 0.5*context.grid.ny)
              img = data_image(imgdata,xdata,ydata, $
                               panel_index = scaled_index, $
                               panel_layout = context.panel.layout, $
                               rgb_table = context.graphics.rgb_table.fft, $
                               min_value = -30, $
                               max_value = 0, $
                               xtitle = "$k_{zon}/\pi$ [m$^{-1}$]", $
                               ytitle = "$k_{ver}/\pi$ [m$^{-1}$]", $
                               xrange = [-4*!pi,4*!pi], $
                               yrange = [-4*!pi,4*!pi], $
                               colorbar_type = context.graphics.colorbar.type, $
                               colorbar_title = colorbar_title)
              if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
                 filename = name+'_'+class[ic]+'-'+context.graphics.note+ $
                            context.graphics.image.type $
              else filename = name+'_'+class[ic]+context.graphics.image.type
              image_save, img,filename = context.path+path_sep()+filename,/landscape
           end
           else: print, "PROJECT_GRAPHICS: Did not recognize graphics class (",class[ic],")"
        endcase
     endfor
  endfor

end
