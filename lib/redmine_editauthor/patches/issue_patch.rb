module RedmineEditauthor
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          safe_attributes 'author_id',
                          :if => proc { |issue, user| (user.allowed_to?(:edit_issue_author, issue.project))}
        end
      end
    end
  end
end
