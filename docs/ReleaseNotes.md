[parm]:title             = 'Cider: Release Notes'
[parm]:toc               = 2 2
[parm]:leanpubExtensions = 1


# Release Notes

Cider release notes contain information regarding actions that need to be executed before a new version can be used, or important pieces of information regarding changes.

This document does not come with a complete list of fixes, added features etc. Consult [Cider on GitHub](https://github.com/aplteam/Cider) for that.

## Version 0.42.1 from 2024-07-07

* So far Cider injected a reference `TatinVars` into a sub-namespace of the project defined by Cider's `tatinVars` property, pointing to `TatinVars` in the root of the project.

  With version 0.42.1 this has changed: in case `tatinVars` specifies a sub-namespace no `TatinVars` is injected into the root of the project. Instead, such a namespace is injected into the sub-namespace defined by the `tatinVars` property.

* The `]Cider.Config` user command does not have a `print` flag anymore but an `-edit` flag instead, and by default it prints the content of Cider's global config file to the session.
 
  That brings this user command syntactially in line with other Cider and Tatin user commands.



