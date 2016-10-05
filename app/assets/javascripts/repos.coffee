$(document).on 'change', '#repo_auto_rebase', ->
  $(@.form).submit()

$(document).on 'click', '#link_rebase', ->
  $(@).hide()
  $(@).parents('.action').find('#spinner').show()
