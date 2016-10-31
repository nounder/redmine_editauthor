require 'redmine_editauthor'

Redmine::Plugin.register :redmine_editauthor do
  name "Redmine Edit Issue Author"
  author "Ralph Gutkowski"
  description "Edit author of issue."
  version '0.9.1'
  url 'https://github.com/rgtk/redmine_editauthor'
  author_url 'https://github.com/rgtk'

  project_module :issue_tracking do
    permission :edit_issue_author, {}
  end
end

RedmineEditauthor.install
