class Github
  def initialize(rebase)
    @rebase = rebase
  end

  def rebase
    `rm -rf #{@rebase.repo}`
    `git clone git@#{@rebase.repository_name.parameterize}:#{@rebase.repository_name}.git ./#{@rebase.repo}`
    `cd ./#{@rebase.repo} && git checkout #{@rebase.head}`
    output = `cd ./#{@rebase.repo} && git rebase origin/#{@rebase.base}`
    output.exclude?('is up to date')
  end

  def push
    `cd ./#{@rebase.repo} && git checkout #{@rebase.head}`
    `cd ./#{@rebase.repo} && git rebase origin/#{@rebase.base}`
    output = `cd ./#{@rebase.repo} && git push origin #{@rebase.head} --force-with-lease --porcelain`
    sha = `cd ./#{@rebase.repo} && git rev-parse HEAD`
    return sha if output.match(/(forced update|up to date)/)
  end
end
