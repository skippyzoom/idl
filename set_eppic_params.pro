;+
; Read a simulation parameter file and set default values.
;
; TO DO
; -- Consider setting the units dictionary elsewhere.
;-
function set_eppic_params, path

  ;---------------------------;
  ; Read the EPPIC input file ;
  ;---------------------------;
  params = read_parameter_file(path,/verbose)

  ;----------;
  ; Defaults ;
  ;----------;
  if n_elements(params) ne 0 then begin
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
  endif

  ;-------;
  ; Units ;
  ;-------;
  if n_elements(params) ne 0 then begin
     params.units = dictionary()
     params.units['prefixes'] = hash('Y', 24, $         ;yotta
                                     'Z', 21, $         ;zetta
                                     'E', 18, $         ;exa
                                     'P', 15, $         ;peta
                                     'T', 12, $         ;tera
                                     'G', 9, $          ;giga
                                     'M', 6, $          ;mega
                                     'k', 3, $          ;kilo
                                     'h', 2, $          ;hecto
                                     'da', 1, $         ;deca
                                     '', 0, $           ;(unit)
                                     'd', -1, $         ;deci
                                     'c', -2, $         ;centi
                                     'm', -3, $         ;milli
                                     '$\mu$', -6, $     ;micro
                                     'n', -9, $         ;nano
                                     'p', -12, $        ;pico
                                     'f', -15, $        ;femto
                                     'a', -18, $        ;atto
                                     'z', -21, $        ;zepto
                                     'y', -24)          ;yocto
     params.units['bases'] = hash('abs_den', '$m^{-3}$', $ ;Absolute density
                                  'rel_den', 'rel.', $     ;Relative density
                                  'phi', 'V', $            ;Electrostatic potential
                                  'E', 'V/m')              ;Electric field
  endif

  return, params
end
