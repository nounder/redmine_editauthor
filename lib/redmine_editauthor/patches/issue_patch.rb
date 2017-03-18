module RedmineEditauthor
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          safe_attributes 'author_id',
                          :if => proc { |issue, user|
            issue.new_record? && user.allowed_to?(:set_original_issue_author,
                                                  issue.project) \
            or issue.persisted? && user.allowed_to?(:edit_issue_author, issue.project)
          }
        end
      end
    end
  end
end
