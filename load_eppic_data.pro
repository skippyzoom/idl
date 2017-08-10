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

function load_eppic_data, dataName,dataType, $
                          timestep=timestep, $
                          _EXTRA=ex
@load_eppic_params

  if n_elements(dataName) gt 0 then begin
     nData = n_elements(dataName)
     nType = n_elements(dataType)
     if nType gt 0 and nType ne nData then $
        dataType = make_array(nData,value=dataType[0]) $
     else dataType = make_array(nData,value='ph5')
     if n_elements(timestep) eq 0 then nt = nout*ntMax $
     else nt = n_elements(timestep)

     data = dictionary()
     for id=0,nData-1 do begin
        print, "LOAD_EPPIC_DATA: Loading ",dataName[id],"..."
        data[dataName[id]] = read_xxx_data(dataName[id], $
                                           dataType[id], $
                                           nx = grid.nx, $
                                           ny = grid.ny, $
                                           nz = grid.nz, $
                                           nsubdomains = grid.nsubdomains, $
                                           order = order, $
                                           skip = iskip, $
                                           istart = istart, $
                                           iend = iend, $
                                           sizepertime = grid.sizepertime, $
                                           timestep = timestep, $
                                           path = 'parallel', $
                                           /verbose, $
                                           _EXTRA = ex)
     endfor
     return, data
  endif else begin
     print, "LOAD_EPPIC_DATA: No data loaded"
     return, !NULL
  endelse

end
