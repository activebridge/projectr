$("#pull_<%= @rebase.id %>").attr('class', "pl-<%= @rebase.status %>")
$("#pull_<%= @rebase.id %>").parents().find('.action').hide()
if "<%= @rebase.status %>" == 'failure'
  $("#pull_<%= @rebase.id %>").find('#link_rebase').show()
