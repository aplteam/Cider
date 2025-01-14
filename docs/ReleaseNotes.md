[parm]:title             = 'Cider: Release Notes'
[parm]:toc               = 2 2
[parm]:leanpubExtensions = 1


# Release Notes

Cider release notes contain information regarding changes that...

* require action, like renaming stuff in project config files
* change the syntax of a command, like getting rid of a flag, or renaming it

In short, when compatability is affected.

This document does not come with a complete list of fixes, added features etc. Consult [Cider on GitHub](https://github.com/aplteam/Cider/releases) for that.

## Version 0.46.0 from 2025-01-14

* Prior to version 0.46.0, Cider would look for a file `.linkconfig` in the source folder. If there is one, it ignored a `LINK` section in Cider's project config file and informed the user about this. In addition Cider recommended to the user to remove the `Link` section from the Cider config file.

  There is a problem with that: Link would create such a file in case there are any Stop- or Trace vectors set on any function or operator. For that reason Cider 0.46.0 checks whether the file `.linkconfig` contains nothing but those settings (plus the Link version number the file was written by). If that's the case, Cider now ignores the file and evaluates the LINK section in the project config files. It would also recommend to reconcile the two sources of Link settings, and get rid of the LINK section in the project config file.

* The user command `]Cider.Make` was renamed; it's now `]Cider.HowToMakeNewVersion`
* The user command `]Cider.RunTests` was renamed; it's now `]Cider.HowToRunTests`

* Several bug fixes

## Version 0.45.0 from 2024-12-09

* `]UpdateCider` now allows to replace the current version by a particular version
* The Dropbox check is now mandatory when not configured in case there is a folder `Dropbox/` in the user's home folder
* A couple of bug fixes

## Version 0.44.0 from 2024-11-16

* `]OpenProject`'s reporting on Git enhanced and streamlined
* Some bug fixes

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



















