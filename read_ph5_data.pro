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
;-
function read_ph5_data, data_name, $
                        verbose=verbose, $
                        ext=ext, $
                        timestep=timestep, $
                        type=type, $
                        eppic_ft_data=eppic_ft_data, $
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
  params = set_eppic_params(path=run_dir)

  ;;==Extract global dimensions from parameters
  nx = params.nx*params.nsubdomains
  ny = params.ny
  nz = params.nz
  nout_avg = params.nout_avg
  ndim_space = params.ndim_space

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

  ;;==Check if the data is EPPIC Fourier-transformed data
  if keyword_set(eppic_ft_data) then begin
     tmp = get_h5_data(h5_file[0],data_name+'_index')
     if n_elements(tmp) ne 0 then begin
        n_dim = (size(tmp))[1]
        case n_dim of
           1: begin
              ft_template = {ikx:0, val:complex(0.0,0.0)}
              data = make_array(nx,nt,type=type)
           end
           2: begin
              ft_template = {ikx:0, iky:0, val:complex(0.0,0.0)}
              data = make_array(nx,ny,nt,type=type)
           end
           3: begin
              ft_template = {ikx:0, iky:0, ikz:0, val:complex(0.0,0.0)}
              data = make_array(nx,ny,nz,nt,type=type)
           end           
        endcase     
        tmp = !NULL
     endif
  endif $
  else begin
     tmp = get_h5_data(h5_file[0],data_name)
     if n_elements(tmp) ne 0 then begin
        n_dim = (size(tmp))[0]
        case n_dim of
           1: data = make_array(nx/nout_avg,nt,type=type)
           2: data = make_array(nx/nout_avg,ny/nout_avg,nt,type=type)
           3: data = make_array(nx/nout_avg,ny/nout_avg,nz/nout_avg,nt,type=type)
        endcase
        tmp = !NULL
     endif
  endelse

  ;;==Loop over all available time steps
  if keyword_set(verbose) then print,"[READ_PH5_DATA] Reading ",data_name,"..."

  ;;==Set counted for missing data
  null_count = 0L

  ;;==Check if data is Fourier Transformed output
  if keyword_set(eppic_ft_data) then begin

     for it=0,nt-1 do begin
        ;;==Read data set
        tmp_data = get_h5_data(h5_file[it],data_name)
        if n_elements(tmp_data) ne 0 then begin
           tmp_size = size(tmp_data)
           tmp_len = (tmp_size[0] eq 1) ? 1 : tmp_size[2]
           tmp_cplx = complex(tmp_data[0,0:tmp_len-1],tmp_data[1,0:tmp_len-1])
           ;;==Read index set
           tmp_ind = get_h5_data(h5_file[it],data_name+'_index')
           ;;==Assign to intermediate struct
           ft_struct = replicate(ft_template,tmp_len)
           ft_struct.val = reform(tmp_cplx)
           switch n_dim of 
              3: ft_struct.ikz = reform(tmp_ind[2,*])
              2: ft_struct.iky = reform(tmp_ind[1,*])
              1: ft_struct.ikx = reform(tmp_ind[0,*])
           endswitch
           ;;==Free temporary variables
           tmp_data = !NULL
           tmp_ind = !NULL
           ;;==Convert to output array
           ;;->Based on fill_k_array.pro
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
           ;;<-(fill_k_array)
           ft_struct = !NULL
           ;;->Based on mirror_fft_eppic.pro
           full_size = [ndim_space,nx,ny,nz]
           ft_size = size(ft_array)
           case ndim_space of
              2: begin
                 full_array = complexarr(full_size[1],full_size[2])              
                 full_array[0:ft_size[1]-1,0:ft_size[2]-1] = ft_array
                 ft_array = !NULL              
                 full_array = rotate(full_array,2)
                 full_array = shift(full_array,1)
                 full_array = conj(full_array)
                 data[*,*,it] = full_array
              end
              3: begin
                 full_array = complexarr(full_size[1],full_size[2],full_size[3])
                 full_array[0:ft_size[1]-1,0:ft_size[2]-1,0:ft_size[3]-1] = ft_array
                 ft_array = !NULL              
                 for iz=0,full_size[3]-1 do $
                    full_array[*,*,iz] = shift(reform(rotate(full_array[*,*,iz],2)),[1,1])
                 full_array = conj(full_array)
                 data[*,*,*,it] = full_array
              end
           endcase              ;data dimensions
        endif else null_count++ ;tmp_data exists?
     endfor                     ;time step loop
  endif $
  else begin
     for it=0,nt-1 do begin
        ;;==Read data set
        tmp = get_h5_data(h5_file[it],data_name)
        ;;==Assign to return array
        if n_elements(tmp) ne 0 then begin
           case size(data,/n_dim) of
              2: data[*,it] = tmp
              3: data[*,*,it] = transpose(tmp,[1,0])
              4: data[*,*,*,it] = transpose(tmp,[2,1,0])
              5: data[*,*,*,*,it] = transpose(tmp,[3,2,1,0])
              6: data[*,*,*,*,*,it] = transpose(tmp,[4,3,2,1,0])
              7: data[*,*,*,*,*,*,it] = transpose(tmp,[5,4,3,2,1,0])
              8: data[*,*,*,*,*,*,*,it] = transpose(tmp,[6,5,4,3,2,1,0])
           endcase              ;data dimensions
        endif else null_count++ ;tmp_data exists?
        tmp = !NULL             ;time step loop
     endfor
  endelse

  ;;==Let user know about missing data (not necessarily an error)
  if keyword_set(verbose) && null_count gt 0 then $
     print, "[READ_PH5_DATA] Warning: Did not find '", $
            data_name+"' in ", $
            strcompress(null_count,/remove_all),"/", $
            strcompress(nt,/remove_all)," files."

  if n_elements(data) eq 0 then data = !NULL
  return, data
end
