;+
; Read an EPPIC input file into a dictionary. This function
; is intended to replace the @ppic3d.i/@eppic.i paradigm.
;
; TO DO
; -- Check that ppic3d.i exists. If it doesn't, try eppic.i.
;    If that doesn't exist, exit gracefully.
; -- Is there a better place to set the units dictionary?
;-
function set_eppic_params, path

  ;---------------------------;
  ; Read the EPPIC input file ;
  ;---------------------------;
  filename = expand_path(path+path_sep()+'ppic3d.i')
  openr, rlun,filename,/get_lun
  line = ''
  params = dictionary()
  for il=0,file_lines(filename)-1 do begin
     readf, rlun,line
     if ~strcmp(strmid(line,0,1),';') then begin
        eq_pos = strpos(line,'=')
        if eq_pos ge 0 then begin
           name = strcompress(strmid(line,0,eq_pos),/remove_all)
           value = strtrim(strmid(line,eq_pos+1,strlen(line)),2)
           params[name] = detect_type(value,/convert)
        endif
     endif
  endfor
  close, rlun
  free_lun, rlun

  ;----------;
  ; Defaults ;
  ;----------;
  ;; if ~params.haskey('ny') then params.ny = 1
  ;; if ~params.haskey('nz') then params.nz = 1
  if ~params.haskey('ndim_space') then params.ndim_space = 1+params.haskey('ny')+params.haskey('nz')
  if params.ndim_space lt 3 then params.nz = 1
  if params.ndim_space lt 3 then params.dz = 0.0
  if params.ndim_space lt 2 then params.ny = 1
  if params.ndim_space lt 2 then params.dy = 0.0
  if ~params.haskey('nsubdomains') then params.nsubdomains = 1
  if ~params.haskey('subcycle0') then params.subcycle0 = 1
  if ~params.haskey('subcycle1') then params.subcycle1 = 1
  if ~params.haskey('subcycle2') then params.subcycle2 = 1
  if ~params.haskey('subcycle3') then params.subcycle3 = 1
  if ~params.haskey('den_out_subcycle0') then params.den_out_subcycle0 = 1
  if ~params.haskey('den_out_subcycle1') then params.den_out_subcycle1 = 1
  if ~params.haskey('den_out_subcycle2') then params.den_out_subcycle2 = 1
  if ~params.haskey('den_out_subcycle3') then params.den_out_subcycle3 = 1
  if ~params.haskey('iskip') then params.iskip = 1
  if ~params.haskey('istart') then params.istart = 0
  if ~params.haskey('iend') then params.iend = -1
  if ~params.haskey('order') then params.order = [0,1,2]
  if ~params.haskey('hdf_output_arrays') then params.hdf_output_arrays = 0
  if ~params.haskey('Ex0_external') then params.Ex0_external = 0.0
  if ~params.haskey('Ey0_external') then params.Ey0_external = 0.0
  if ~params.haskey('Ez0_external') then params.Ez0_external = 0.0

  ;-------;
  ; Units ;
  ;-------;
  params.units = dictionary()
  params.units['prefixes'] = hash('Y', 24, $          ;yotta
                                  'Z', 21, $          ;zetta
                                  'E', 18, $          ;exa
                                  'P', 15, $          ;peta
                                  'T', 12, $          ;tera
                                  'G', 9, $           ;giga
                                  'M', 6, $           ;mega
                                  'k', 3, $           ;kilo
                                  'h', 2, $           ;hecto
                                  'da', 1, $          ;deca
                                  '', 0, $            ;(unit)
                                  'd', -1, $          ;deci
                                  'c', -2, $          ;centi
                                  'm', -3, $          ;milli
                                  '$\mu$', -6, $      ;micro
                                  'n', -9, $          ;nano
                                  'p', -12, $         ;pico
                                  'f', -15, $         ;femto
                                  'a', -18, $         ;atto
                                  'z', -21, $         ;zepto
                                  'y', -24)           ;yocto
  params.units['bases'] = hash('abs_den', '$m^{-3}$', $      ;Absolute density
                               'rel_den', 'rel.', $          ;Relative density
                               'phi', 'V', $                 ;Electrostatic potential
                               'E', 'V/m')                   ;Electric field

  return, params
end
