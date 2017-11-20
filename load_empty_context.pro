;+
; Load an empty instance of the default project context
; dictionary. This simply builds as many dictionaries as
; necessary for the user to populate with other types
; (e.g., numbers, strings, lists).
;-

function load_empty_context

  ;; ;;==Top level
  ;; context = dictionary('data', dictionary(), $
  ;;                      'graphics', dictionary())

  ;; ;;==DATA level
  ;; context.data.scale = dictionary()

  ;; ;;==GRAPHICS level
  ;; context.graphics.rgb_table = dictionary()
  ;; context.graphics.class = dictionary()
  ;; context.graphics.plane = dictionary()
  ;; context.graphics.image = dictionary()
  ;; context.graphics.axes = dictionary()
  ;; context.graphics.colorbar = dictionary()
  ;; context.graphics.movie = dictionary()
  ;; ;;==graphics/AXES level
  ;; context.graphics.axes.x = dictionary('title', dictionary)
  ;; context.graphics.axes.y = dictionary('title', dictionary)
  ;; context.graphics.axes.z = dictionary('title', dictionary)

  ;; ;;==PANEL level
  ;; context.panel.index = dictionary()
  ;; context.panel.layout = dictionary()


  context = dictionary('data', dictionary('scale', dictionary()), $
                       'graphics', dictionary('rgb_table', dictionary(), $
                                              'class', dictionary(), $
                                              'plane', dictionary(), $
                                              'image', dictionary(), $
                                              'axes', dictionary('x', dictionary(), $
                                                                 'y', dictionary(), $
                                                                 'z', dictionary()), $
                                              'colorbar', dictionary(), $
                                              'movie', dictionary()), $
                       'panel', dictionary('index', dictionary(), $
                                           'layout', dictionary() $
                                          ) $
                      )

  return, context
end
