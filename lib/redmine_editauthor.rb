module RedmineEditauthor
  PATCHES = [
    'Issue',
    'Project'
  ]

  def self.patch
    PATCHES.each do |name|
      require "#{self.name.underscore}/patches/#{name.underscore}_patch"

      target = name.constantize
      patch = "#{self.name}::Patches::#{name}Patch".constantize

      unless target.included_modules.include?(patch)
        target.send(:include, patch)
      end
    end
  end

  def self.hook
    require_dependency "#{self.name.underscore}/hook"
  end

  def self.install
    patch
    hook
  end
end
