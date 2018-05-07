;+
; Procedure for making a movie of output from interp_xy2kt.pro
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
pro xy2kt_movie, xy2kt, $
                 lun=lun, $
                 data_isdB=data_isdB, $
                 lambda=lambda, $
                 plot_kw=plot_kw, $
                 filebase=filebase, $
                 filetype=filetype

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(filebase) eq 0 then filebase = 'xy2kt_frames'
  filebase = strip_extension(filebase)
  if n_elements(filetype) eq 0 then filetype = 'mp4'
  if n_elements(plot_kw) eq 0 then plot_kw = dictionary()

  if ~keyword_set(lambda) then lambda = xy2kt.keys()
  nl = n_elements(lambda)
  for il=0,nl-1 do begin
     plot_lambda = lambda[il]
     filename = filebase+ $
                '-'+string(plot_lambda,format='(f04.1)')+'m'+ $
                '.'+get_extension(filetype)
     t_interp = xy2kt[plot_lambda].t_interp
     t_interp /= !dtor
     f_interp = xy2kt[plot_lambda].f_interp
     fsize = size(f_interp)
     if fsize[0] gt 1 then begin
        if keyword_set(data_isdB) then $
           for it=0,fsize[2]-1 do f_interp[*,it] -= max(f_interp[*,it]) $
        else $
           for it=0,fsize[2]-1 do f_interp[*,it] /= max(f_interp[*,it])
        data_graphics, t_interp, $
                       f_interp, $
                       /make_movie, $
                       filename = filename, $
                       plot_kw = plot_kw
     endif $
     else begin
        printf, lun,"[XY2KT_MOVIE] Interpolated arrays must have more than one time"
        printf, lun,"              step in order to make a movie. If you want individual"
        printf, lun,"              frames, see xy2kt_frames.pro"
     endelse
  endfor

end
