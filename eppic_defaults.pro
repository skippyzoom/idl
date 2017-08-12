;+
; Sets default parameters for analyzing EPPIC/PPIC3D simulation runs.
; Some of this comes from $EPPIC/idl/ppic3d/params_in.pro, where
; where $EPPIC is the directory containing code from the EPPIC SVN
; repository.
;
; Graphics default structs will be passed to graphics routines, so
; they may only consist of valid keyword parameters for the 
; receiving routine.
;
; This script may be called multiple times during analysis routines,
; so DO NOT PUT ANY RECURSIVE CALCULATIONS HERE! It is also probably
; best to prevent overwriting existing values by using a guard such
; as "if n_elements(<var>) eq 0 then <var> = <value>".
;-

ny = 1
dy = 1
nz = 1
dz = 1

;--------------------------------;
; Simulation inputs and defaults ;
;--------------------------------;
@ppic3d.i

if n_elements(ndim_space) eq 0 then ndim_space = 1+(ny gt 1)+(nz gt 1)
if ndim_space lt 3 then nz = 1
if ndim_space lt 3 then dz = 0.0
if ndim_space lt 2 then ny = 1
if ndim_space lt 2 then dy = 0.0
if n_elements(nsubdomains) eq 0 then nsubdomains = 1
if n_elements(subcycle0) eq 0 then subcycle0 = 1
if n_elements(subcycle1) eq 0 then subcycle1 = 1
if n_elements(subcycle2) eq 0 then subcycle2 = 1
if n_elements(subcycle3) eq 0 then subcycle3 = 1
if n_elements(den_out_subcycle0) eq 0 then den_out_subcycle0 = 1
if n_elements(den_out_subcycle1) eq 0 then den_out_subcycle1 = 1
if n_elements(den_out_subcycle2) eq 0 then den_out_subcycle2 = 1
if n_elements(den_out_subcycle3) eq 0 then den_out_subcycle3 = 1
if n_elements(iskip) eq 0 then iskip = 1
if n_elements(istart) eq 0 then istart = 0
if n_elements(iend) eq 0 then iend = -1
if n_elements(hdf_output_arrays) eq 0 then hdf_output_arrays = 0
if n_elements(Ex0_external) eq 0 then Ex0_external = 0.0
if n_elements(Ey0_external) eq 0 then Ey0_external = 0.0
if n_elements(Ez0_external) eq 0 then Ez0_external = 0.0

;--------------;
; I/O defaults ;
;--------------;
;-->May be misleading. Better to handle defaults in 
;   individual programs?
;; if n_elements(dataName) eq 0 then dataName = 'den1'
;; if n_elements(dataType) eq 0 then dataType = 'ph5'
;; if n_elements(timestep) eq 0 then timestep = 0

;-------------------;
; Graphics defaults ;
;-------------------;
;-->Update these for consistency with the dictionary-based
;   kw approach.
;; if n_elements(kw_image) eq 0 then kw_image = {buffer: 1B}
;; if n_elements(kw_plot) eq 0 then kw_plot = {buffer: 1B}
;; if n_elements(use_clr) eq 0 then use_clr = 0B

;--------------;
; Dictionaries ;
;--------------;
units = dictionary()
units['prefixes'] = hash('Y', 24, $           ;yotta
                         'Z', 21, $           ;zetta
                         'E', 18, $           ;exa
                         'P', 15, $           ;peta
                         'T', 12, $           ;tera
                         'G', 9, $            ;giga
                         'M', 6, $            ;mega
                         'k', 3, $            ;kilo
                         'h', 2, $            ;hecto
                         'da', 1, $           ;deca
                         '', 0, $             ;(unit)
                         'd', -1, $           ;deci
                         'c', -2, $           ;centi
                         'm', -3, $           ;milli
                         '$\mu$', -6, $       ;micro
                         'n', -9, $           ;nano
                         'p', -12, $          ;pico
                         'f', -15, $          ;femto
                         'a', -18, $          ;atto
                         'z', -21, $          ;zepto
                         'y', -24)            ;yocto
units['bases'] = hash('abs_den', '$m^{-3}$', $ ;Absolute density
                      'rel_den', '', $         ;Relative density
                      'phi', 'V', $            ;Electrostatic potential
                      'E', 'V/m')              ;Electric field
