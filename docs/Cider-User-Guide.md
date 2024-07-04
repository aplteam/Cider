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

Note that a Cider project may or may not contain a single Tatin package. It is **_not_** designed to keep multiple packages. O course a project can have multiple Tatin packages as dependencies, that is a different matter.

A> ### Additional features
A> 
A> Cider offers more than is outlined here as "the solution", but you need to configure these extra features. See [Global configuration](#) for details.

### Requirements

#### APL Version

The first version you can use Cider with is 18.0. This is because Cider is a Tatin package, and Tatin runs under 18.0 or later.

Cider requires (like Tatin) a Unicode version of APL.

#### Tatin

Cider relies on the [Tatin package manager](https://github.com/aplteam/Tatin "Link to Tatin on GitHub") because it is a Tatin package. With version 19.0 and later Cider and Tatin will optionally be both available in `⎕SE` right from the start. With earlier versions (18.0 and 18.2) it's up to the user to take care of that.

If Tatin is not in `⎕SE` but recognized as a user command then Cider will attempt to load it by executing the user command `]Tatin.Version` which will implicitly load the Tatin API into `⎕SE`.

I> Note that Tatin will check whether Cider is available, and if so cooperate with it. However, Cider is not a requirement for using Tatin.

### Installation

With version 19.0, Cider will be part of a default installation, though it won't be active by default: for that the user has to take action. 

In earlier versions you must install Cider yourself.

#### Version 19.0

Use the user command `]Activate` to activate both Cider and Tatin. Start with:

```
]Activate -??
```

#### Version 18.0 and 18.2
 Unlike 19.0, these versions come with neither Tatin nor Cider, so you first have to make sure that Tatin is installed and available, because Cider is a Tatin package and is loaded as such.
 
The document [Installing And Updating The Tatin Client](https://tatin.dev/Assets/docs/InstallingAndUpdatingTheTatinClient.html "Link to the document on https://tatin.dev") provides instructions for how to install Tatin on 18.0 and 18.2.
 
Once Tatin is available, installing Cider is easy and straightforward, just issue this command:

```
]Tatin.InstallPackages [tatin]Cider <targetFolder>
```

`targetFolder` must be one of the following folders, here for version 18.2:

```
  ⍝ Windows
  ⍝ 32 bit
C:\Users\<⎕AN>\Documents\Dyalog APL 18.2 Unicode Files\SessionExtensions\CiderTatin\Cider
  ⍝ 64 bit
C:\Users\<⎕AN>\Documents\Dyalog APL-64 18.2 Unicode Files\SessionExtensions\CiderTatin\Cider
  ⍝ Linux
/home/<⎕AN>/dyalog.182U64.files/SessionExtensions/CiderTatin/Cider/
  ⍝ Mac OS
/Users/<⎕AN>/dyalog.182U64.files/SessionExtensions/CiderTatin/Cider/
```

Once the folder `SessionExtensions/CiderTatin/Cider` is in place, any newly started version of Dyalog 18.2 Unicode is aware of the user commands `]Cider.*`.

The API is not available yet at this point, but it will become available once a Cider user command is issued. For example, after issuing the following command the API will be available via `⎕SE.Cider`:

```
]Cider.Version
```

I> Note that for Dyalog's user command framework to be able to identify Cider's user command script, the folder must be made known to SALT. However, since Cider requires Tatin to be available this must have been done already.
I>
I> You can check this by issuing the command 
I>
I> `]SALT.Settings cmddir`
I>
I> This command lists all folders the user command framework will scan for user commands. The `SessionExtensions/CiderTatin/` folder must be among them, otherwise no Tatin user command would be available.

If that is not good enough for you, follow the instructions provided by the document [Installing And Updating The Tatin Client](https://tatin.dev/Assets/docs/InstallingAndUpdatingTheTatinClient.html#On-setupdyalog "Link to the document on https://tatin.dev") for how to achieve that for Tatin.

All you have to do in addition to that is to add this function to the `setup.dyalog` script:

```
    ∇ {r}←LoadCider debug;version;res;sep;path;qdmx
      r←0 0⍴''
      :Trap debug/0
          version←⊃(//)⎕VFI{⍵↑⍨¯1+⍵⍳'.'}2⊃# ⎕WG'APLVersion'
          path←1 GetProgramFilesFolder '/SessionExtensions/CiderTatin/'
          :If version<18
              r←'Cider not loaded, only supported in Dyalog 18.0 and later'
          :ElseIf 9=⎕SE.⎕NC'Cider'
              ⍝ Already loaded (19.0)
          :ElseIf 80≠⎕DR' '               ⍝ Not in "Classic"
              r←'Cider not loaded: not compatible with Classic'
          :Else
              ⎕SE.⎕EX¨'_Cider' 'Cider'    ⍝ Paranoia
              {}⎕SE.Tatin.LoadDependencies(path,'/Cider/')'⎕SE'
          :EndIf
      :Else
          r←'>>> Attempt to load Cider failed with ',⎕DMX.EM
      :EndTrap
    ∇
```

The final step is to add this line to the `Setup` function in the `setup.dyalog` script:

```
 (GetProgramFilesFolder '/SessionExtensions/CiderTatin') LoadCider ⎕SE.SALTUtils.DEBUG
```

### Updating Cider

You can update Cider to the latest version by issuing the following command:

```
]Cider.UpdateCider
```
    
You must restart Dyalog in order to start using the new version.

A> ### ]Cider.UpdateCider
A> 
A> Note that due to a change of the target folder this command will only work when you use it to update version 0.37.1 or later.
A>
A> !> ### Versions prior to 0.37.0
A> => *In earlier versions of Cider the command cannot know about the new target folder and must therefore not be used.*
A> =>
A> => For that reason you are advised to delete the `Cider/` folder from you `MyUCMDs/` folder (which means un-installing it) and then install it into the correct folder; see above.
A>
A> !> ### Versions 0.37.1 and 0.37.2
A> => These versions installed into the new folder but with one level missing, therefore *you must not use* `]CiderUpdateCider`!
A> =>
A> => For that reason you are advised to install again into the correct folder. 
A> =>
A> => The next time you use `]Cider.UpdateCider` it will remove Cider from the wrong folder.


#### When updating goes wrong

Debugging is the process of removing bugs from code, while programming is how you introduce them in the first place.

There is always the possibility that the update process is itself buggy. Calling it again usually does not help, so you need an escape route.



!> 18.2 and 18.0
=> The easiest way to recover it by uninstalling and then installing Cider again.
!> 19.0 and later
=> 1. Execute `]DeActivate tatin` --- that removes Cider.
=> 2. Execute `]Activate cider` --- that brings the version of Cider back that your installation originally came with.
=> 3. Execute `]Cider.UpdateCider` --- that will try to update to the latest version.

### Git

If you use Git for version control management, and you have the [Git Bash](https://git-scm.com/downloads "Link to the Git Bash download page") installed, then Cider uses the package [`APLGit2`](https://github.com/aplteam/APLGit2 "Link to APLGit2 on GitHub") to communicate with Git. 

For example, when a project carries a directory `.git/`, then Cider knows that the project is version controlled with Git, and it therefore uses the API of `APLGit2` to display the Git status report for a project in the later stages of opening a project.

### Configuration

#### Global configuration

Cider may have a global configuration file that can be used to define settings that effect _all_ projects. It's name is `config.json`.

This file, if it exists, it situated in a folder `.cider` that lives in the user's home folder on all platforms. For example, for a user JohnDoe the path would be `C:\Users\JohnDoe\.cider` on Windows, on Linux it would be `/home/JohnDoe/.cider`, and on the Mac it would be `/Users/JohnDoe/.cider`.

This folder does not only host the global config file, it's also the place where the file with alias definitions (`aliase.txt`) is saved as well as the file `cider.config.template` which is used as a template (hence the name) whenever a new project is created.

##### AskForDirChange

You may define `AskForDirChange` and assign one of the following values:

0 = Don't do anything at all regarding the current directory<br>
1 = If it's the first project in the current WS then change the directory<br>
2 = If it's the first project in the current WS then ask the user whether she wants to change the current directory

If no such value is defined then Cider behaves as if it is defined with the value 1.

##### CheckForDropboxConflicts

This is an optional flag. 

If you don't use Dropbox skip this topic.


If `CheckForDropboxConflicts` is defined and has the value 1, then both `]OpenProject` and `]CloseProject` will check whether the project has files that contain the string "conflicted copy", and report such files to the session.

Background: in case Dropbox cannot figure out what the last version of a file is, it will create such a file. Dropbox leaves it to the user to compare such a file manually and solve the conflict somehow. The problem is that Dropbox does not actually tell you about such files, therefore Cider does it for you if you configure Cider accordingly.

##### ExecuteAfterProjectOpen

If defined and not empty it must be the fully qualfied path to a function. That function will be executed by Cider after the project was opened.

The function must accept a right argument. This will be a namespace holding the information from the project's config file.

The function may or may not return a result, but it will be ignored.

##### ReportGitStatus

By default Cider reports the Git status of a project by putting it into an edit window if the working tree is not clean.

If you don't want this you can inject `ReportGitStatus` into the global config file and assign one of the following values:

0 = Don't report the Git status <br>
1 = Report the Git status in a read-only edit window (the default) <br>
2 = Report the Git status by printing it to the session <br>
3 = Ask the user what to do <br>

No matter what the global config parameter `ReportGitStatus` is saying, if a project is not version-controlled by Git (read: has no `.git/` folder in the root of the project folder) or `batch` is 1, no Git status is reported.

##### verbose

Boolean that defaults to 0. This means that Cider provides only really important messages. If you want Cider to be verbose (some would say: chatty) in this respect, set `verbose` to 1.

#### Project configuration

Every Cider project has a configuration file called `cider.config`, which is saved in the root of the project's folder.

When a new project is created, a copy of the file `cider.config.template` is copied from the global configuration folder (see above) into the root of the new project.


### CreateProject

With `]Cider.CreateProject` any folder that does not yet host a file `cider.config` can be transformed into a Cider project. (You may specify the `-acceptConfig` flag to override this default behaviour and make Cider accept an already existing file `cider.config`)

If the folder does not yet exist it will be created. In any case, the folder will be populated with a file `cider.config`.

I> The default config file that is copied into any new project stems from a folder `.cider/` in your home directory. 
I>
I> You may change this file and make amendments that suit your needs. 
I>
I> However, when a new version of Cider is installed the template config file *might* come with new or renamed or removed properties, and those would not make it into the template file in `.cider/cider.config` in your home directory: watch the release notes for this.

Starting with version 0.41.0, when Cider writes a config file to disk is adds (to old config files) or updates the Cider version number. The purpose of this is that one can see which version of Cider was used to write the file.

Note that `]Cider.CreateProject` deals differently with the possible combinations of namespace and source folder:

* The namespace and the source folder are both empty
* The namespace is empty and the source folder is not
* The source folder is empty and the namespace is not

"Empty" and non-existing have the same meaning/effect here.

In all these cases it should be pretty obvious what `]Cider.CreateProject` will do.

However, when the namespace and source folder are _both not empty_ then the user will be asked whether the contents of the namespace should be deleted because that might well make sense. 

If the user answers this question with "No" then an error is thrown.

A> ### Aliases
A>
A> If you work frequently on a project, entering the (potentially long) path over and over again can be tiresome.
A>
A> In such cases you can assign an alias like this:
A> ```
A> ]Cider.CreateProject /path/2/project -alias=foo
A> ```
A> From now on you can open the project with:
A> ```
A> ]Cider.OpenProject [foo]
A> ```

#### Project configuration parameters

The Cider configuration file comes with four sections:

* CIDER
* LINK
* SYSVARS
* USER

We will discuss the settings in each section in detail.

##### CIDER

This section discusses the Cider-specific parameters in alphabetical order.


###### distributionFolder

There is no default. If it is not empty it is supposed to be a folder, usually relative to the root of the project. Tatin's `BuildPackage` function would use this property in order to save the resulting ZIP file in this folder in case no specific target folder was specified.

If you create all your package ZIP files always in the same sub-folder of any project, then you can define this in Cider's project config template file in order to make sure that it will always default to that folder name: Tatin's `BuildPackage` function, when not provided with a target folder, would check whether the project is managed by Cider and has a non-empty property `distributionFolder` defined, and if so take that as the target folder.


###### parent

Defaults to `#` but can be something like `⎕SE` or `#.MyNamespace1.MyNamespace2` etc.

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

Defaults to `APLSource`: a subfolder that hosts all APL code. Its relative to the project folder. 

This might be empty, for example when the project is just a single script (class or namespace) that lives in the root of the project.

Note that this might be different from Tatin `source` parameter, which might point to a sub-folder of Cider's `source` hosting just the code that is a package. Cider's `source` might also contain test cases, development tools and whatnot.

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

All packages in the sub-folder `tatin-packages_dev/` are loaded into the sub-namespace `Testcases`

However, note that you cannot have a sub-key `nuget` in `dependencies_dev` for the time being. This restriction is likely to be lifted in a future release.

###### init

If not empty this must be the name of a function within `projectSpace`. The function will be executed after a project was opened or imported.

Such a function should not return a result; if it does anyway it should be shy.

Such a function may be niladic, monadic or ambivalent:

* A niladic function is just called
* An ambivalent or monadic function receives a namespace with the project configuration as right argument 


###### make

Empty or an expression (relative to the project) that would create a new version.

The purpose is to tell anybody not familiar with the project how to create a new version by entering:

```
      ]Cider.Make
#.Cider.Admin.Make 1 ⍝ Execute this for creating a new version
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.make`, and the comment is then added.

However, if the first non-white space character of `make` is a `]`, its definition would just be printed to the session together with a comment because then it's obviously a user command.


###### project_url

If not empty this is expected to be a URL pointing to, say, a GitHub project. For information only.

Note that Cider comes with a package [`APLGit2`](https://github.com/aplteam/APLGit2 title="Link to APLGit2 on GitHub"). `APLGit2` is an interface between Dyalog and Git, although some of its commands will only work when the project is hosted on GitHub.

Some function of `APLGit2` must know the `owner` of a project on GitHub. Those functions will investigate `project_url`: if that points to GitHub, the owner is established from its contents.


###### tatinVars

This property is optional, it may or may not exist. If it exists it must carry either `⎕THIS` or the name of a sub-namespace of the project.

* `⎕THIS` has the same effect as if the property would not exist  at all

* Specifying a sub-namespace would tell Cider to inject a reference `TatinVars` into that sub-namespace pointing to `TatinVars` in the root the project

For details see [Injecting a namespace TatinVars](#).


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

However, until all supported versions of Link can deal with Link's own configuration file, Cider will save non-default values in a Cider project config file.

If there is a Link config file by the name `.linkconfig`, then any definition in the "Link" section of the Cider config file is ignored. A message will remind the user of deleting the "Link" section from the Cider config file.

Cider will look for the file in what [`source`](#) defines. If `source` is empty then it is the root of the project.

###### watch

Defines which source to track for changes, so the other can be synchronised.

Defaults to "both" (namespace _and_ disk) and "ns" otherwise. Can also be "dir" and "none". 

Note that for "both" and "dir" .NET or .NET Core is required. Under Windows this is a given, but not so on Linux and Mac-OS: it may or may not be available. If it is not, the default for "watch" will be "ns".

"watch" is a very important parameter; that's why Cider will always report the setting. Other Link settings are only reported when they diverge from the default.

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

After opening the project into, say, `#.MyProject`, the value is accessible via

```
#.MyProject.CiderConfig.USER.Foo
```

### OpenProject

Naturally, `OpenProject` is the most important command Cider offers. We discuss all its actions in detail.

Note that the contents of the file `cider.config` directs what exactly Cider is going to do when its principal method, `OpenProject`, is executed.

#### Creating a project space

The first step carried out by `]Cider.OpenProject` is to create a namespace with the name `projectSpace` as a child of `parent`, when `parent` defaults to `#`, but may be something like `⎕SE` or `#.Foo.Goo` etc.

The `parent` must exist while the `parentSpace` may or may not exist. If it does not, it is created. If it does already exist then:

* In case the namespace and the folder are both empty Cider carries on
* In case only the namespace is empty Cider carries on
* In case only the folder is empty Cider carries on
* In case neither the namespace nor the folder is empty, the user is asked whether she wants the namespace to be emptied; if not an error is thrown.


#### Setting system variables

In the next step `]Cider.OpenProject` is going to set at least two system variables defined in the config file in the `SYSVARS` section of the INI file: `⎕IO` and `⎕ML`.

It is important to set these variables before code is brought into the workspace because bringing class scripts or namespace scripts into the workspace implies potentially the execution of code, and that code might well rely on the correct setting of those system variables.

If you need other system variables to carry specific values then you may add them to the `SYSVARS` section. 

Note that the names are not case sensitive; for example, whether the value for `⎕FR` is specified as  "fr" or "FR" or "Fr" or "fR" does not matter.

In case a setting in `SYSVARS` cannot be used for assigning a system variable a warning message will be printed to the session.

A> ### System variables
A>
A> Feel free to save system variables in files like `⎕IO.apla` in your source folder. 
A>
A> That's another way to make sure that system variables are set as early as possible, because LINK will establish the values of system variables defined in files before it attempts to bring code into the workspace.


#### Bringing the code into the workspace

In this step, all files with supported file extensions (See LINK's documentation for details) found in `source` and any subfolder are established in the workspace in `{parent}. {projectSpace}`.

To achieve this Cider uses LINK[^link]. 

Note that from now on we will refer to:

`{parent}.{projectSpace}` as _the root of a project_.

By default, a Link is established between the root of the project and the folder. When you intend to work on the project (read: change the code) then this is the obvious thing to do.

A> ### LINK's `watch` parameter
A>
A> By default Cider sets the `watch` parameter to "both", meaning that changes in the workspace via the editor are saved to disk, and any changes on disk are brought into the workspace. 
A>
A> You may set `watch` to "ns" or "dir" instead. Refer to the LINK documentation for details.


However, if you want to bring in the code as part of, say, an automated build process, then you don't want to establish a Link, you just want to bring the code into the workspace. This can be achieved by specifying the `-import` flag.


#### Check for empty package folders

Cider now checks whether any of the Tatin installation folders --- as noted on the `dependencies` and `dependencies_dev` properties --- is empty apart from a dependency file and a build list.

A> ### Why this may happen
A>
A> Since version 0.21.0 Cider itself has an enhanced `.gitignore` file: it defines that the contents of the Tatin installation folder(s) but the two definition files shall be ignored. Only these two definition files are therefore uploaded to GitHub, but _none of the packages_.
A>
A> The effect of this is that when somebody downloads the Cider project now _the Tatin installation folder contains just those two definition files but no packages!_
A>
A> Note that this is in line with the vast majority of other package managers.

In case a Tatin installation folder defined in the Cider config file does not contain any packages but the two definition files, the user will be asked whether she wants to re-install the packages. 


#### Check for later packages versions

In case the project has Tatin packages installed in one or more folders, the user will be asked whether she wants Cider to check for any later versions of any of the principal packages. This will only happen in case `importFlag` is 0.

However, note that this is only true if you've loaded the package(s) from a Tatin Registry that is in your config file _and_ has a priority greater than 0. Refer to the Tatin documentation for details.

If `]Cider.OpenProject` discovers later packages it will ask the user whether these packages shall be re-installed. This will happen independently for each package installation folder.


#### Loading Tatin packages
 
Your application or tool might depend on one or more Tatin[^tatin] packages. By assigning a folder hosting Tatin packages to the `tatin` sub-key in `dependencies`, and potentially also `dependencies_dev`, you can make sure that Cider will load[^load_tatin_pkgs] those installed packages into the root of your project or the assigned sub-namespace.

See the config properties `dependencies` and `dependencies_dev` for details.


#### Loading NuGet packages
 
Your application or tool might depend on a NuGet[^nuget] package. By assigning a folder hosting NuGet packages to the `nuget` sub-key in `dependencies` you can make sure that Cider will load those installed packages into the root of your project or the assigned sub-namespace.

See the config property `dependencies` details.

Note that NuGet packages can currently become part of your application, but they cannot be loaded as development tools. This restriction is likely to be lifted in a later release.


#### Injecting a namespace `CiderConfig`

In this step `]Cider.OpenProject` injects a namespace `CiderConfig` into the project space and...

* populates it with the contents of the configuration file as an APL array
* adds a variable `HOME` that remembers the path the project was loaded from


#### Injecting a namespace `TatinVars`

Whether a project is going to be a package depends on the presence of a file `apl-package.json` in the root of the project.

If such a file is present, Cider injects a namespace `TatinVars` into the root of the project, containing exactly the same pieces of information as if it were loaded as a package. This allows a developer to access `TatinVars` as if it was loaded as a package while working on the project.

However, a programmer would expect a namespace `TatinVars` in the root of the _package_. That might be the root of a project, but it might as well be a _sub-namespace_ of the project. In fact, that is more likely.

This can be addressed by adding the optional property "tatinVars" into the `CIDER` section of the Cider config file, holding the name of a sub-namespace that will eventually become the package. 

If a property "tatinVars" does exist and points to a sub-namespace, then Cider will create a reference `TatinVars` in that namespace that points to `TatinVars` in the root of the project.


#### Changing the current directory

If the project was opened (rather than imported!) **_and_** `batch` is 0, then Cider checks at this point the current (or working) directory. If it's different from the project's directory, the user is asked whether she wants to change the current directory to the project's directory.


#### Initialising a project

There might well be demand for executing some code to initialise your project.

This can be achieved by assigning the name of a function to `init`. The name must be relative to the root of your project.

The function will be executed unless `suppressInit` is 1.

The function should not return a result. If it does anyway it should be shy. Any result would be ignored.

Such a function may be niladic, monadic, ambivalent or dyadic:

* A monadic function receives a namespace with the project configuration as right argument 
* A dyadic or ambivalent function receives in addition the parameter space passed to `OpenProject`

Note that such a function will be executed no matter whether the project was opened or imported.


#### Executing user-specific code

You might want to execute some general code (as opposed to project-specific code) after a project was opened (rather than imported). "General" means that this code is executed whenever a project (any project!) is opened. 

You can suppress the execution of such a function by setting `ignoreUserExec` to 1.

This can be achieved by specifying the fully qualified name of a function that must be monadic, most likely in `⎕SE`. A namespace with the configuration data of the project is passed as the right argument.

The function may or may not return a result, but when it does the result will be discarded.

The fully qualified name of the function must go into the file that is returned by the function `GetCiderGlobalConfigFilename` which is available only via the API, not as a user command. This is the global Cider config file, not a Cider project config file.

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


#### Check for `ToDo`

If the project was opened (rather than imported!) **_and_** `batch` is 0, then Cider checks whether there is a variables `ToDo` in the root of your project that is not empty. If that's the case then the contents of that variable is printed to the session.

You may use this to keep track ...

* of steps that need to be executed before the project can be commited or published etc.
* keep track of a variable or a config property or a setting that has just been deprecated, but should be removed with the next major release
* you name it


#### Git status

If the project was opened (rather than imported!) **_and_** the project is version-controlled by Git **_and_** `batch` is 0 **_and_** the global configuration parameter `ReportGitStatus` is greater than 0, then Cider will report the current branch and its status. 


## Misc

Cider offers helpers that are useful in particular circumstances.

### Check for Dropbox conflicts

At this stage Cider would perform a check for any Dropbox conflicts if the project was opened rather than imported **_and_** the global configuration parameter 

The check is only performed the `batch` parameter is 0


### AddTatinDependencies

This requires at least a comma-separated list of Tatin packages to be added to a project.

A second (optional) argument, if specified, must be either a path to a Cider project or a Cider project alias.

If the second argument is omitted, Cider acts on any open project. If there are multiple projects open, the user is asked which one she wants to act on.

If the dependencies are development tools then the `-development` flag must be specified.

### AddNuGetDependencies

This requires at least a comma-separated list of NuGet packages to be added to a project.

A second (optional) argument, if specified, must be either a path to a Cider project or a Cider project alias.

If the second argument is omitted, Cider acts on any open project. If there are multiple projects open, the user is asked which one she wants to act on.

Note that NuGet packages cannot be added to a Cider project as development tools; this restriction is likely to be lifted in a later release.

Note that on Windows, adding NuGet packages requires Dyalog APL to be configured for .NET rather than .NET Framework. See <https://docs.dyalog.com/latest/dotNET%20Differences.pdf> for details.

### ListTatinDependencies

This user command serves two different purposes: 

* Checking the origin of the packages a project relies on
* Report the precise versions of dependencies 

The first one is the default, for the second you need to specify the `-full` flag.

#### Check the origin of dependencies

Checking dependencies before publishing to the principal Tatin Registry is a good idea, in particular when one uses several Tatin Registries like a personal one, a company Registry and https://tatin.dev

In such a scenario you might well install release candidates into a project that will eventually be published on https://tatin.dev. However, when the package is eventually published on tatin.dev, then you most likely don't want your projecty to depend on release candidates anymore.

The function `ListTatinDependencies` compiles a report from the build lists from all Tatin install folders of a given project on display, making it easy to check.

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

#### Check the precise versions of dependencies

This is useful for finding out why a particular package (typically an old one) is requested at all.

For this specifify the `-full` flag:

```
]listTatinDependencies -full
--- Select package install folder to report on: ---
   1. tatin-packages     
   2. tatin-packages_dev 

Select one item (q=quit) :1

aplteam-APLTreeUtils2-1.4.0 
aplteam-FilesAndDirs-5.7.1  
 aplteam-OS-3.1.1           
 aplteam-APLTreeUtils2-1.4.0
aplteam-CommTools-1.7.1     
aplteam-APLGit2-0.15.4      
 aplteam-APLTreeUtils2-1.2.2
 aplteam-FilesAndDirs-5.5.1 
 aplteam-GitHubAPIv3-0.7.0  
 dyalog-HttpCommand-5.2.0   
 aplteam-CommTools-1.7.0    
 aplteam-OS-3.1.1           
dyalog-NuGet-0.2.1          
```

This shows that the package `APLGit2` requests older versions of `APLTreeUtils2`, `FilesAndDirs` and `CommTools` than Cider would eventually use, information that is not easily available by other means.

### ListNuGetDependencies                                                   

This lists all installed NuGet dependencies.

An example:

```
      ]Cider.ListNuGetDependencies
 Clock     1.0.3 
 NodaTime  3.1.9 
```


[^tatin]: _Tatin_ is a Dyalog APL package manager: <https://github.com/aplteam/Tatin>

[^nuget]: _NuGet_ is all about .NET packages: <https://en.wikipedia.org/wiki/NuGet>

[^link]: _LINK_ is a tool designed to bring APL code into the workspace and keep it in sync with the files the code came from; see <https://github.com/dyalog/Link> and <https://dyalog.github.io/link>

[^load_tatin_pkgs]: Strictly speaking only references to the packages are injected into your application or tool. The actual packages are loaded into either `#._tatin` or `⎕SE._tatin`

































