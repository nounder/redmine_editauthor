# Redmine Edit Issue Author

Redmine plugin that allows to change issue author.


## Installation

Follow standard Redmine plugin installation procedure.

 * Move `redmine_editauthor/` to `$REDMINE/plugins/`.


## Configuration

#### Permissions

This plugin provides 2 permissions:

 * *Edit author* allows to edit author of existing issue.
 * *Set original author* allows to set author when creating new issue.

Authorized users will be able to see author field and change its value in issue
form.
    

#### Possible authors
 
 By default users with global permissions such as administrators will be
 listed even if they are not participants of the project. It is possible to
 narrow possible authors to project members in plugin settings.


## Requirements

This plugin has been written with compatibility in mind to keep it
functional across many different versions of Redmine:

  * Redmine (2.0+)
  * Redmine (3.0+)
