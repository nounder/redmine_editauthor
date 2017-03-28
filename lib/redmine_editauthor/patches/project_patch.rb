module RedmineEditauthor
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :reload, :editauthor
        end
      end

      module InstanceMethods
        def possible_authors
          return @possible_authors if @possible_authors

          @possible_authors = User.active.eager_load(:members).where(
            "#{Member.table_name}.project_id = ? OR #{User.table_name}.admin = ?",
            id, true
          ).select { |u| u.allowed_to?(:add_issues, self) }
        end

        def reload_with_editauthor(*args)
          @possible_authors = nil
          reload_without_editauthor(*args)
        end 
      end
    end
  end
end
