module RedmineEditauthor
  PLUGIN_ID ||= :redmine_editauthor

  PATCHES ||= [
    'Issue'
  ]

  module Settings
    class << self
      def defaults
        Redmine::Plugin.find(PLUGIN_ID).settings[:default] || {}
      end

      def method_missing(method_name)
        s = Setting.method("plugin_#{PLUGIN_ID}")

        name = method_name.to_s.sub('?', '')

        if defaults.include?(name)
          m = {}
          value = defaults[name]

          case value
          when Array
            m[name] = proc { s.call[name] || value }
            m["#{name}?"] = proc { (s.call[name] || value).any? }
          when Integer
            m[name] = proc { v = s.call[name]; v.present? ? v.to_i : value }
          when TrueClass, FalseClass
            p = proc { v = s.call[name]; v ? (!!v == v ? v : v.to_i > 0) : value }
            m[name] = p
            m["#{name}?"] = p
          else
            m[name] = proc { s.call[name] || value }
            m["#{name}?"] = proc { (s.call[name] || value).present? }
          end

          m.each { |k, v| define_singleton_method(k, v) }

          send(method_name)
        else
          super
        end
      end
    end
  end

  def self.patch
    PATCHES.each do |name|
      require File.expand_path("#{self.name.underscore}/patches/#{name.underscore}_patch", __dir__)

      target = name.constantize
      patch = "#{self.name}::Patches::#{name}Patch".constantize

      unless target.included_modules.include?(patch)
        target.send(:include, patch)
      end
    end
  end

  # Users that can be set as author of issues in the given project.
  # With members scope: active members of the project. Otherwise: active
  # members with a role that can add issues, plus active administrators.
  def self.possible_authors(project)
    if Settings.members_scope?
      project.users.sorted
    else
      member_roles = MemberRole.joins(:member)
                       .where(members: { project_id: project.id })

      role_ids = Role.where(id: member_roles.select(:role_id))
                   .select { |role| role.has_permission?(:add_issues) }
                   .map(&:id)

      member_ids = member_roles.where(role_id: role_ids)
                     .select("#{Member.table_name}.user_id")

      User.active.where(id: member_ids)
        .or(User.active.where(admin: true))
        .sorted
    end
  end

  def self.hook
    require File.expand_path("#{self.name.underscore}/hook", __dir__)
  end

  def self.install
    patch
    hook
  end
end
