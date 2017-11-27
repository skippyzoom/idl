;+
; This function builds array of data from parallel HDF 
; files. It was originally written to work with EPPIC
; simulation output. It assumes that there is one 
; parallel HDF file per time step. The variable-size
; portion of this code is based on code written by
; Meers Oppenheim and Liane Tarnecki.
;
; If TIMESTEP is set, it must be given in 
; simulation time steps, not output steps.
; The user is responsible for knowing which
; time steps are available.
;
; TO DO:
;-
function read_ph5_data, data_name, $
                        verbose=verbose, $
                        ext=ext, $
                        timestep=timestep, $
                        type=type, $
                        variable=variable, $
                        run_dir=run_dir, $
                        path=path

  ;;==Defaults and guards
  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(type) eq 0 then type = 4
  if n_elements(path) eq 0 then path = './'
  path = terminal_slash(path)
  if n_elements(run_dir) eq 0 then $
     run_dir = strmid(path,0,strpos(path,'parallel',/reverse_search))

  ;;==Read in run parameters
  params = set_eppic_params(run_dir)

  ;;==Trim the dot from file extension pattern
  if strcmp(strmid(ext,0,1),'.') then $
     ext = strmid(ext,1,strlen(ext))

  ;;==Search for available files...
  h5_file = file_search(path+'*.'+ext,count=n_files)
  if n_files ne 0 then begin
     ;;...If files exist, derive nout for subsetting (below)
     h5_base = file_basename(h5_file)
     all_timesteps = get_ph5timestep(h5_base)
     nout = all_timesteps[n_files-1]/n_files + 1
  endif $
  else begin
     ;;...Otherwise, throw an error
     errmsg = "Found no files with extension "+ext
     message, errmsg
  endelse
  
  ;;==Select a subset of time steps, if requested
  if n_elements(timestep) ne 0 then h5_file = h5_file[timestep/nout]

  ;;==Get the size of the subset
  nt = n_elements(h5_file)

  ;;==Check if user expects data to vary between time steps
  if keyword_set(variable) then begin
     tmp = get_h5_data(h5_file[0],data_name+'_index')
     n_dim = (size(tmp))[1]
     case n_dim of
        1: ft_template = {ikx:0, val:complex(0.0,0.0)}
        2: ft_template = {ikx:0, iky:0, val:complex(0.0,0.0)}
        3: ft_template = {ikx:0, iky:0, ikz:0, val:complex(0.0,0.0)}
     endcase     
  endif $
  else begin
     data = make_array([size(get_h5_data(h5_file[0],data_name),/dim),nt],type=type)
  endelse

  ;;==Loop over all available time steps
  if keyword_set(verbose) then print,"[READ_PH5_DATA] Reading ",data_name,"..."

  ;;==Set counted for missing data
  null_count = 0L

  ;;==Check if data is Fourier Transformed output
  if keyword_set(variable) then begin
     for it=0,nt-1 do begin
        ;;==Read data set
        tmp_data = get_h5_data(h5_file[it],data_name)
        tmp_size = size(tmp_data)
        tmp_len = (tmp_size[0] eq 1) ? 1 : tmp_size[2]
        tmp_cplx = complex(tmp_data[0,0:tmp_len-1],tmp_data[1,0:tmp_len-1])
        ;;==Read index set
        tmp_ind = get_h5_data(h5_file[it],data_name+'_index')
        ;;==Assign to intermediate struct
        tmp_struct = replicate(ft_template,tmp_len)
        for il=0L,tmp_len-1 do begin
           tmp_struct.val = tmp_cplx[il]
           switch n_dim of
              3: tmp_struct[il].ikz = tmp_ind[2,il]
              2: tmp_struct[il].iky = tmp_ind[1,il]
              1: tmp_struct[il].ikx = tmp_ind[0,il]
           endswitch
        endfor
        ;;==Reset temporary variables
        tmp_data = 0.0
        tmp_ind = 0.0
        ;;==Create global struct or append to existing one
        if n_elements(ft_struct) eq 0 then $
           ft_struct = tmp_struct $
        else $
           ft_struct = [ft_struct,tmp_struct]
        ;;==Convert to output array
        tmp_range = intarr(n_dim,2)
        for id=0,n_dim-1 do begin
           tmp_range[id,0] = min(ft_struct.(id))
           tmp_range[id,1] = max(ft_struct.(id))
        endfor
        ft_array = complexarr(tmp_range[*,1]-tmp_range[*,0]+1)
        case n_dim of 
           3: ft_array[ft_struct.ikx,ft_struct.iky,ft_struct.ikz] = $
              ft_struct.val
           2: ft_array[ft_struct.ikx,ft_struct.iky] = $
              ft_struct.val
           1: ft_array[ft_struct.ikx] = ft_struct.val
        endcase
        full_size = [params.ndim_space, $
                     params.nx*params.nsubdomains, $
                     params.ny, $
                     params.nz]
        ft_size = size(ft_array)
        ;; if (ft_size[1] ne outsize[1]) && (params.ndim_space eq 2) then begin
        ;;    tmp = ft_array
        ;;    ft_array = complexarr(full_size[1],ft_size[2])
        ;;    ft_array[full_size[1]-ft_size[1]:full_size[1]-1,0:ft_size[2]-1] = tmp
        ;;    ft_size = size(ft_array)
        ;; endif
        if params.ndim_space eq 2 then begin
           if ft_size[1] ne full_size[1] then begin
              tmp = ft_array
              ft_array = complexarr(full_size[1],ft_size[2])
              ft_array[full_size[1]-ft_size[1]:full_size[1]-1,0:ft_size[2]-1] = tmp
              ft_size = size(ft_array)
           endif
        endif $
        else begin
        endelse
STOP
        
     endfor
  endif $
  else begin
     for it=0,nt-1 do begin
        ;;==Read data set
        tmp = get_h5_data(h5_file[it],data_name)
        ;;==Assign to return array
        if n_elements(tmp) ne 0 then begin
           case size(data,/n_dim) of
              2: data[*,it] = tmp
              3: data[*,*,it] = tmp
              4: data[*,*,*,it] = tmp
              5: data[*,*,*,*,it] = tmp
              6: data[*,*,*,*,*,it] = tmp
              7: data[*,*,*,*,*,*,it] = tmp
              8: data[*,*,*,*,*,*,*,it] = tmp
           endcase
        endif else null_count++
     endfor
  endelse

  ;;==Let user know about missing data (not necessarily an error)
  if keyword_set(verbose) && null_count gt 0 then $
     print, "[READ_PH5_DATA] Warning: Did not find '", $
            data_name+"' in ", $
            strcompress(null_count,/remove_all),"/", $
            strcompress(nt,/remove_all)," files."

  return, data
end
