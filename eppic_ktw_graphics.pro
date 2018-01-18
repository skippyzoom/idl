;+
; This routine creates images of spectral data that has
; been interpolated from Cartesian to polar in k-space.
;-
pro eppic_ktw_graphics, ktw,rtp,info, $
                        lambda=lambda, $
                        yrange=yrange, $
                        xrange=xrange, $
                        aspect_ratio=aspect_ratio, $
                        min_value=min_value, $
                        max_value=max_value, $
                        basename=basename

  ;;==Get dimensions of input array
  ktw_size = size(ktw)
  n_dims = ktw_size[0]

  ;;==Check dimensions
  if n_dims eq 3 then begin

     ;;==Defaults and guards
     if n_elements(xrange) eq 0 then xrange = !NULL
     if n_elements(yrange) eq 0 then yrange = !NULL
     if n_elements(aspect_ratio) eq 0 then aspect_ratio = 1.0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(basename) eq 0 then basename = 'ktw'
     
     ;;==Loop over wavelengths
     nl = n_elements(lambda)
     for il=0,nl-1 do begin

        ;;==Select k index for current wavelength
        ik = find_closest(rtp.r_vals,2*!pi/lambda[il])

        ;;==Set up data
        gdata = reform(ktw[ik,*,*])
        xdata = rtp.t_vals
        ydata = rtp.w_vals/rtp.r_vals[ik]

        ;;==Create image
        img = image(gdata,xdata,ydata, $
                    axis_style = 2, $
                    aspect_ratio = aspect_ratio, $
                    rgb_table = 39, $
                    min_value = min_value, $
                    max_value = max_value, $
                    xrange = xrange, $
                    yrange = yrange, $
                    xtitle = "$\theta$ [deg]", $
                    ytitle = "$V_{ph}$ [m/s]", $
                    font_name = info.font_name, $
                    font_size = info.font_size, $
                    /buffer)

        ;;==Add colorbar(s)
        img = multi_colorbar(img,'global', $
                             width = 0.0225, $
                             height = 0.40, $
                             buffer = 0.03, $
                             orientation = 1, $
                             textpos = 1, $
                             tickdir = 1, $
                             ticklen = 0.2, $
                             major = 7, $
                             title = "Power [dB]", $
                             font_name = info.font_name, $
                             font_size = 8.0)

        ;;==Add path label
        txt = text(0.00,0.05,info.path, $
                   alignment = 0.0, $
                   target = img, $
                   font_name = info.font_name, $
                   font_size = 5.0)

        ;;==Save image
        string_lambda = string(lambda[il],format='(f5.2)')
        string_lambda = strcompress(string_lambda,/remove_all)
        image_save, img[0],filename=basename+ $
                    '_lambda'+string_lambda+'.pdf'

     endfor
  endif $
  else print, "[EPPIC_KTW_GRAPHICS] Incorrect dimensions. Could not produce graphics."

end
