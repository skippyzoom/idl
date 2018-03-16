;+
; Create and save a movie of an EPPIC data quantity
;
; This routine reads time-dependent data of a single 2-D
; plane from 2-D or 3-D HDF files produced by EPPIC, then
; creates a movie of that (2+1)-D data array.
;
; Created 14Mar2018 by Matt Young.
;------------------------------------------------------------------------------
; DATA_NAME
;     The name of the data quantity to read. If the data
;     does not exist, read_ph5_plane.pro will return 0
;     and this routine will exit gracefully.
; PLANE (default: 'xy')
;     Simulation plane to extract from HDF data. If the
;     simulation is 2 D, read_ph5_plane.pro will ignore
;     this parameter.
; DATA_TYPE (default: 4)
;     IDL numerical data type of simulation output, 
;     typically either 4 (float) for spatial data
;     or 6 (complex) for Fourier-transformed data.
; DATA_ISFT (default: 0)
;     Boolean that represents whether the EPPIC data 
;     quantity is Fourier-transformed or not.
; SWAP_XY (default: unset)
;     Boolean keyword indicating that this routine should
;     swap the x and y axis by exchanging xdata and ydata,
;     and rotating fdata by 270 degrees.
; CALC_FFT (default: unset)
;     Boolean keyword or integer indicating whether to 
;     calculate the FFT of the data before creating images.
;     If the user sets /calc_fft, this routine will 
;     calculate the forward transform. The user can also 
;     pass an integer to indicate the transform direction
;     (e.g., calc_fft = -1 will calculate the inverse 
;     transform).
; INFO_PATH (default: './')
;     Fully qualified path to the simulation parameter
;     file (ppic3d.i or eppic.i).
; DATA_PATH (default: './')
;     Fully qualified path to the simulation data.
; SAVE_PATH (default: './')
;     Fully qualified path to the location in which to save
;     the output movie.
; SAVE_NAME (default: 'data_movie.mp4')
;     Name of the movie.
;-
pro eppic_movie, data_name, $
                 plane=plane, $
                 data_type=data_type, $
                 data_isft=data_isft, $
                 swap_xy=swap_xy, $
                 calc_fft=calc_fft, $
                 info_path=info_path, $
                 data_path=data_path, $
                 save_path=save_path, $
                 save_name=save_name

  ;;==Defaults and guards
  if n_elements(plane) eq 0 then plane = 'xy'
  if n_elements(data_type) eq 0 then data_type = 4
  if n_elements(data_isft) eq 0 then data_isft = 0B
  if n_elements(info_path) eq 0 then info_path = './'
  if n_elements(data_path) eq 0 then data_path = './'
  if n_elements(save_path) eq 0 then save_path = './'
  if ~file_test(save_path,/directory) then $
     spawn, 'mkdir -p '+expand_path(save_path)
  if n_elements(save_name) eq 0 then save_name = 'data_movie.mp4'

  ;;==Read simulation parameters
  params = set_eppic_params(path=info_path)

  ;;==Build the spatial grid struct
  grid = set_grid(path=info_path)

  ;;==Calculate max number of time steps
  nt_max = calc_timesteps(path=info_path,grid=grid)

  ;;==Create the time-step array
  timestep = params.nout*lindgen(nt_max)
  nt = n_elements(timestep)

  ;;==Create arrays of x- and y-axis data points
  xdata = grid.dx*indgen(grid.nx)
  ydata = grid.dy*indgen(grid.ny)

  ;;==Read a single (2+1)-D plane of data
  if strcmp(data_name,'e',1,/fold_case) then $
     read_name = 'phi' $
  else $
     read_name = data_name
  fdata = read_ph5_plane(read_name, $
                         ext = '.h5', $
                         timestep = timestep, $
                         plane = plane, $
                         type = data_type, $
                         data_isft = data_isft, $
                         path = data_path, $
                         /verbose)

  ;;==Check dimensions
  fsize = size(fdata)
  if fsize[0] eq 3 then begin

     ;;==Swap x and y axes, if requested
     if keyword_set(swap_xy) then begin
        tmp = ydata
        ydata = xdata
        xdata = tmp
        fsize = size(fdata)
        tmp = fdata
        fdata = make_array(fsize[2],fsize[1],nt,type=fsize[4],/nozero)
        for it=0,nt-1 do fdata[*,*,it] = rotate(tmp[*,*,it],3)
     endif

     ;;==Get dimensions of data array
     fsize = size(fdata)
     nx = fsize[1]
     ny = fsize[2]

     ;;==Calculate FFT, if requested
     if keyword_set(calc_fft) then begin
        for it=0,nt-1 do begin
           fdata[*,*,it] = fft(fdata[*,*,it],calc_fft)
           if calc_fft gt 0 then begin
              fdata[*,*,it] = real_part(fdata[*,*,it])
              fdata[*,*,it] = shift(fdata[*,*,it],[nx/2,ny/2])
              fdata[nx/2-3:nx/2+3,ny/2-3:ny/2+3,*] = min(fdata[*,*,it])
              fdata /= max(fdata[*,*,it])
              fdata[*,*,it] = 10*alog10(fdata[*,*,it]^2)
           endif
        endfor
        if calc_fft lt 1 then begin
           xtitle = '$k_{Zon}$ [m$^{-1}$]'
           ytitle = '$k_{Ver}$ [m$^{-1}$]'
        endif $
        else begin
           xtitle = 'Zonal [m]'
           ytitle = 'Vertical [m]'
        endelse
     endif

     ;;==Calculate E, if necessary
     if strcmp(data_name,'e',1,/fold_case) then begin
        Ex = fltarr(size(fdata,/dim))
        Ey = fltarr(size(fdata,/dim))
        for it=0,nt-1 do begin
           gradf = gradient(fdata[*,*,it], $
                            dx = params.dx*params.nout_avg, $
                            dy = params.dy*params.nout_avg)
           Ex[*,*,it] = -1.0*gradf.x
           Ey[*,*,it] = -1.0*gradf.y
        endfor
     endif

     ;;==Set graphics preferences
     if strcmp(data_name,'den',3) then begin
        min_value = -max(abs(fdata[*,*,1:*]))
        max_value = +max(abs(fdata[*,*,1:*]))
        rgb_table = 5
     endif
     if strcmp(data_name,'phi') then begin
        min_value = -max(abs(fdata[*,*,1:*]))
        max_value = +max(abs(fdata[*,*,1:*]))
        ct = get_custom_ct(2)
        rgb_table = [[ct.r],[ct.g],[ct.b]]
     endif
     if strcmp(data_name,'Ex') || $
        strcmp(data_name,'efield_x') then begin
        fdata = Ex
        min_value = -max(abs(fdata[*,*,1:*]))
        max_value = +max(abs(fdata[*,*,1:*]))
        rgb_table = 5
     endif
     if strcmp(data_name,'Ey') || $
        strcmp(data_name,'efield_y') then begin
        fdata = Ey
        min_value = -max(abs(fdata[*,*,1:*]))
        max_value = +max(abs(fdata[*,*,1:*]))
        rgb_table = 5
     endif
     if strcmp(data_name,'Er') || $
        strcmp(data_name,'efield_r') || $
        strcmp(data_name,'efield') then begin
        fdata = sqrt(Ex^2 + Ey^2)
        min_value = 0
        max_value = max(fdata[*,*,1:*])
        rgb_table = 3
     endif
     if strcmp(data_name,'Et') || $
        strcmp(data_name,'efield_t') then begin
        fdata = atan(Ey,Ex)
        min_value = -!pi
        max_value = +!pi
        ct = get_custom_ct(2)
        rgb_table = [[ct.r],[ct.g],[ct.b]]
     endif
     if keyword_set(calc_fft) then begin
        min_value = -30
        max_value = 0
        rgb_table = 39
     endif
STOP
     ;;==Set up an array of times for the title
     str_time = strcompress(string(1e3*params.dt*timestep, $
                                   format='(f6.2)'),/remove_all)
     title = "t = "+str_time+" ms"

     ;;==Create the movie
     filename = expand_path(save_path+path_sep()+save_name)
     data_movie, fdata,xdata,ydata, $
                 filename = filename, $
                 min_value = min_value, $
                 max_value = max_value, $
                 rgb_table = rgb_table, $
                 axis_style = 1, $
                 title = title, $
                 xstyle = 1, $
                 ystyle = 1, $
                 xmajor = 5, $
                 xminor = 1, $
                 ymajor = 5, $
                 yminor = 1, $
                 xticklen = 0.02, $
                 yticklen = 0.02*(float(ny)/nx), $
                 xsubticklen = 0.5, $
                 ysubticklen = 0.5, $
                 xtickdir = 1, $
                 ytickdir = 1, $
                 xtickfont_size = 20.0, $
                 ytickfont_size = 20.0, $
                 font_size = 24.0, $
                 font_name = "Times"

  endif $
  else print, "[EPPIC_MOVIE] Could not create movie of "+data_name+"."
  
end
