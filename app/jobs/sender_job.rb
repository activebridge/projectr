class SenderJob < ApplicationJob
  queue_as :default

  def perform(pr, status)
    uri = URI.parse(ENV['slack_webhook'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = params_message(pr, status).to_json
    http.request(request)
  end

  private

  def params_message(pr, status)
    {
      channel: 'projectr',
      username: 'ProjectR',
      icon_emoji: ':projectr:',
      attachments: attachments(pr, status)
    }
  end

  def attachments(pr, status)
    if status == 'success'
      success_template(pr)
    else
      error_template(pr)
    end
  end

  def success_template(pr)
    [
      {
        color: '#36a64f',
        title: "Pull Request ##{pr.number}",
        title_link: "https://github.com/#{pr.repo}/pull/#{pr.number}",
        text: I18n.t('message.success')
      }
    ]
  end

  def error_template(pr)
    [
      {
        color: '#d50200',
        title: "Pull Request ##{pr.number}",
        title_link: "https://github.com/#{pr.repo}/pull/#{pr.number}",
        text: I18n.t('message.error'),
        mrkdwn_in: ['text']
      }
    ]
  end
end
