class SenderWorker < ApplicationWorker
  STATUSES = %w[success error test].freeze

  def perform(attr)
    attr.symbolize_keys!
    channel_url = attr[:channel_url] || attr[:repo][:channel_url]
    return unless channel_url.present? && STATUSES.include?(attr[:status])
    uri = URI.parse(channel_url)
    return unless uri.respond_to?(:request_uri)
    post_message(uri, attr)
  end

  private

  def post_message(uri, attr)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = params_message(attr).to_json
    http.request(request)
  end

  def params_message(attr)
    {
      username: APPLICATION_TITLE,
      icon_url: I18n.t(:icon_url),
      attachments: attachments(attr)
    }
  end

  def attachments(attr)
    return test_template(attr[:repo]) if attr[:status].eql?('test')
    send "#{attr[:status]}_template", attr[:rebase]
  end

  def success_template(pr)
    [
      {
        color: '#36a64f',
        title: I18n.t(:title_template, number: pr.number),
        title_link: I18n.t(:title_link, repo: pr.repo, number: pr.number),
        text: I18n.t(:message_success, branch: pr.head, base: pr.base),
        mrkdwn_in: ['text']
      }
    ]
  end

  def error_template(pr)
    [
      {
        color: '#d50200',
        title: I18n.t(:title_template, number: pr.number),
        title_link: I18n.t(:title_link, repo: pr.repo, number: pr.number),
        text: I18n.t(:message_error, base: pr.base),
        mrkdwn_in: ['text']
      }
    ]
  end

  def test_template(repo)
    [
      {
        text: I18n.t(:message_test, repo: repo)
      }
    ]
  end
end
