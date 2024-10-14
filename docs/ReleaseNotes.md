[parm]:title             = 'Cider: Release Notes'
[parm]:toc               = 2 2
[parm]:leanpubExtensions = 1


# Release Notes

Cider release notes contain information regarding changes that...

* require action, like renaming stuff in project config files
* change the syntax of a command, like getting rid of a flag, or renaming it

In short, when compatability is affected.

This document does not come with a complete list of fixes, added features etc. Consult [Cider on GitHub](https://github.com/aplteam/Cider/releases) for that.

## Version 0.43.2 from 2024-13

Just bug fixes

## Version 0.43.1 from 2024-09-25

Just bug fixes

## Version 0.43.0 from 2024-09-23

* The `-raw` flag has been removed from the `]ListTatinDependencies` user command

## Version 0.42.4 from 2024-09-07

Just bug fixes

## Version 0.42.3 from 2024-09-05

Just bug fixes

## Version 0.42.2 from 2024-08-04

Just bug fixes


## Version 0.42.1 from 2024-07-12

* So far Cider injected a reference `TatinVars` into a sub-namespace of the project defined by Cider's `tatinVars` property, pointing to `TatinVars` in the root of the project.

  With version 0.42.1 this has changed: in case `tatinVars` specifies a sub-namespace, NO `TatinVars` is injected into the root of the project. Instead, such a namespace is injected into the sub-namespace defined by the `tatinVars` property.

* The `]Cider.ProjectConfig` user command does not have a `-print` flag anymore but an `-edit` flag instead, and by default it prints the content of Cider's global config file to the session.
 
  That brings this user command syntactially in line with another Cider user command (`Config`) and similar Tatin user commands.












