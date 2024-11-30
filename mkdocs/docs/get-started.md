---
title: Get started
description: How to install and activate the Cider project manager for Dyalog APL. How to create and open a blank project.
keywords: apl, command, cider, dyalog, install, link, source, tatin
---

# Get started

!!! abstract "Install and activate Cider; create and open a blank project"

<!-- FIXME Describe creating a project from APL source files -->

## Install

Dyalog version 19 has Tatin and Cider already installed.
Nothing to do here. 

??? info "For Dyalog 18.2 install Tatin and Cider"

	For Dyalog 18.2, first [install Tatin](https://tatin.dev/Assets/docs/InstallingAndUpdatingTheTatinClient.html).

	Then use Tatin to install Cider.

	    ]Tatin.InstallPackages [tatin]Cider <targetFolder>

	where `<targetFolder>` is

	=== ":fontawesome-brands-windows: Windows 32-bit"

			C:\Users\<⎕AN>\Documents\Dyalog APL 18.2 Unicode Files\SessionExtensions\CiderTatin\Cider

	=== ":fontawesome-brands-windows: Windows 64-bit"

			C:\Users\<⎕AN>\Documents\Dyalog APL-64 18.2 Unicode Files\SessionExtensions\CiderTatin\Cider

	=== ":fontawesome-brands-linux: Linux"

			/home/<⎕AN>/dyalog.182U64.files/SessionExtensions/CiderTatin/Cider/

	=== ":fontawesome-brands-apple: macOS"

			/Users/<⎕AN>/dyalog.182U64.files/SessionExtensions/CiderTatin/Cider/


## Activate

Dyalog 19.0 installs with Tatin and Cider, but they are disabled by default.

	]Activate all

Rebuild the user commands.

	]UReset

Restart Dyalog.

Verify. For example,

	      ]TATIN.Version
	 Tatin  0.112.1+1942  2024-08-16 
	      ]CIDER.Version
	0.42.2+671


!!! detail "Your first Cider user command also activates the Cider API."


## Create a blank project

		  ]CIDER.CreateProject <projectpath>

where `<projectpath>` identifies a folder that is empty or does not exist.

Cider creates the folder as a Cider project, with an empty `APLSource` child folder, linked to a new namespace in your active workspace. 

	      ]CIDER.CreateProject /Users/sjt/tmp/myproj

	"/Users/sjt/tmp/myproj" does not exist yet - create? (Y/n) Y

	Project successfully created; open as well? (Y/n) Y
	Link parameter "watch" is <both>
	The current directory is now /Users/sjt/tmp/myproj
	  No Dropbox conflicts found
	Project successfully opened and established in "#.myproj"

Now Link will save APL objects in the `#.myproj` namespace as text files in `APLSource`.

	      )CS myproj
	#.myproj
	      mean←{(+⌿÷≢)⍵}
	      ]LINK.Add mean
	Added: #.myproj.mean


```bash
❯ tree myproj
myproj
├── APLSource
│   └── mean.aplf
└── cider.config
```


## Open your project

Clear the workspace and open the project.

	      )CLEAR
	clear ws
	      ]CIDER.OpenProject /Users/sjt/tmp/myproj
	Link parameter "watch" is <both>
	The current directory is now /Users/sjt/tmp/myproj
	  No Dropbox conflicts found
	Project successfully opened and established in "#.myproj"
	      myproj.mean ⍳20
	10.5

Changes to the objects in `#.myproj` will be mirrored in their source files in `myproj/APLSource`. 
Changes to the source files will be mirrored in the workspace.

When you quit Dyalog your changes have already been saved.

If you have APL source files already written, copy them into the `APLSource` folder.