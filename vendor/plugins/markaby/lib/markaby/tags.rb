module Markaby

  TAGS = [
    :a, :abbr, :acronym, :span, :b, :caption, :del, :cite, :code, :col,
    :colgroup, :dd, :dfn, :dt, :em, :fieldset, :i, :img, :ins, :kbd, :p,
    :label, :legend, :li, :optgroup, :option, :select, :small, :span, :strong,
    :sub, :sup,  :tbody, :td, :textarea, :thead, :title, :th, :tr, :tfoot,
    :tt, :address, :blockquote, :body, :div, :dl, :form, :h1, :h2, :h3, :head,
    :noscript, :object, :ol, :pre, :q, :samp, :script, :style, :table, :ul
  ]

  FORM_TAGS = [ :form, :input, :select, :textarea ]
  SELF_CLOSING_TAGS = [ :hr, :br, :link, :meta, :input ]

end
