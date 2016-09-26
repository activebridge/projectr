require 'support/base_page'

class ProjectPage < BasePage
  def open_repo
    find(:link, class: 'list__link').trigger('click')
  end

  def update_repo
    find(:css, '#repo_auto_rebase').set(true)
  end

  def destroy_repo
    find(:link, class: 'link-delete').trigger('click')
  end
end
