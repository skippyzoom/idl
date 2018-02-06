;+
; This routine creates either images or movies of
; spatio-temporal data from an EPPIC run.
;-
pro eppic_xyw_graphics, pdata,xdata,ydata, $
                        w_vals, $
                        info, $
                        xrng=xrng, $
                        yrng=yrng, $
                        aspect_ratio=aspect_ratio, $
                        rgb_table=rgb_table, $
                        min_value=min_value, $
                        max_value=max_value, $
                        xrange=xrange, $
                        yrange=yrange, $
                        basename=basename, $
                        colorbar_title=colorbar_title, $
                        center=center

  ;;==Get data size
  data_size = size(pdata)
  n_dims = data_size[0]

  ;;==Check data size
  if n_dims eq 3 then begin
     nt = data_size[n_dims]
     nx = data_size[1]
     ny = data_size[2]

     ;;==Defaults and guards
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(xrng) eq 0 then xrng = [0,nx-1]
     if n_elements(yrng) eq 0 then yrng = [0,ny-1]
     if n_elements(xrange) eq 0 then xrange = !NULL
     if n_elements(yrange) eq 0 then yrange = !NULL
     if n_elements(data_name) eq 0 then data_name = 'data'
     if n_elements(image_string) eq 0 then image_string = ''
     if n_elements(basename) eq 0 then basename = data_name+'-xyw-'+image_string
     if n_elements(center) eq 0 then center = [0,0]

     ;;==Backup input
     pdata_in = pdata
     xdata_in = xdata
     ydata_in = ydata

     ;;==Set up plot axes
     axes = ['x','y']
     n_axes = n_elements(axes)

     ;;==Reverse the center array for consistency with axes
     center = reverse(center)
     nc = n_elements(center)

     ;;==Extract axis subsets
     xdata = xdata[xrng[0]:xrng[1]]
     ydata = ydata[yrng[0]:yrng[1]]

     ;;==Store x & y data in a dictionary to simplify access
     vecs = dictionary('x',xdata,'y',ydata)

     ;;==Extract subimage
     gdata = pdata[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

     ;;==Declare positions locally
     layout = [1,2]
     position = multi_position(layout[*], $
                               edges = [0.12,0.10,0.80,0.80], $
                               buffer = [0.00,0.10])

     ;;==Declare x-axis titles
     xtitle = ['$k_x$ [m$^{-1}$]', $
               '$k_y$ [m$^{-1}$]', $
               '$k_z$ [m$^{-1}$]']

     ;;==Loop over number of panels (directions in k space)
     for ic=0,nc-1 do begin

        ;;==Extract the appropriate k-space abscissa
        k_vals = vecs[axes[ic mod n_axes]]

        ;;==Create panel
        if ic eq 1 then gdata = transpose(gdata,[1,0,2])
        img = image(reform(gdata[*,center[ic],*]),k_vals,w_vals, $
                    xrange = xrange, $
                    yrange = yrange, $
                    aspect_ratio = aspect_ratio, $
                    position = position[*,ic], $
                    title = '', $
                    xtitle = xtitle[ic], $
                    ytitle = '$\omega$ [rad/s]', $
                    xtickdir = 1, $
                    ytickdir = 1, $
                    xticklen = 0.01, $
                    yticklen = 0.01, $
                    axis_style = info.axis_style, $
                    rgb_table = rgb_table, $
                    min_value = min_value, $
                    max_value = max_value, $
                    current = (ic gt 0), $
                    /buffer)
        
     endfor

     ;;==Add colorbar(s)
     width  = 0.02
     height = 0.40
     buffer = 0.02
     x1 = max(position[2,*]) + buffer
     x2 = x1 + width
     y1 = 0.5*(1.0 - height)
     y2 = 0.5*(1.0 + height)
     clr = colorbar(target = img, $
                    position = [x1,y1,x2,y2], $
                    orientation = 1, $
                    textpos = 1, $
                    tickdir = 1, $
                    ticklen = 0.2, $
                    major = 7, $
                    title = colorbar_title, $
                    font_name = info.font_name, $
                    font_size = 8.0)

     ;;==Add path label
     txt = text(0.00,0.05,info.path, $
                alignment = 0.0, $
                target = img, $
                font_name = info.font_name, $
                font_size = 5.0)

     ;;==Save image
     image_save, img,filename=basename+'.pdf'

     ;;==Restore original data
     pdata = pdata_in
     xdata = xdata_in
     ydata = ydata_in

  endif $
  else print, "[EPPIC_XYW_GRAPHICS] pdata must have dimensions (x,y,w)."

end
