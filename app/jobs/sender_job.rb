class SenderJob < ApplicationJob
  queue_as :default

  def perform(attr)
    if attr[:status] == 'test'
      return unless attr[:channel_url].present?
      uri = URI.parse(attr[:channel_url])
    else
      uri = URI.parse(attr[:repo][:channel_url])
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = params_message(attr).to_json
    http.request(request)
  end

  private

  def params_message(attr)
    {
      username: 'ProjectR',
      icon_url: I18n.t(:icon_url),
      attachments: attachments(attr)
    }
  end

  def attachments(attr)
    if attr[:status] == 'test'
      test_template(attr[:repo])
    else
      send "#{attr[:status]}_template", attr[:rebase]
    end
  end

  def success_template(pr)
    [
      {
        color: '#36a64f',
        title: I18n.t(:title_template, number: pr.number),
        title_link: I18n.t(:title_link, repo: pr.repo, number: pr.number),
        text: I18n.t(:message_success)
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

  def branch_not_found_template(pr)
    [
      {
        color: '#d50200',
        title: I18n.t(:title_template, number: pr.number),
        title_link: I18n.t(:title_link, repo: pr.repo, number: pr.number),
        text: I18n.t(:message_branch_not_found),
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
