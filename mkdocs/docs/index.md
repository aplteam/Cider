# ![Cider logo](img/cider-logo.png){: style="height: 1.8em"} Cider

_Cider is a project manager for Dyalog APL_

A project is

-   the software you publish
-   the files you make it from
-   any imported packages needed

Cider manages projects written in Dyalog APL (with APL source kept as text files) and with imported [Tatin](https://tatin.dev) or [NuGet](https://learn.microsoft.com/en-us/nuget/what-is-nuget) packages.


## Using Cider

You use Cider through its [user commands](user-commands.md).

You identify your project folder (where you keep your APL source files) and any packages your project uses. When you open your project, Cider builds everything in namespaces in the session workspace.
(Code is not stored in saved workspaces.)

Cider assumes your project will have multiple versions, and keeps track of them for you.

You can also use Cider through its API.


## Related tools

Cider cooperates with

-    [Link](https://dyalog.github.io/link), the tool for maintaining the source of functions and other Dyalog APL objects as text files
-    [Tatin](https://tatin.dev), the APL community’s package manager
-    [NuGet](https://www.nuget.org), the package manager for .NET
-    [Git](https://git-scm.com), a version-control system
-    [Dropbox](https://dropbox.com), a file synching service

Cider is designed to work with the Git source control manager, but can also be used with others.


## Requirements

1.  Dyalog Unicode Edition version 18.2 or better
1.  Your APL source kept in text files
1.  Tatin version xx.x or better

Dyalog 19.0 has Cider and Tatin installed.
For Dyalog 18.2, Cider and Tatin have to be installed.


## Terminology

flag
: A flag has value 0 or 1. It is ‘set’ with a value of 1.

string
: A simple character vector (depth 1)

list of strings
: A nested vector of strings (depth 2)