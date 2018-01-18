;+
; This routine creates images of spectral data that has
; been interpolated from Cartesian to polar in k-space.
;-
pro eppic_ktw_graphics, ktw,rtp,info, $
                        lambda=lambda, $
                        basename=basename

  nl = n_elements(lambda)
  for il=0,nl-1 do begin

     ;;==Select k index for current wavelength
     ik = find_closest(rtp.r_vals,2*!pi/lambda[il])

     ;;==Create imagea
     img = image(reform(ktw[ik,*,*]), $
                 axis_style = 2, $
                 rgb_table = 39, $
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
end
