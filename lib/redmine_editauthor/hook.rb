module RedmineEditauthor
  module Hook
    class ViewListener < Redmine::Hook::ViewListener
      include IssuesHelper

      # necessary for using content_tag in Listener
      attr_accessor :output_buffer

      def view_issues_form_details_bottom(context = {})
        issue, project = context.values_at(:issue, :project)

        if issue.new_record? && !User.current.allowed_to?(:set_original_issue_author, project) \
          or issue.persisted? && !User.current.allowed_to?(:edit_issue_author, project)
          return
        end

        author = issue.author

        content_tag(:p, id: 'editauthor') do
          authors = project.possible_authors

          authors.unshift(author) if author && !authors.include?(author)

          o = options_from_collection_for_select(authors, 'id', 'name',
                                                 issue.author_id)

          author_select_field(o)
        end
      end

      def view_issues_bulk_edit_details_bottom(context = {})
        project = context[:project]

        return if project && !User.current.allowed_to?(:edit_issue_author, project)

        content_tag(:p, id: 'editauthor') do
          authors = project.possible_authors

          o = content_tag('option', l(:label_no_change_option), :value => '') \
              + options_from_collection_for_select(authors, 'id', 'name')

          author_select_field(o)
        end
      end

      def helper_issues_show_detail_after_setting(context = {})
        d = context[:detail]

        return if d.prop_key != 'author_id'

        d[:value] = find_name_by_reflection('author', d.value)
        d[:old_value] = find_name_by_reflection('author', d.old_value)
      end

      private

      def author_select_field(options)
        label_tag('issue[author_id]', l(:field_author)) \
        + select_tag('issue[author_id]', options) \
        + "<script>$('#editauthor').insertBefore($('#issue_tracker_id').parent());</script>"
            .html_safe
      end
    end
  end
end
