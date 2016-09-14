$(document).on 'change', '#repo_auto_rebase', ->
  $(@.form).submit()

$(document).on 'click', '#link_rebase', ->
  $(@).hide()
  $(@).parents('td.body__action').find('#spinner').show()
