---
title: Troubleshooting Cider
description: How to spot and handle problems with Cider, the project manager for Dyalog APL software authors.
keywords: apl, cider, dotnet, dyalog, link, source, tatin
---

# :fontawesome-solid-bugs: Troubleshooting


??? quote "I don’t mind a reasonable amount of trouble."

	Sam Spade in Dashiel Hammett’s _The Maltese Falcon_



## :fontawesome-solid-eye: How Link watches for changes

To detect changes on the file system, Link uses a .NET File System Watcher.

To detect changes in the workspace, Link uses APL threads.

When you trace through your code, or set a stop vector, and have _Pause on Error_ checked in the session’s _Threads_ menu, handlers associated with those threads will also stop.

The Link handlers set a Hold under some circumstances.
Depending on your actions, this might result in a deadlock. Dyalog would appear to hang until you use the session’s _System_ menu to issue a strong interrupt.


## :fontawesome-solid-download: Updating Cider

If the update process fails for any reason other than network interruptions,
calling it again rarely helps. You need an escape route.

=== "Dyalog v19.0 and later"

	1. Execute `]DeActivate tatin` to remove Cider.
	1. Execute `]Activate cider` to restore the version of Cider your installation originally came with.
	1. Execute `]Cider.UpdateCider` to try to update to the latest version.

=== "Dyalog v18.2"

	Uninstall and then install Cider again.
