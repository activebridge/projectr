class Github
  def initialize(rebase)
    @rebase = rebase
  end

  def rebase
    `git clone git@#{@rebase.repo.parameterize}:#{@rebase.repo}.git ./#{@rebase.repo}` unless File.exist?("./#{@rebase.repo}")
    `cd ./#{@rebase.repo} && git pull origin`
    `cd ./#{@rebase.repo} && git checkout #{@rebase.head}`
    output = `cd ./#{@rebase.repo} && git rebase origin/#{@rebase.base}`
    `cd ./#{@rebase.repo} && git rebase --abort`
    return 'conflict' unless output.exclude?('CONFLICT')
    return 'fail' if output.exclude?('is up to date')
  end

  def push
    `cd ./#{@rebase.repo} && git checkout #{@rebase.head}`
    `cd ./#{@rebase.repo} && git fetch`
    `cd ./#{@rebase.repo} && git rebase origin/#{@rebase.base}`
    output = `cd ./#{@rebase.repo} && git push origin #{@rebase.head} --force-with-lease --porcelain`
    sha = `cd ./#{@rebase.repo} && git rev-parse HEAD`
    return sha if output.match(/(forced update|up to date)/)
  end
end
