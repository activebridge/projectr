$(document).on 'change', '#repo_auto_rebase', ->
  $(@.form).submit()

$(document).on 'click', '#link_rebase', ->
  $(@).hide()
  $(@).parents('.action').find('#spinner').show()

$(document).on 'keyup', '#repo_channel_url', ->
  href = $('#test_channel').prop('href')
  $('#test_channel').attr('href', href + "?channel_url=#{$('#repo_channel_url').val()}")

$(document).on 'click', '#test_channel', (e) ->
  if $('#repo_channel_url').val().length == 0
    $('#repo_channel_url').focus()
