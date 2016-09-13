$("#pull_<%= @rebase.id %>").attr('class', "pl-<%= @rebase.status %>")
$("#pull_<%= @rebase.id %>").find('td#status').text("<%= @rebase.status %>")
$("#pull_<%= @rebase.id %>").find('td#rebase').text('')
