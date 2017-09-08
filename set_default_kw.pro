;+
; Set the default keywords for making graphics of <name>.
; The user should call this function, then make project-specific
; changes to the kw struct in a project.eppic file that lives in
; a subdirectory of ~/projects/.
;
; NAME: The names of the quantities for which to set up keywords.
;       Possible names include simulated quantities (e.g. den1 or
;       phi) or quantities derived therefrom (e.g. emag or fft).
;       See data_kw_* for currently available quantities and edit
;       data_kw_* to add a new name.
; TO DO
;-
function set_default_kw, name, $
                         image=image,colorbar=colorbar,text=text, $
                         _EXTRA=ex

  if isa(name,'list') then kw = dictionary(name.toarray()) $
  else kw = dictionary(name)
  kw_keys = list()
  if keyword_set(image) then kw_keys.add, 'image'
  if keyword_set(colorbar) then kw_keys.add, 'colorbar'
  if keyword_set(text) then kw_keys.add, 'text'
  for id=0,kw.count()-1 do kw[name[id]] = dictionary(kw_keys.toarray())
  if keyword_set(image) then data_kw_image, name,kw,_EXTRA=ex
  if keyword_set(colorbar) then data_kw_colorbar, name,kw,_EXTRA=ex
  if keyword_set(text) then data_kw_text, name,kw,_EXTRA=ex

  return, kw
end
