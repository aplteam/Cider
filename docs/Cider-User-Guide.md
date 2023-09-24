[parm]:title             = 'Cider User Guide'
[parm]:leanpubExtensions = 1
[parm]:numberHeaders     = 2 3 4 5 6
[parm]:toc               = 2 3 4 5 6



# Cider User Guide

## What is Cider for?

In this document, we use the word "project" for an application or a tool that consists not only of what is finally delivered, like an Installer EXE under Windows or a Tatin package or a workspace or whatnot, but also of stuff that is required only during development, like test cases and test data, tools, helpers etc.

While LINK is perfect for bringing stuff into the workspace, putting together an environment in which development can take place requires more than just that. Something is missing...

## The solution

Cider attempts to fill that gap. A Cider project requires a configuration file named `cider.config`. 

The two most important commands of Cider's user commands are `CreateProject` and `OpenProject`.

I> Note that in this document names stemming from the Cider configuration file are shown `like this`.

### Requirements

#### APL Version

The first version you can use Cider with is 18.0. This is because Cider is a Tatin package, and Tatin runs under 18.0 or later.

#### Tatin

Cider relies on the [Tatin package manager](https://github.com/aplteam/Tatin "Link to Tatin on GitHub") because it is a Tatin package. With version 19.0 and later Tatin will optionally be available in `⎕SE` right from the start. With earlier versions (18.0 and 18.2) it's up to the user to take care of that.

If Tatin is not in `⎕SE` but available in the user's home folder then Cider will attempt to load it by executing the user command `]Tatin.Version` which should implicitly load Tatin into `⎕SE`.

I> Note that Tatin will check whether Cider is available, and if so cooperate with it. However, Cider is not a requirement for using Tatin.

#### Git

If you use Git for version control management and you have the [Git Bash](https://git-scm.com/downloads "Link to the Git Bash download page") installed then Cider uses the package [`APLGit2`](https://github.com/aplteam/APLGit2 "Link to APLGit2 on GitHub") for communicating with Git. 

For example, when a project carries a directory `.git/` then Cider knows that the project is version controlled with Git, and it therefore uses the API of `APLGit2` to display the Git status report for a project in the later stages of opening a project.

### Installation

With version 19.0, Cider will be part of a default installation, though it won't be active: for that the user has to take action. 

In earlier versions you must install Cider yourself.

#### Version 19.0

Version 19.0 comes with both Tatin and Cider, but neither is active by default.

In order to activate them, the folder `[DYALOG]/Experimental/CiderTatin` needs to be copied into one of the following folders:

##### Windows

```
C:\Users\<⎕AN>\Documents\Dyalog APL 19.0 Unicode Files\StartupSession\     ⍝ 32-bit
C:\Users\<⎕AN>\Documents\Dyalog APL-64 19.0 Unicode Files\StartupSession\  ⍝ 64-bit
C:\Users\<⎕AN>\Documents\Dyalog APL Files\StartupSession\                  ⍝ version agnostic
```


It is up to the user to choose a target folder: either an appropriate version-specific folder (first or second) or a version-agnostic folder (third).

Once the folder `CiderTatin/` is in place, any newly started version of Dyalog comes with the user commands `]Tatin.*` as well as `]Cider.*`; the APIs are both available via `⎕SE.Tatin` and `⎕SE.Cider`.

##### Linux

```
/home/<⎕AN>/dyalog.190U32.files ⍝ 32-bit
/home/<⎕AN>/dyalog.190U64.files ⍝ 64-bit
/home/<⎕AN>/dyalog.files        ⍝ version agnostic
```

It is up to the user to choose a target folder: either an appropriate version-specific folder (first or second) or a version-agnostic folder (third).

Note that your intended target directory might not exist yet.

Once the folder `CiderTatin/` is in place, any newly started version of Dyalog comes with the user commands `]Tatin.*` as well as `]Cider.*`; the APIs are both available via `⎕SE.Tatin` and `⎕SE.Cider`.

##### Mac OS

```
/Users/<⎕AN>/dyalog.190U32.files ⍝ 32-bit
/Users/<⎕AN>/dyalog.190U64.files ⍝ 64-bit
/Users/<⎕AN>/dyalog.files        ⍝ version agnostic
```

It is up to the user to choose a target folder: either an appropriate version-specific folder (first or second) or a version-agnostic folder (third).

Note that your intended target directory might not exist yet.

Once the folder `CiderTatin/` is in place, any newly started version of Dyalog comes with the user commands `]Tatin.*` as well as `]Cider.*`; the APIs are both available via `⎕SE.Tatin` and `⎕SE.Cider`.


#### Version 18.0 and 18.2

Unlike 19.0, these versions don't come with neither Tatin and Cider, so you first have to make sure that Tatin is installed and available.

<https://tatin.dev/> provides instructions for how to install Tatin on 18.0 and 18.2.

Once Tatin is available, installing Cider is easy and straightforward, just issue this command:

```
]Tatin.InstallPackages [tatin]Cider [PROGRAM_FILES_32]
]Tatin.InstallPackages [tatin]Cider [PROGRAM_FILES_64]
]Tatin.InstallPackages [tatin]Cider [PROGRAM_FILES]
```

Once the folder `CiderTatin/` is in place, any newly started version of Dyalog is aware of the user commands `]Tatin.*` and `]Cider.*`.

The APIs are not available yet at this point, but they will become available once a user command is issued. For example, after issuing the following two commands the APIs will both be available via `⎕SE.Tatin` and `⎕SE.Cider`:

```
]Tatin.Version
]Cider.Version
```

If that is not good enough for you (because you want the API to be available right from the start) this article explains how to load stuff into `⎕SE` at a very early stage: <https://aplwiki.com/wiki/Dyalog_User_Commands>

### Upgrading Cider

You can update Cider to the latest version by issuing the following command:

```
]Cider.UpdateCider
```
    
You must restart Dyalog in order to start using the new version.

### Configuration

#### Global configuration

Cider may have a global configuration file that can be used to define settings that effect all projects. It's named is `cider.json`, and it is referred to as the _global_ Cider config file.

This file, if it exists, it situated in a folder `.cider` that lives in the user's home folder on all platforms. For example, for a user JohnDoe the path would be C:\Users\JohnDoe\.cider on Windows, on Linux it would be /home/JohnDoe/.cider etc.

This folder does not only host the global config file, it's also the place where the file with alias definitions (`aliase.txt`) is saved as well as the file `cider.config.template` that is used as a template when a new project is created.

#### Project configuration

Every Cider project has a configuration file called `cider.config` that is saved in the root of the project's folder.

When a new project is created, a copy of the file `cider.config.template` is copied from the global configuration folder (see above) into the root of the new project.


### CreateProject

With `]Cider.CreateProject` any folder that does not yet host a file `cider.config` can be transformed into a Cider project. (You may specify the `-acceptConfig` flag to override this default behaviour and make Cider accept an already existing file `cider.config`)

If the folder does not yet exist it will be created. In any case, the folder will be populated with a file `cider.config`.

I> The default config file that is copied into any new project stems from a folder `.cider/` in your home directory. 
I>
I> You may change this file and make amendments that suit your needs. 
I>
I> However, when a new version of Cider is installed the template config file *might* come with new or renamed or removed properties, and those would not make it into the template file in `.cider/cider.config` in your home directory: watch the release notes for this.

Note that `]Cider.CreateProject` deals differently with the possible combinations of namespace and source folder:

* The namespace and the source folder are both empty
* The namespace is empty and the source folder is not
* The source folder is empty and the namespace is not

In all these cases it should be pretty obvious what `]Cider.CreateProject` will do.

However, when the namespace and source folder are _both not empty_ then the user will be asked whether the contents of the namespace should be deleted because that might well make sense. 

If the user answers this question with "No" then an error is thrown.

#### Configuration parameters

The Cider configuration file comes with four sections:

* CIDER
* LINK
* SYSVARS
* USER

We will discuss the settings in each section in detail.

##### CIDER

This section discusses the Cider-specific parameters in alphabetical order.


###### distributionFolder

Has no default. If it is not empty it is supposed to be a folder, usually relative to the root of the project. Tatin's `BuildPackage` function would use this property in order to save the resulting ZIP file in this folder in case no specific target folder was specified.

If you create all your package ZIP files always in the same sub-folder of any project then you can define this in Cider's project config template file in order to make sure that it will always default to that folder name: Tatin's `BuildPackage` function, when not provided with a target folder, would check whether the project is managed by Cider and has a non-empty property `distributionFolder` defined, and if so take that as the target folder.


###### parent

Defaults to `#` but can be something like `⎕SE` or `#.MyNamespace1.MyNamespace2`. 

Note that all namespaces specified as `parent` _must already exist_, otherwise an error is thrown.

With the user command, this can be overwritten temporarily with, say:

```
]Cider.OpenProject {path} -parent=#.MyProjects
```

###### projectSpace

The name of a namespace that will host the project. *Must* be set by the user in the config file.

With the user command, this can be overwritten temporarily with, say:

```
]Cider.OpenProject {path} -projectspace=Foo
```    

###### source

Defaults to `APLSource`: a subfolder that hosts the code. That's where the code lives, relative to the project folder. 

This might be empty, for example when the project is just a single script (class or namespace).

###### dependencies

This carries two sub-keys: "tatin" and "nuget". This is how the template config file looks like:

```
dependencies: {
    tatin: "tatin-packages",
    nuget: "nuget-packages",
    },
```

The sub-key "tatin" defaults to "tatin-packages", which must be a folder in the root of the project the resulting package or application depends on. 

This makes Cider load all Tatin and NuGet packages that are installed in the project's subfolder "tatin-packages" and "nuget-packages" respectively into the namespace that hosts the project.

In case you don't want the packages to be loaded into the root of the project but a sub-namespace, say "Foo"/"Goo":

```
dependencies: {
    tatin: "tatin-packages=Foo",
    nuget: "nuget-packages=Goo",
    },
```

I> You may add your own sub-keys in addition to "tatin", but Cider will ignore them: you have to put them to good use yourself.

###### dependencies_dev

In principle this is the same as `dependencies`, but it regards dependencies that are only required for development and testing, not for producing the final result, be it a package or an application.

For that reason those dependencies are more often than not expected to be loaded into a sub-namespace of the project:

```
dependencies_dev: {
    tatin: "tatin-packages_dev=Testcases",
    },
```

All packages in the sub-folder tatin-packages_dev/ are loaded into the sub-namespace `Testcases`

However, note that you cannot have a sub-key "nuget" in "dependencies_dev".

###### init

If not empty this must be the name of a function within `projectSpace`. The function will be executed after a project was opened. 

Such a function should not return a result; if it does anyway it should be shy.

Such a function may be niladic, monadic or ambivalent:

* A niladic function is just called
* An ambivalent or monadic function receives a namespace with the project configuration as right argument 


###### make

Empty or an expression (relative to the project) that would create a new version of the project.

The purpose is to tell anybody not familiar with the project how to create a new version by entering:

```
      ]Cider.Make
#.Cider.Admin.Make 1 ⍝ Execute this for creating a new version
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.make` and the comment is then added.

However, if the first non-white space character of `make` is a `]` its definition would just be printed to the session together with a comment because then it's obviously a user command.


###### project_url

If not empty this is expected to be a URL pointing to, say, a GitHub project. For information only.

Note that Cider cooperates with the package [`APLGit2`](https://github.com/aplteam/APLGit2 title="Link to APLGit2 on GitHub") if that is available in `⎕SE`. `APLGit2` is an interface between Dyalog and Git, although some of its commands will only work when the project is hosted on GitHub.

Some function of `APLGit2` must know the `owner` of a project on GitHub. Those functions will investigate project_url`: if that points to GitHub, the owner is established from its contents.


###### tests

Empty or an expression (relative to the project) that would execute the test cases of the project.

The purpose is to tell anybody not familiar with the project how to execute the test cases by entering:

```
      ]Cider.RunTests
#.Cider.TestCases.RunTests ⍝ Execute this for running the test suite
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.tests`, and the comment is then added.

However, if the first non-white space character of `tests` is a `]` (making it a user command rather than a function call) its definition would just be printed to the session together with a comment because then it's obviously a user command.

##### LINK

These are LINK parameters which are passed on to LINK when Cider brings the APL code into the WS with LINK.

Note that this is a temporary solution: LINK should have its own config files for this, and will get them with Link 4.0. 

However, until all supported versions of Link can deal with Link's own configuration file, Cider will save non-defaults values in a Cider project config file.

###### watch

Defaults to "both" but can be "ns" or "dir" as well. 

Defines which source to track for changes, so the other can be synchronised.

Note that for "both" and "dir" .NET or .NET Core is required. Under Windows this is a given, but not so on Linux and Mac-OS: it may or may not be available. If it is not, the default for "watch" will be "ns".

##### SYSVARS

This section allows you to define system variables. `⎕IO` and `⎕ML` should always be defined here.

You may add other `⎕`-variables here like, say, `⎕CT` as "ct" etc.
            

###### io

Defaults to 1.


###### ml

Defaults to 1.


#####  USER

This section allows you to specify your own project-specific values; its contents (if any) is ignored by Cider.

This is an example:

```
USER: {                                   
   "Foo": 1,                 
    },
}
},
````

After opening the project into, say, `#.MyProject` the value is accessible via

```
#.MyProject.CiderConfig.USER.Foo
```

### OpenProject

Naturally, `OpenProject` is the most important command Cider offers. We discuss all its actions in detail.

Note that the contents of the file `cider.config` directs what exactly Cider is going to do when its principal method, `OpenProject`, is executed.

#### 1. Creating a project space

The first step carried out by `]Cider.OpenProject` is to create a namespace with the name `projectSpace` as a child of `parent`, when `parent` defaults to `#` but may be something like `⎕SE` or `#.Foo.Goo` etc.

The `parent` must exist while the `parentSpace` may or may not exist. If it does not, it is created. If it does already exist then:

* In case the namespace and the folder are both empty Cider carries on
* In case only the namespace is empty Cider carries on
* In case only the folder is empty Cider carries on
* In case neither the namespace nor the folder is empty the user is asked whether she wants the namespace to be emptied; if not an error is thrown.


#### 2. Setting system variables

In the next step `]Cider.OpenProject` is going to set at least two system variables defined in the config file in the `SYSVARS` section of the INI file: `⎕IO` and `⎕ML`.

It is important to set these variables before code is brought into the workspace because bringing class scripts or namespace scripts into the workspace implies potentially the execution of code, and that code might well rely on the correct setting of those system variables.

If you need other system variables to carry specific values then you may add them to the `SYSVARS` section. 

Note that the names are not case sensitive: whether the value for `⎕FR` is specified as  "fr" or "FR" or "Fr" or "fR" does not matter.

In case a setting in `SYSVARS` cannot be used for assigning a system variable a warning message will be printed to the session.

A> ### System variables
A>
A> Feel free to save system variables in files like `⎕IO.apla` in your source folder. 
A>
A> That's another way to make sure that system variables are set as early as possible because LINK will establish the values of system variables defined in files before it attempts to bring code into the workspace.


#### 3. Bringing the code into the workspace

In this step, all files with supported file extensions (See LINK's documentation for details) found in `source` and any subfolder are established in the workspace in `{parent}. {projectSpace}`.

To achieve this Cider uses LINK[^link]. 

Note that from now on we will refer to:

`{parent}.{projectSpace}` as _the root of a project_.

By default, a link is established between the root of the project and the folder. When you intend to work on the project (read: change the code) then this is the obvious thing to do.

A> ### LINK's `watch` parameter
A>
A> By default Cider sets the `watch` parameter to "both", meaning that changes in the workspace via the editor are saved to disk, and any changes on disk are brought into the workspace. 
A>
A> You may set `watch` to "ns" or "dir" instead. Refer to the LINK documentation for details.


However, if you want to bring in the code as part of, say, an automated build process, then you don't want to establish a link, you just want to bring the code into the workspace. This can be achieved by specifying the `-import` flag.


#### 4. Check for empty package folders

Cider now checks whether any of the Tatin installation folders --- as noted on the `dependencies` and `dependencies_dev` properties --- is empty apart from a dependency file and a build list.

A> ### Why this may happen
A>
A> Since version 0.21.0 Cider itself has an enhanced `.gitignore` file: it defines that the contents of the Tatin installation folder(s) but the two definition files shall be ignored. Only these two definition files are therefore uploaded to GitHub, but _none of the packages_.
A>
A> The effect of this is that when somebody downloads the Cider project now _the Tatin installation folder contains just those two definition files but no packages!_
A>
A> Note that this is in line with the vast majority of other package managers.

In case a Tatin installation folder defined in the Cider config file does not contain any packages but the two definition files, the user will be asked whether she wants to re-install the packages. 


#### 5. Check for later packages versions

In case the project has Tatin packages installed in one or more folders the user will be asked whether she wants Cider to check for any later versions of any of the principal packages. This will only happen in case `importFlag` is 0.

However, note that this is only true if you've loaded the package(s) from a Tatin Registry that is in your config file _and_ has a priority greater than 0. Refer to the Tatin documentation for details.

If `]Cider.OpenProject` discovers later packages it will ask the user whether these packages shall be re-installed with the `-update` flag set. This will happen independently for each package installation folder.


#### 6. Loading Tatin packages
 
Your application or tool might depend on one or more Tatin[^tatin] packages. By assigning a folder hosting Tatin packages to the `tatin` sub-key in `dependencies` and potentially `dependencies_dev` you can make sure that Cider will load[^load_tatin_pkgs] those installed packages into the root of your project or the assigned sub-namespace.

See the config properties `dependencies` and `dependencies_dev` for details.


#### 7. Loading NuGet packages
 
Your application or tool might depend on a NuGet[^nuget] package. By assigning a folder hosting NuGet packages to the `nuget` sub-key in `dependencies` you can make sure that Cider will load those installed packages into the root of your project or the assigned sub-namespace.

See the config property `dependencies` details.

Note that NuGet packages can currently become part of your application, but they cannot be loaded as development tools. This restriction might be lifted in a later release.


#### 8. Injecting a namespace `CiderConfig`

In this step `]Cider.OpenProject` injects a namespace `CiderConfig` into the project space and...

* populates it with the contents of the configuration file as an APL array
* adds a variable `HOME` that remembers the path the project was loaded from


#### 9. Injecting a namespace `TatinVars`

If the project becomes eventually a package, Cider injects a namespace `TatinVars` which contains exactly the same stuff as if it were loaded as a package.

This allows a developer to access `TatinVars` as if it was loaded as a package while working on the project.

Whether the project ends up as a package is determined by the presencse of a file `apl-package.json` in the root of the project.


#### 10. Initialising a project (optional)

Now there might well be demand for executing some code to initialise your project.

This can be achieved by assigning the name of a function to `init`. This must again be relative to the root of your project.

The function should not return a result. If it does anyway it should be shy. Any result would be ignored.

Such a function may be niladic, monadic, ambivalent or dyadic:

* A non-niladic function receives a namespace with the project configuration as right argument 
* An ambivalent or dyadic function receives a path as left argument: this is the home folder of the project


#### 11. Executing user-specific code

You might want to execute some general code (as opposed to project-specific code) after a project was loaded. "General" means that this code is executed whenever a project (any project!) is opened. 

This can be achieved by specifying the fully qualified name of a function that must be monadic, most likely in `⎕SE`. A namespace with the configuration data of the project is passed as the right argument.

The function may or may not return a result, but when it does the result will be discarded.

The fully qualified name of the function must go into the file that is returned by the function `GetCiderGlobalConfigFilename` which is available only via the API, not as a user command. This is the Cider config file, not a Cider project config file.

That file already contains a definition of the keyword `ExecuteAfterProjectOpen`, but it is empty:

```
{
    ExecuteAfterProjectOpen: "",
}
```

What is this application for this you may ask. Well, let's assume that you are not using Git but a different version control software. With Git, Cider would execute the "status" command and show the result to the user. With your version control software, it can't do something similar because it does not know what to do.

You can easily achieve that by yourself: just add the required code to a function you load early into `⎕SE`, and then make sure that `ExecuteAfterProjectOpen` is calling that function and you are done.

Another application could be to bring in non-Tatin dependencies defined in the `dependencies` and/or the `dependencies_dev` properties.

Note that you may use the `ignoreUserExec` flag to tell `OpenProject` to ignore the global setting. This is certainly useful when Cider's test suite is executed.


#### 12. Check for `ToDo`

Finally Cider checks whether there is a variables `ToDo` in the root of your project that is not empty. If that's the case then the contents of that variable is printed to the session.

You may use this to keep track of steps that need to be executed before the project can be commited or published etc.


#### 13. Git

If the project is managed by Git then Cider will report the current branch and its status.


## Misc

Cider offers helpers that are useful in particular circumstances.


### AddTatinDependencies

This requires at least a comma-separated list of Tatin packages to be added to a project.

A second (optional) argument, if specified, must be either a path to a Cider project or a Cider project alias.

If the second argument is omitted Cider acts an any open project. If there is more than one project currently open the user is asked which one she wants to act on.

If the dependencies are going to be part of the development tool the `-development` flag must be specified.

### AddNuGetDependencies

This requires at least a comma-separated list of NuGet packages to be added to a project.

A second (optional) argument, if specified, must be either a path to a Cider project or a Cider project alias.

If the second argument is omitted Cider acts an any open project. If there is more than one project currently open the user is asked which one she wants to act on.

Note that NuGet packages cannot be added to a Cider project as development tools.


### ListTatinDependencies

Checking dependencies before publishing to the principal Tatin Registry is a good idea, in particular when one uses several Tatin Registries like a personal one, a company Registry and https://tatin.dev

In such a scenario you might well install release candidates into a project that will eventually be published on https://tatin.dev. However, when the package **is** published on tatin.dev then you most likely don't want your projecty to depend on release candidates anymore.

The function `ListTatinDependencies` puts all build lists from all Tatin install folders of a given project on display, making it easy to check.

The following example was created in a workspace where the project `Cider` was opened. Because it was the only open project at that time, it acted on it.

`Cider` has two Tatin installation folders, one for production (`tatin-packages/`) and one for development and testing (`tatin-packages_dev/`):

```
      ]listTatinDependencies
 Source               Package-ID                      Principal  URL                  
 -------------------  ------------------------------  ---------  ------------------   
 tatin-packages/       G@aplteam-APLGit2-0.15.3               1  https://tatin.dev/   
 tatin-packages/       F@aplteam-FilesAndDirs-5.5.0           1  https://tatin.dev/   
 tatin-packages/       C@aplteam-CommTools-1.7.0              1  https://tatin.dev/   
 tatin-packages/       aplteam-FilesAndDirs-5.5.0             1  https://tatin.dev/   
 tatin-packages/       aplteam-CommTools-1.7.0                1  https://tatin.dev/   
 tatin-packages/       aplteam-APLTreeUtils2-1.2.0            1  https://tatin.dev/   
 tatin-packages/       aplteam-APLGit2-0.15.3                 1  https://tatin.dev/   
 tatin-packages/       A@aplteam-APLTreeUtils2-1.2.0          1  https://tatin.dev/   
 tatin-packages/       dyalog-HttpCommand-5.2.0               0  https://tatin.dev/   
 tatin-packages/       aplteam-OS-3.1.1                       0  https://tatin.dev/   
 tatin-packages/       aplteam-GitHubAPIv3-0.7.0              0  https://tatin.dev/   
 tatin-packages_dev/   aplteam-Tester2-3.5.0                  1  https://tatin.dev/   
 tatin-packages_dev/   aplteam-MakeHelpers-0.10.1             1  https://tatin.dev/   
 tatin-packages_dev/   aplteam-FilesAndDirs-5.5.0             1  https://tatin.dev/   
 tatin-packages_dev/   aplteam-CommTools-1.7.0                1  https://tatin.dev/   
 tatin-packages_dev/   aplteam-CodeCoverage-0.10.3            1  https://tatin.dev/   
 tatin-packages_dev/   aplteam-APLTreeUtils2-1.2.0            1  https://tatin.dev/   
 tatin-packages_dev/   aplteam-ZipArchive-1.1.0               0  https://tatin.dev/   
 tatin-packages_dev/   aplteam-OS-3.1.1                       0  https://tatin.dev/   
 tatin-packages_dev/   aplteam-MarkAPL-11.1.0                 0  https://tatin.dev/   
 tatin-packages_dev/   aplteam-IniFiles-5.0.3                 0  https://tatin.dev/   
 tatin-packages_dev/   aplteam-DotNetZip-2.0.2                0  https://tatin.dev/   
```

### ListNuGetDependencies                                                   

This lists all installed NuGet dependencies.

An example:

```
      ]Cider.ListNuGetDependencies
 Clock     1.0.3 
 NodaTime  3.1.9 
```


[^tatin]: _Tatin_ is a Dyalog APL package manager: <https://github.com/aplteam/Tatin>

[^nuget]: NuGet is all about .NET packages: <https://en.wikipedia.org/wiki/NuGet>

[^link]: _LINK_ is a tool designed to bring APL code into the workspace and keep it in sync with the files the code came from; see <https://github.com/dyalog/Link> and <https://dyalog.github.io/link>

[^load_tatin_pkgs]: Strictly speaking only references to the packages are injected into your application or tool. The actual packages are loaded into either `#._tatin` or `⎕SE._tatin`

