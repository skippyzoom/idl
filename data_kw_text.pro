;+
; Set default keyword parameters for text on images
; of simulation data.
;-
pro data_kw_text, name,kw,prj=prj,global_colorbar=global_colorbar
@eppic_defaults.pro

  text = dictionary()
  kw[name[id]].text = text[*]
end

