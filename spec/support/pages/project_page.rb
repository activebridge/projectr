require 'support/base_page'

class ProjectPage < BasePage
  def open_repo
    find(:link, class: 'link').trigger('click')
  end

  def update_repo
    find('#repo_auto_rebase', visible: false).trigger('click')
  end

  def destroy_repo
    find(:link, class: 'link-delete').trigger('click')
  end
end
