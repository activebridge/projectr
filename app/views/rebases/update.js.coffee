$("#pull_<%= @rebase.id %>").attr('class', "pl-<%= @rebase.status %>")
$("#pull_<%= @rebase.id %>").find('td#status').text("<%= @rebase.status %>")
$("#pull_<%= @rebase.id %>").find('#spinner').hide()
if "<%= @rebase.status %>" == 'failure'
  $("#pull_<%= @rebase.id %>").find('#link_rebase').show()
