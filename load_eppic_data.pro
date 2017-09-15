;+
; Load EPPIC simulation data into memory.
;
; This function can handle different file types
; for different simulation quantities.
;
; The default for timestep is all time steps.
;
; TO DO:
; -- Only create dictionary entries for data that has
;    been read successfully.
; -- Allow user to specify names of IDL save files
;    from which to read data.
; -- Add option to calculate E-field component(s) or 
;    magnitude? May be more trouble than it's worth,
;    but could also provide a more streamlined setup
;    for kmag_interpolate-related routines.
;-

function load_eppic_data, data_name,data_type,path, $
                          timestep=timestep, $
                          _EXTRA=ex
;; @load_eppic_params
  if n_elements(path) eq 0 then path = '.'
  params = set_eppic_params(path)
  grid = set_grid(path)
  nt_max = calc_timesteps(path,grid)

  if n_elements(data_name) gt 0 then begin
     nData = n_elements(data_name)
     nType = n_elements(data_type)
     if nType gt 0 and nType ne nData then $
        data_type = make_array(nData,value=data_type[0]) $
     else data_type = make_array(nData,value='ph5')
     if n_elements(timestep) eq 0 then nt = params.nout*nt_max $
     else nt = n_elements(timestep)

     data = dictionary()
     for id=0,nData-1 do begin
        print, "LOAD_EPPIC_DATA: Loading ",data_name[id],"..."
        data[data_name[id]] = read_xxx_data(data_name[id], $
                                            data_type[id], $
                                            nx = grid.nx, $
                                            ny = grid.ny, $
                                            nz = grid.nz, $
                                            nsubdomains = grid.nsubdomains, $
                                            order = params.order, $
                                            skip = params.iskip, $
                                            istart = params.istart, $
                                            iend = params.iend, $
                                            sizepertime = grid.sizepertime, $
                                            timestep = timestep, $
                                            path = path+path_sep()+'parallel', $
                                            /verbose, $
                                            _EXTRA = ex)
     endfor
     return, data
  endif else begin
     print, "LOAD_EPPIC_DATA: No data loaded"
     return, !NULL
  endelse

end
