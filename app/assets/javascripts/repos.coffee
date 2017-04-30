$(document).on 'change', '#repo_auto_rebase', ->
  $(@.form).submit()

$(document).on 'click', '#link_rebase', ->
  $(@).hide()
  $(@).parents('.action').find('#spinner').show()

$(document).on 'click', '#test_channel', (e) ->
  e.preventDefault()
  input = $('#repo_channel_url')
  if input.val().length == 0
    input.focus()
  else
    $.post($(@).prop('href'), { channel_url: input.val() } )
