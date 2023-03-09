[parm]:title             = 'Cider User Guide'
[parm]:leanpubExtensions = 1
[parm]:numberHeaders     = 2 3 4 5 6




# Cider User Guide

## What is Cider for?

In this document, we use the word "project" for an application or a tool that consists not only of what is finally delivered, like an Installer EXE under Windows or a Tatin package or a workspace or whatnot, but also of stuff that is required only during development, like test cases and test data, tools, helpers etc.

While LINK is perfect for bringing stuff into the workspace, putting together an environment in which development can take place requires more than just that. Something is missing...

## The solution

Cider attempts to fill that gap. A Cider project requires a configuration file named `cider.config`. 

The two most important commands of Cider's user commands are `CreateProject` and `OpenProject`.

I> Note that in this document names stemming from the Cider configuration file are shown `like this`.

### Requirements

Cider relies on the [Tatin packet manager](https://github.com/aplteam/Tatin "Link to Tatin on GitHub") because it is a Tatin package. With version 19.0 and later Tatin will be available in `⎕SE` right from the start. With earlier versions (18.0 and 18.2) it's up to the user to take care of that.

If Tatin is not in `⎕SE` but available in the `MyUCMDs/` folder then Cider will attempt to load it by executing the user command `]Tatin.Version` which should implicitly load Tatin into `⎕SE`.

I> Note that Tatin will check whether Cider is available, and if so cooperate with it. However, Cider is not a requirement for Tatin.


### CreateProject

With `]Cider.CreateProject` any folder that does not yet host a file `cider.config` can be transformed into a Cider project. (You may specify the `-acceptConfig` flag to override this default behaviour and make Cider accept an already existing file `cider.config`)

If the folder does not yet exist it will be created. In any case, the folder will be populated with a file `cider.config`.

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

This section contains the Cider-specific parameters.


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

This might be empty, for example when the project is just a script (class or namespace).

###### tatinFolder

Defaults to "packages".

Defines the folder(s) with installed Tatin packages required by the project as well as the resulting package or application. Must be relative to the folder where the project lives.

Accepts also something like this:

```
packages,packages_dev=TestCases
```

This is interpreted as follows:

1. Load all Tatin packages that are installed in the project's subfolder "packages" into the namespace that hosts the project

1. Load all Tatin packages that are installed in the project's subfolder "packages_dev/" into the namespace `TestCases` which must be a child of the namespace that hosts the project

W> You **must** put the main package folder first. `InstallPackages` will install all packages found in the first folder but nothing else.
 
If a project has only dependencies for development purposes then specify a leading comma like this:

```
,packages_dev=TestCases
```

This makes the first item an empty vector, and that tells Cider that there are no principal dependencies, just development dependencies.

Although it is possible to define more than two folders on `tatinFolder`, it is hard to imagine a case when this 
makes sense.

Of course you may assign a namespace name to the principal package as well, like this:

```
packages=Foo,packages_dev=TestCases
```


###### init

If not empty this must be an expression that would call a function within the project. It must be defined relative to `projectSpace`.

The expression will be executed after a project was opened. 


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


###### tests

Empty or an expression (relative to the project) that would execute the test cases of the project.

The purpose is to tell anybody not familiar with the project how to execute the test cases by entering:

```
      ]Cider.RunTests
#.Cider.TestCases.RunTests ⍝ Execute this for running the test suite
```

The output is compiled from the config parameter values `CIDER.parent`, `CIDER.projectSpace` and `CIDER.tests`, and the comment is then added.

However, if the first non-white space character of `tests` is a `]` (making it a user command rather than a function call) its definition would just be printed to the session together with a comment because then it's obviously a user command.

###### githubUsername

This parameter was introduced with version 0.19.0 --- from this version onwards Cider will deal with a missing parameter by this name: it will establish it as an empty character vector.

By default the parameter is empty. If a project is hosted on GitHub then you are advised to set it to the GitHub username --- "group" in Tatin speak.

That allows commands to be successfully issued towards GitHub when they require the username to be specified.

An example would be `]APLGit2.GetTagOfLatestRelease`: you may specify `-user=` and it would work, but when issued on a Cider project there is no need for this since it would collect the required information from the project's Cider config file.

##### LINK

These are LINK parameters which are passed on to LINK when Cider brings the APL code into the WS with LINK.

You may add other settings like `caseCode` as well; refer to LINKs documentation for details.

###### arrays

This is a Boolean that defaults to 0.

A 1 means that all variables are watched, and 0 means that Cider/Link do not care unless a variable is already saved in an `.apla` file.

###### beforeRead

Empty or a *fully qualified* function name.

###### beforeWrite

Empty or a *fully qualified* function name.

###### watch"

Defaults to "both" but can be "ns" or "dir" as well. 

Defines which source to track for changes, so the other can be synchronised.

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

It is important to set these variables before code is brought into the workspace because bringing class scripts or namespace scripts into the workspace implies the execution of some code, and that code might well rely on the correct setting of those system variables.

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
A> By default Cider sets the `watch` parameter to "both", meaning that changes in the workspace via the editor are saved to disk, and any changes on disk are brought into the workspace[^winonly]. 
A>
A> You may set `watch` to "ns" or "dir" instead. Refer to the LINK documentation for details.


However, if you want to bring in the code as part of, say, an automated build process, then you don't want to establish a link, you just want to bring the code into the workspace. This can be achieved by specifying the `-import` flag.


#### 4. Check for empty package folders

Cider now checks whether any of the Tatin installation folders --- as noted on the `tatinFolder` property --- is empty apart from the dependency file and the build list.

A> ### Why this may happen
A>
A> Since version 0.21.0 Cider itself has an enhanced `.gitignore` file: it defines that the contents of the Tatin installation folder(s) but the two definition files shall be ignored. Only these two definition files are therefore uploaded to GitHub, but _none of the packages_.
A>
A> The effect of this is that when somebody downloads the Cider project now _the Tatin installation folder contains just those two definition files but no packages!_
A>
A> Note that this is in line with the vast majority of other package managers.

In case a Tatin installation folder defined in the Cider config file does not contain any packages but the two definition files, the user will be asked whether she wants to re-install the packages. 

If she answers "Y" she will also be asked whether she wants to update those packages in case a later version of one of the packages mentioned in the dependency file is now available.


#### 5. Check for later packages versions

In case the project has Tatin packages installed in one or more folders the user will be asked whether she wants Cider to check for any later versions of any of the principal packages. This will only happen in case `importFlag` is 0.

However, note that this is only true if you've loaded the package(s) from a Tatin Registry that is in your config file _and_ has a priority greater than 0. Refer to the Tatin documentation for details.

If `]Cider.OpenProject` discovers later packages it will ask the user whether packages shall be re-installed with the `-update` flag set. This will happen independently for each package installation folder.


#### 6. Loading Tatin packages
 
Your application or tool might depend on one or more Tatin[^tatin] packages. By assigning `tatinFolder` one or more comma-separated folders hosting installed Tatin packages you can make sure that Cider will load[^load_tatin_pkgs] those installed packages into the root of your project.

In particular, when you specify more than a single folder you are likely to want some packages to be loaded into a sub-namespace of the root of your project.

For example, let's assume you want all packages installed in the folder `packages/` to be loaded into the root of your project, and that you want to load all packages from a folder `packages_dev/` (for "development") into a namespace `TestCases` in the root of your project.

This will do the trick:

```
"tatinFolder": "packages,packages_development=TestCases",

```

Notes:
* For the first folder, `packages/`, no target namespace is specified, therefore the packages are loaded into the root of the project
* A namespace, if assigned to a folder, must be specified relative to the root of the project


#### 7. Injecting a namespace `CiderConfig`

In this step `]Cider.OpenProject` injects a namespace `CiderConfig` into the project space and...

* populates it with the contents of the configuration file as an APL array
* adds a variable `HOME` that remembers the path the project was loaded from


#### 8. Initialising a project (optional)

Now there might well be demand for executing some code to initialise your project.

This can be achieved by assigning the name of a function to `init`. This must again be relative to the root of your project.

Notes:

* The function should not return a result. If it does anyway it should be shy. Any result would be ignored.
* The function must be either monadic or niladic. If it is monadic then `⍬` is passed as the right argument.

  What is passed as the right argument might well change in a future release.

Note that you can access the configuration data of the project from within your initialisation function by questioning the `CiderConfig` namespace.

#### 9. Executing user-specific code

Finally, you might want to execute some general code (as opposed to project-specific code) after a project was loaded. "General" means that this code is executed whenever a project (any project!) is opened. 

This can be achieved by specifying the fully qualified name of a function that must be monadic, most likely in `⎕SE`. A namespace with the configuration data of the project is passed as the right argument.

The function may or may not return a result, but when it does the result will be discarded.

The fully qualified name of the function must go into the file that is returned by the function `GetCiderConfigFilename` which is available only via the API, not as a user command. This is the Cider config file, not a Cider project config file.

That file already contains a definition of the keyword `ExecuteAfterProjectOpen`, but it is empty:

```
{
    ExecuteAfterProjectOpen: "",
}
```

What is this good for you may ask? Well, let's assume that you are not using Git but a different version control Software. With Git, Cider would execute the "status" command and show the result to the user. With your version control software, it can't do something similar.

You can easily achieve that by yourself: just add the required code to a function you load early into `⎕SE`, and then make sure that `ExecuteAfterProjectOpen` is calling that function and you are done.

[^tatin]: _Tatin_ is a Dyalog APL package manager: <https://github.com/aplteam/Tatin>

[^link]: _LINK_ is a tool designed to bring APL code into the workspace and keep it in sync with the files the code came from: <https://github.com/dyalog/Link>

[^load_tatin_pkgs]: Strictly speaking only references to the packages are injected into your application or tool. The actual packages are loaded into either `#._tatin` or `⎕SE._tatin`

[^winonly]: At the time of writing (July 2022) this works under Windows but not on other operating systems. However, Dyalog plans to implement this feature on all platforms.

## Misc

Cider offers helpers that are useful in particular circumstances.

### ListTatinPackage

Checking dependencies before publishing to the principal Tatin Registry is a good idea, in particular when one uses several Tatin Registries like a personal one, a company Registry and https://tatin.dev

In such a scenario you might well install release candidates into a project that will eventually be published on https://tatin.dev, but of course not with a release candidate!

The function `ListTatinPackage` helps put all build lists from all Tatin install folders of a given project on display, making it easy to check.

The following example was created in a workspace where the project `APLGit2` was opened. Because it is the only one Cider knows that it is supposed to deal with it.

`APLGit2` has two Tatin installation folders, one for production (`packages/`) and one for development and testing (`packages_dev/`):

```
      ]listTatinPackages
*** C:/.../APLGit2/packages:
 Package-ID                                         Principal  URL                
 ---------------------------                        ---------  ------------------ 
 aplteam-OS-3.0.1                                           1  https://tatin.dev/ 
 aplteam-GitHubAPIv3-0.7.0                                  1  https://tatin.dev/ 
 aplteam-FilesAndDirs-5.1.5                                 1  https://tatin.dev/ 
 aplteam-CommTools-1.0.1                                    1  https://tatin.dev/ 
 aplteam-APLTreeUtils2-1.1.3                                1  https://tatin.dev/ 
*** C:/.../APLGit2/packages_dev:
 Package-ID                                         Principal  URL                
 ---------------------------                        ---------  ------------------ 
 aplteam-ZipArchive-1.0.0                                   1  https://tatin.dev/ 
 aplteam-Tester2-3.2.7                                      1  https://tatin.dev/ 
 aplteam-FilesAndDirs-5.1.5                                 1  https://tatin.dev/ 
 aplteam-CodeCoverage-0.9.3                                 1  https://tatin.dev/ 
 aplteam-APLTreeUtils2-1.1.3                                1  https://tatin.dev/ 
 aplteam-OS-3.0.1                                           0  https://tatin.dev/ 
 aplteam-IniFiles-5.0.3                                     0  https://tatin.dev/ 
 aplteam-DotNetZip-2.0.2                                    0  https://tatin.dev/ 
```
