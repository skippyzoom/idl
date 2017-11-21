;+
; Create spectral graphics, without time transform, from project context
;-
pro project_graphics_kxyzt, context,name,class

  print, "[PROJECT_GRAPHICS_KXYZT] Currently unavailable"

  if 0 then begin
     ;;==Scale normalized panel indices
     if strcmp(context.panel.index.type,'rel',3) then begin
        temp = floor(context.panel.index.value*context.params.nt_max)
        ge_max = where(temp ge context.params.nt_max,count)
        if count gt 0 then temp[ge_max] = context.params.nt_max-1
        panel_index = temp
     endif $
     else panel_index = context.panel.index.value

     datadims = size(context.data.array[name],/dim)
     tsize = datadims[context.params.ndim_space]
     wsize = next_power2(tsize)
     fftdata = complexarr(context.grid.nx, $
                          context.grid.ny, $
                          context.grid.nz, $
                          wsize)*0.0
     fftdata[*,*,*,0:tsize-1] = complex(context.data.array[name])
     for iw=0,wsize-1 do fftdata[*,*,*,iw] = fft(fftdata[*,*,*,iw],/center)
     imgdata = abs(fftdata)
     for it=0,tsize-1 do imgdata[*,*,*,it] /= max(imgdata[*,*,*,it])
     where_ne0 = where(imgdata ne float(0))
     imgdata[where_ne0] = 10*alog10(imgdata[where_ne0]^2)
     xlen = context.grid.nx*context.params.nout_avg*context.grid.dx
     ylen = context.grid.ny*context.params.nout_avg*context.grid.dy
     xdata = (2*!pi/xlen)*(findgen(context.grid.nx) - 0.5*context.grid.nx)
     ydata = (2*!pi/ylen)*(findgen(context.grid.ny) - 0.5*context.grid.ny)
     img = data_image(imgdata,xdata,ydata, $
                      panel_index = panel_index, $
                      panel_layout = context.panel.layout, $
                      rgb_table = context.graphics.rgb_table.fft, $
                      min_value = -30, $
                      max_value = 0, $
                      ;; xtitle = "$k_{zon}/\pi$ [m$^{-1}$]", $
                      ;; ytitle = "$k_{ver}/\pi$ [m$^{-1}$]", $
                      xrange = [-4*!pi,4*!pi], $
                      yrange = [-4*!pi,4*!pi], $
                      colorbar_type = context.graphics.colorbar.type, $
                      colorbar_title = colorbar_title)
     if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
        filename = name+'_'+class+'-'+context.graphics.note+ $
                   context.graphics.image.type $
     else filename = name+'_'+class+context.graphics.image.type
     image_save, img,filename = context.path+path_sep()+filename,/landscape
  endif ;SKIP
end
