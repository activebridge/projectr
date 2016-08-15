module SSH
  extend ActiveSupport::Concern

  SSH_CONFIG = %(
    Host %{name} github.com
    Hostname github.com
    IdentityFile ~/.ssh/id_rsa.%{name}
  ).freeze

  def generate_ssh
    ssh_path = File.expand_path("~/.ssh/id_rsa.#{name.parameterize}")
    return if File.file?(ssh_path)
    Timeout.timeout(3) do
      `ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa.#{name.parameterize}`
      config = SSH_CONFIG % { name: name.parameterize }
      `echo "#{config}" >> ~/.ssh/config`
    end
  end
end
