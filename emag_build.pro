;+
; Build the electric-field magnitude from the
; the electrostatic potential. This routine
; will create the full electric field and 
; split it into components if it is not already 
; in memory. The user may wish to delete the
; field or components to recover memory.
;-

;;==Defaults and guards
if n_elements(gridReform) eq 0 then $
   gridReform = [grid.nx,grid.ny,grid.nz,ntMax]
if n_elements(add_E0) eq 0 then add_E0 = 0B
if n_elements(Ex0_external) eq 0 then Ex0_external = 0.0
if n_elements(Ey0_external) eq 0 then Ey0_external = 0.0
if n_elements(Ez0_external) eq 0 then Ez0_external = 0.0
identity = make_array(size(gridReform,/dim),value=1)
if n_elements(phiSW) eq 0 then phiSW = identity
if array_equal(phiSW,identity) then rescale = !NULL
if n_elements(rescale) eq 0 then rescale = 0B

;;==Calculate the electric field if it isn't in memory
if n_elements(Efield) eq 0 then begin
   print, "EMAG_BUILD: Calculating Efield"
   Efield = calc_efield(phi,phiSW, $
                        dx=dx*nout_avg,dy=dy*nout_avg,dz=dz*nout_avg, $
                        rescale=rescale,/verbose)
   phi = reform(phi,gridReform)
endif else print, "EMAG_BUILD: Efield exists in memory"

;;==Split into components and add external field if requested
Ex = 0.0
if tag_exist(Efield,'x',/top_level) then begin
   Ex = reform(Efield.x,gridReform)
   if add_E0 and Ex0_external gt 0.0 then begin
      print, "EMAG_BUILD: Adding Ex0_external = ", $
             string(Ex0_external*1e3,format='(f6.1)'), $
             " mV/m"
      Ex += Ex0_external
   endif
endif
Ey = 0.0
if tag_exist(Efield,'y',/top_level) then begin
   Ey = reform(Efield.y,gridReform)
   if add_E0 and Ey0_external gt 0.0 then begin
      print, "EMAG_BUILD: Adding Ey0_external = ", $
             string(Ey0_external*1e3,format='(f6.1)'), $
             " mV/m"
      Ey += Ey0_external
   endif
endif
Ez = 0.0
if tag_exist(Efield,'z',/top_level) then begin
   Ez = reform(Efield.z,gridReform)
   if add_E0 and Ez0_external gt 0.0 then begin
      print, "EMAG_BUILD: Adding Ez0_external = ", $
             string(Ez0_external*1e3,format='(f6.1)'), $
             " mV/m"
      Ez += Ez0_external
   endif
endif

;;==Calculate magnitude
Emag = sqrt(Ex^2 + Ey^2 + Ez^2)
Emag = reform(Emag,gridReform)

end
