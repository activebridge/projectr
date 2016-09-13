$(document).on 'change', '#repo_auto_rebase', ->
  $(@.form).submit()

$(document).on 'click', '#link_rebase', ->
  $(@).hide()
  $(@).parents('td#rebase').find('#spinner').show()
