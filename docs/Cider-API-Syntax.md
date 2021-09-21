[parm]:title = 'Cider Reference'

# Cider's API --- Syntax Reference

Although the API functions are similar to their user command equivalents, they are not identical. Also, the API offers more functions, and for two user commands there are no corresponding functions in the API (`CreateProject` and `CloseProject`). 

While for the user commands the help provided by the `-?` syntax is sufficient, this document deals with the API.

The following list is ordered alphabetically.

## CloseProject

There is no API equivalent for the user command `]Cider.CloseProject`. Use `⎕SE.Link.Break` instead.

## CreateOpenParms

A monadic function that returns a namespace with default parameters required by the `OpenProject` function. The right argument is ignored.


```
 alias         ''      
 folder        ''  
 parent        '#' 
 projectSpace  ''  
 quietFlag     0 
 suppressLX    0 
```

This is useful for creating a namespace with the defaults, set required parameters (at least `folder` and `projectSpace`), make amendments and pass the namespace as argument to `OpenProject`.

## CreateProject

There is no API equivalent for the user command `]Cider.CreateProject`.

## DropAlias

Takes an alias and removes it.


## GetAliasFileContent

Niladic function that returns the contents of the file returned by the `GetCiderAliasFilename` function as an APL array:

```
      ⎕SE.Cider.GetAliasFileContent
 cider  C:/T/Projects/Dyalog/Cider 
```

Every record of that file contains two pieces of information: an alias and its associated path. The file might be empty.

## GetAliasFilename

Niladic function that returns the path to the file that is used by Cider to manage alias names and their paths.


## GetMyUCMDsFolder

Niladic function that returns the path to the `MyUCMDs/` folder.

Note that this folder is created under Windows by the Dyalog installation routine, but not on other platforms.


## GetCidersConfigFileContent

Niladic function that returns the contents of the file returned by the `GetCidersConfigFilename` function as a vector of text vectors:

```
       ⍪ ⎕se.Cider.GetCidersConfigFileContent
 {                                
     ExecuteAfterProjectOpen: "", 
 }                                
```

## GetCidersConfigFilename

Niladic function that returns the path to the file with Cider's own configuration file.

```
      ⎕se.Cider.GetCiderConfigFilename
C:\Users\{⎕AN}\AppData\Roaming/.cider/config.json
```

## ListOpenProjects

Requires a Boolean as right argument ("verbose").

With 0 it returns a matrix with two columns:

```
      ⎕SE.Cider.ListOpenProjects 0
 #.Cider  /path/to/Cider
```

With the verbose flag set it returns 4 columns:

```
      ⎕SE.Cider.ListOpenProjects 1
 #.Cider  /path/to/Cider  32  cider 
```
`[;1]` | Fully qualified project space
`[;2]` | Path the project was loaded from
`[;3]` | Number of objects belonging to the project
`[;4]` | Alias (if any)

## OpenProject

Opening a project means carrying out the following actions:

1. Creating the `projectSpace` (namespace) in `parent`; if it already exists it must be empty

   From here on we refer to this as the _root of the project_.
2. Setting the system variables `⎕IO`, `⎕ML` and `⎕WX` in the root of the project
3. Bringing all code and variables into the root of the project
4. Loading all Tatin packages from the Tatin installation folders defined on `tatinFolders`
5. Injecting a namespace `CiderConfig` into the root of the project and populating it with the contents of the configuration file as an APL array
6. Addng a variable `HOME` to `CiderConfig` that carries a path to where the project was loaded from
7. Executing the project-specific function noted on `lx`, ususally to initialize the project. 
8. Executing a non-project-specific function defined in Cider's own configuration file.

`OpenProject` requires parameters expected to be passed via the right argument. The parameters can be provided in two different ways:

### Positional parameters

As a vector with up to 5 parameters:

  1. folder (mandatory)
  2. projectSpace
  3. parent
  4. alias
  5. Flags
     1. quietFlag
     2. suppressLX

Note that the flags must be specified as a single integer according to this table:

```
0 0 ←→ 0
1 0 ←→ 1
0 1 ←→ 2
1 1 ←→ 3
```

Currently there are only two flags recognized by `OpenProject`, but that might well change in a future release.


### Parameter namespace 
A namespace carrying appropriately named variables, typically created by calling `CreateOpenParms`.

  Such a namespace must carry the following variables:

#### folder (mandatory)

This must be one of:

* A path pointing to a folder that carries a file `cider.config`
* An alias like `[aliasname]`

Note that this must _not_ be empty.

#### projectSpace (mandatory)

The name of the namespace the project is injected into.

#### parent

Defaults to `#` but might as be something like `⎕SE` or `#.Foo.Goo.Boo`. However, all namespaces listed must exist.

#### alias

The alias under which you might want to access the project in the future.

#### Flags

##### quietFlag

Defaults to 1, meaning that the function prints messages to the session.

##### suppressLX

Defaults to 0, meaning that the projects initialisation function (if any) is automatically executed.

There might well be situations when you don't want this, therefore you may suppress the execution by setting this to 1.

An example might be an automated build process: that might need to open the project but without actually initialising it.

## ProcessAlias

Takes two parameters via the right argument:

1. Fully qualified folder hosting a project
2. Alias name

If the alias is not already in use and the folder exists the function adds the definition to the file returned by `GetAliasFilename`. 

Returns an empty vector in case of success and an error message otherwise.

## Version

`Version` returns a three-element vector with these pieces of information:

1. The name, "Cider"
2. The version number

   This can be just `1.2.3`,  but it may be something like `1.2.3-beta-1+113`
3. The version date in international date format: YYYY-MM-DD
