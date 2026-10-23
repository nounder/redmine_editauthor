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

          validate :validate_editauthor_author
        end

        base.prepend InstanceMethods
      end

      module InstanceMethods
        # Remember whether the author was changed by the user, so that
        # authors set by Redmine itself (new issues, emails, ...) are not
        # validated against the list of possible authors.
        def safe_attributes=(attrs, user = User.current)
          author_id_before = author_id
          super
          @editauthor_author_set ||= author_id != author_id_before
        end

        private

        def validate_editauthor_author
          return unless @editauthor_author_set && author_id_changed?
          return if project.nil? || author_id.nil?

          unless RedmineEditauthor.possible_authors(project).where(id: author_id).exists?
            errors.add :author_id, :inclusion
          end
        end
      end
    end
  end
end
