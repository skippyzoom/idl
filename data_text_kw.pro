;+
; Set default keyword parameters for text on images
; of simulation data.
;-
function data_text_kw, prj=prj,global=global
@eppic_defaults.pro

  if n_elements(kw) eq 0 then kw = create_struct('text',text) $
  else kw = create_struct(kw,'text',text)

  return, kw
end

