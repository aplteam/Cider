:Class Cider_UC
⍝ User Command class for the project manager "Cider"
⍝ Kai Jaeger
⍝ 2023-09-05      
⍝ 2023-09-10 Version with "Dependency" added by Morten Kromberg


    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3
    MinimumVersionOfDyalog←'18.0'
    L←⎕SE.Link
    configFilename←'cider.config'

    ∇ r←List;c ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
      r←⍬
      :If AtLeastVersion⊃(//)⎕VFI MinimumVersionOfDyalog
               
          c←⎕NS''
          c.Name←'Dependency'
          c.Desc←'Add a Tatin or Cider dependency'
          c.Group←'Cider'
          c.Parse←'3s -list'
          r,←c

          c←⎕NS''
          c.Name←'OpenProject'
          c.Desc←'Load all source files into the WS and keep it linked by default'
          c.Group←'Cider'
          c.Parse←'1s -projectSpace= -parent= -alias= -suppressInit -quiet -import -noPkgLoad -ignoreUserExec -watch=ns dir both'
          r,←c
     
          c←⎕NS''
          c.Name←'Config'
          c.Desc←'Allow the user to edit Cider''s config file'
          c.Group←'Cider'
          c.Parse←'-print'
          r,←c
     
          c←⎕NS''
          c.Name←'ListOpenProjects'
          c.Desc←'List all currently open projects'
          c.Group←'Cider'
          c.Parse←'0 -verbose'
          r,←c
     
          c←⎕NS''
          c.Name←'ListAliases'
          c.Desc←'List all defined aliases with their folders'
          c.Group←'Cider'
          c.Parse←'0 -prune -edit -quiet'
          r,←c
     
          c←⎕NS''
          c.Name←'CreateProject'
          c.Desc←'Makes the given folder a project folder'
          c.Group←'Cider'
          c.Parse←'2s -alias= -acceptConfig -noEdit -quiet -ignoreUserExec'
          r,←c
     
          c←⎕NS''
          c.Name←'CloseProject'
          c.Desc←'Breaks the Link between the workspace and the files on disk'
          c.Group←'Cider'
          c.Parse←'-all'
          r,←c
     
          c←⎕NS''
          c.Name←'ListTatinPackages'
          c.Desc←'Lists all Tatin packages in all install folders'
          c.Group←'Cider'
          c.Parse←'1s'
          r,←c
     
          c←⎕NS''
          c.Name←'RunTests'
          c.Desc←'Executes the project''s test suite (if any)'
          c.Group←'Cider'
          c.Parse←'1s'
          r,←c
     
          c←⎕NS''
          c.Name←'Make'
          c.Desc←'Build a new version of the project'
          c.Group←'Cider'
          c.Parse←'1s'
          r,←c
     
          c←⎕NS''
          c.Name←'Help'
          c.Desc←'Offers to put the HTML files on display'
          c.Group←'Cider'
          c.Parse←'0'
          r,←c
     
          c←⎕NS''
          c.Name←'ProjectConfig'
          c.Desc←'Puts the config file of a project on display'
          c.Group←'Cider'
          c.Parse←'1s -edit'
          r,←c
     
          c←⎕NS''
          c.Name←'Version'
          c.Desc←'Returns name, version number and version date as a three-element vector'
          c.Group←'Cider'
          c.Parse←'0'
          r,←c
      :EndIf
    ∇

    ∇ r←Run(Cmd Args);folder;P;⎕TRAP;ciderns;ciderref;refs;deps
      :Access Shared Public
      r←0 0⍴''
      ('Cider needs at least version ',MinimumVersionOfDyalog,' of Dyalog APL')Assert AtLeastVersion⊃(//)⎕VFI MinimumVersionOfDyalog
      :If 0=⎕SE.⎕NC'Tatin'
          :Trap 6
              {}⎕SE.UCMD'Tatin.Version'
          :Else
              'Tatin is not available and cannot be loaded into ⎕SE, therefore Cider won''t work'Assert 0
          :EndTrap
      :EndIf
      :If 0=⎕SE.⎕NC'Cider'
          {}⎕SE.Tatin.LoadDependencies(⊃⎕NPARTS ##.SourceFile)'⎕SE'
      :EndIf
      P←⎕SE.Cider
      :If 18={⊃(//)⎕VFI ⍵↑⍨¯1+⍵⍳'.'}aplVersion←2⊃'.'⎕WG'aplversion'
      :AndIf 44280>⊃(//)⎕VFI 3⊃'.'(≠⊆⊢)aplVersion  ⍝ 44280 has essential ⎕FIX fix for Link to work
          'Version 18 must be at least on build number 44280, otherwise Link won''t work as expected'⎕SIGNAL 11
      :EndIf
      :Select ⎕C Cmd
      :Case ⎕C'Dependency'
          r←Dependency Args
      :Case ⎕C'OpenProject'
          r←OpenProject Args
      :Case ⎕C'ListOpenProjects'
          r←ListOpenProjects Args
      :Case ⎕C'ListAliases'
          r←ListAliases Args
      :Case ⎕C'ListTatinPackages'
          r←ListTatinPackages Args
      :Case ⎕C'CreateProject'
          r←CreateProject Args
      :Case ⎕C'CloseProject'
          r←CloseProject Args
      :Case ⎕C'ProjectConfig'
          r←ProjectConfig Args
      :Case ⎕C'RunTests'
          r←RunTests Args
      :Case ⎕C'Make'
          r←Make Args
      :Case ⎕C'Config'
          r←Config Args
      :Case ⎕C'Version'
          r←P.Version
      :Case ⎕C'Help'
          r←ShowHelp ⍬
      :Else
          ∘∘∘ ⍝ Huh?!
      :EndSelect
    ∇

    ∇ r←RunTests Args;config;path;list;index
      r←''
      :If 0=≢path←GetProjectPath Args
          →0,≢⎕←'Cancelled by user'
      :Else
          :If 0=≢r←⎕SE.Cider.RunTests path
              ⎕←'>>> No expression found for executing ',path,'''s test suite'
          :EndIf
      :EndIf
    ∇

    ∇ r←Make Args;config;path;list;index;home
      r←''
      :If 0=≢path←GetProjectPath Args
          →0,≢⎕←'Cancelled by user'
      :Else
          home←(⎕SE.Cider.ListOpenProjects 0){⊃⍺[⍺[;2]⍳⊂⍵;1]}path
          :If 2≠⎕NC home,'.ToDo'
          :OrIf 0=≢(∊home⍎'ToDo')~' '
          :OrIf ⎕SE.Cider.##.C.YesOrNo'IgnoreToDo@There is a non-empty variable "ToDo" in <',home,'> - carry on anyway?'
              r←⎕SE.Cider.RunMake path
          :EndIf
      :EndIf
    ∇

    ∇ r←Dependency Args;list;path;index;z;load
    ⍝ Dependency nuget Clock [projectpath] -list
      r←''
      :If 0=≢path←GetProjectPath z⊣(z←⎕NS '')._1←Args._3
          →0,≢⎕←'Cancelled by user'
      :Else
          path←(1+0≡Args._3)⊃Args._3 path
          load←0 ⍝ OpenProject will call with load←1
          r← ⎕SE.Cider.Dependency (2↑Args.Arguments),path Args.list load
      :EndIf
    ∇

    ∇ r←Config Args;_Cider;filename;json
      r←'No action taken'
      filename←P.GetCiderGlobalConfigFilename
      :If P.##.F.IsFile filename
          json←⊃P.##.F.NGET filename
          :If Args.Switch'print'
              r←'--- Conder Config File: ',('expand'P.##.F.NormalizePath filename),' ---',⎕UCS 10
              r,←json
          :Else
              _Cider←⎕NS''
              _Cider.config←json
              _Cider.⎕ED'config'
              :If 0<≢_Cider.config
              :AndIf json≢_Cider.config
              :AndIf YesOrNo'Would you like to save your changes on disk?'
                  (⊂_Cider.config)P.##.F.NPUT filename 1
                  r←'File edited and changed saved to disk'
              :EndIf
          :EndIf
      :Else
          r←'File not found: ','expand'P.##.F.NormalizePath filename
      :EndIf
    ∇

    ∇ r←ProjectConfig Args;list;path;index
      r←''
      :If 0=≢path←GetProjectPath Args
          →0,≢⎕←'Cancelled by user'
      :Else
          :If Args.edit ⎕SE.Cider.ProjectConfig path
              r←'Changed: ',path,'/cider.config; changes are NOT reflected in the workspace!'
          :EndIf
      :EndIf
    ∇

    ∇ r←CreateProject Args;folder;msg
      :If 0=≢Args._1
          folder←''
      :Else
          folder←Args._1
      :EndIf
      :If 0=≢Args._2
      :OrIf 0≡Args._2
          r←CreateProject_ folder(Args.acceptConfig)(Args.noEdit)(Args.quiet)(Args.ignoreUserExec)
      :Else
          r←Args._2 CreateProject_ folder(Args.acceptConfig)(Args.noEdit)(Args.quiet)(Args.ignoreUserExec)
      :EndIf
      :If 0≢Args.alias
          :If 0<≢msg←P.AddAlias folder Args.alias
              r,←(⎕UCS 13)msg
          :EndIf
      :EndIf
    ∇

    ∇ r←ListAliases Args
      :If Args.edit
          :If 0=≢r←EditAliasFile ⍬
              r←ProcessAliases 0 0 0
          :EndIf
      :Else
          r←ProcessAliases Args.(prune edit quiet)
      :EndIf
    ∇

    ∇ r←ListTatinPackages Args;path
      r←''
      :If 0=≢path←'act on'GetProjectPath Args
          →0,≢⎕←'Cancelled by user'
      :Else
          r←P.ListTatinPackages path
      :EndIf
    ∇


    ∇ r←ListOpenProjects Args
      r←P.ListOpenProjects Args.verbose
      r(AddTitles)←'Namespace name' 'Path',Args.verbose/'No. of objects' 'Alias'
    ∇

    ∇ r←OpenProject Args;path;parms;aliasDefs;bool;info;opCode;alias;log;success
      r←0 0⍴''
      Args.projectSpace←{(,0)≡,⍵:'' ⋄ ⍵}Args.projectSpace
      aliasDefs←P.GetAliasFileContent
      :If 0≡Args._1
      :OrIf Args._1≡'[?]'
          :If 0=≢path←SelectFromAliases aliasDefs
              :Return
          :EndIf
      :Else
          path←Args._1
      :EndIf
      :If '[]'≡path[1,≢path]
      :AndIf '*'=¯1↑path~'[]'
          bool←~aliasDefs[;2]∊{⍵[;2]}P.ListOpenProjects 0
          bool←bool\(¯1↓path~'[]'){(⎕C(≢⍺)↑[2]⍵)∧.=⎕C ⍺}↑bool⌿aliasDefs[;1]
          :Select +/bool
          :Case 0
              :Return
          :Case 1
              (alias path)←aliasDefs[bool⍳1;]
              :If 0=1 YesOrNo'Sure you want to open "',path,'" ?'
                  :Return
              :EndIf
          :Else
              info←'(',((⍕+/bool),' of ',(⍕≢aliasDefs)),')'
              :If 0=≢path←info SelectFromAliases bool⌿aliasDefs
                  :Return
              :EndIf
          :EndSelect
      :EndIf
      path←⎕C⍣('[]'≡path[1,≢path])⊣path
      parms←P.CreateOpenParms''
      parms.folder←path
      parms.projectSpace←Args.projectSpace
      parms.parent←{(,0)≡,⍵:'' ⋄ ⍵}Args.parent
      parms.alias←⎕C''Args.Switch'alias'
      parms.watch←⎕C Args.Switch'watch'
      parms.quietFlag←Args.quiet
      parms.suppressInit←Args.suppressInit
      parms.importFlag←Args.import
      parms.noPkgLoad←Args.noPkgLoad
      parms.ignoreUserExec←Args.ignoreUserExec
      (success log)←P.OpenProject parms
      :If Args.quiet
          r←log
          :If success
              r,←⊂'Project successfully opened'
          :EndIf
      :ElseIf success
          r←'Project successfully opened'
      :Else
          r←'Attempt to open the project failed'
      :EndIf
    ∇

    ∇ r←level Help Cmd;ref
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          :Select ⎕C Cmd
          :Case ⎕C'Dependency'
              r,←⊂'Add a dependency'
              r,←⊂']Cider.Dependency [tatin|nuget] [package] [projectpath] -list'
          :Case ⎕C'OpenProject'
              r,←⊂'Load all source files into the WS and keep it linked by default plus many more actions...'
              r,←⊂']Cider.OpenProject [folder|alias] -projectSpace= -parent= -alias= -suppressInit -quiet -import -noPkgLoad -ignoreUserExec -watch=ns|dir|both'
          :Case ⎕C'ListOpenProjects'
              r,←⊂'List all currently open projects'
              r,←⊂']Cider.ListOpenProjects -verbose'
          :Case ⎕C'ListAliases'
              r,←⊂'List all defined aliases with their folders'
              r,←⊂']Cider.ListAliases -prune -edit -quiet'
          :Case ⎕C'ListTatinPackages'
              r,←⊂'Lists all Tatin packages in all install folders'
              r,←⊂']Cider.ListTatinPackages [folder]'
          :Case ⎕C'CreateProject'
              r,←⊂'Makes the given folder a project folder'
              r,←⊂']Cider.CreateProject <folder> [<project-namespace>] -alias= -acceptConfig -noEdit -quiet -ignoreUserExec'
          :Case ⎕C'CloseProject'
              r,←⊂'Breaks the Link between one or more project spaces and their associated files on disk'
              r,←⊂']Cider.CloseProject [<namespace-name>|alias-name] -all'
          :Case ⎕C'Help'
              r,←⊂'Offers to put the HTML files on display'
              r,←⊂']Cider.Help'
          :Case ⎕C'ProjectConfig'
              r,←⊂'Puts the config file of a project on display'
              r,←⊂']Cider.ProjectConfig [path] -edit'
          :Case ⎕C'RunTests'
              r,←⊂'Prints the project''s specific statements to the session that will run the test suite'
          :Case ⎕C'Make'
              r,←⊂'Prints the project''s specific statements to the session that will create a new version ("Make")'
          :Case ⎕C'Cider'
              r,←⊂'Allows the user to edit one or both of Cider''s config files'
              r,←⊂']Cider.Config -print'
          :Case ⎕C'Version'
              r,←⊂'Returns name, version number and version date as a three-element vector'
              r,←⊂']Cider.Version'
          :EndSelect
          :If ~(⊂⎕C Cmd)∊⎕C'Version' 'Help'
              r,←''(']Cider.',Cmd,' -?? ⍝ Enter this for more information ')
          :EndIf
      :Case 1
          :Select ⎕C Cmd
          :Case ⎕C'OpenProject'
              r,←⊂'Takes path to folder that must host a file "',configFilename,'" or a pre-defined alias.'
              r,←⊂'The config file must specify all variables required by Cider, including "source".'
              r,←⊂'The contents of "source" is then linked to "parent.projectSpace" by default.'
              r,←⊂'If no folder or alias is specified, Cider will present a list with all defined aliases.'
              r,←⊂''
              r,←⊂'An alias must be embraced by square brackets, for example:'
              r,←⊂'    ]Cider.OpenProject [alias]'
              r,←⊂'The "*" wildcard is supported, but only at the end. The following statement will list all'
              r,←⊂'projects that start their names with "A"'
              r,←⊂'    ]Cider.OpenProject [A*]'
              r,←⊂''
              r,←⊂'-quiet          The user command prints messages to the session unless -quiet is specified.'
              r,←⊂'-parent         The project is loaded into Cider.(parent.projectSpace) unless this is (temporarily)'
              r,←⊂'                overwritten by setting the -parent= and/or the -projectSpace= option(s).'
              r,←⊂'-projectSpace   The project is loaded into Cider.(parent.projectSpace) unless this is (temporarily)'
              r,←⊂'                overwritten by setting the -projectSpace= and/or the -parent= option(s).'
              r,←⊂'-import         By default the namespace is linked to folder. By specifying the -import'
              r,←⊂'                flag this can be avoided: the code is then loaded into the workspace with the'
              r,←⊂'                Link.Import method, meaning that changes are not tracked.'
              r,←⊂'                With -import the status of neither Git nor any installed Tatin packages is checked.'
              r,←⊂'-alias=         In case you are going to work on a project frequently you may specify'
              r,←⊂'                -alias=name for quicker access.'
              r,←⊂'                (In order to remove an alias use ]Cider.ListAliases -edit)'
              r,←⊂'-noPkgLoad      By default the Tatin packages from the installation folder(s) defined in the'
              r,←⊂'                config will be loaded. If you don''t want this specify -noPkgLoad'
              r,←⊂'-watch          Defaults to "both" (if .NET is available) but may be "ns" or "dir" instead.'
              r,←⊂'                * "ns" means that changes in the workpace are saved on disk'
              r,←⊂'                * "dir" means that any changes on disk are brought into the WS'
              r,←⊂'                * "both" means that any changes in either "ns" or "dir" are reflected accordingly'
              r,←⊂'                   However, currently "both" works only under Windows.'
              r,←⊂'                   Note that the flag does NOT change the config file on disk'
              r,←⊂'                Refer to the Link documentation for details.'
              r,←⊂'-ignoreUserExec Suppress execution of a user function defined in Cider''s config file on this occasion'
          :Case ⎕C'Config'
              r,←⊂'Puts the content of Cider''s global config into the editor and allows the user to change it.'
              r,←⊂'By specifying the -print flag you can force the user command to print the content of the file'
              r,←⊂'to the session.'
              r,←⊂''
              r,←⊂'Note that changing the config file does not affect the currently running instance of Cider.'
          :Case ⎕C'ListOpenProjects'
              r,←⊂'Print a list with the namespaces of all currently opened projects.'
              r,←⊂'Add the -verbose flag for more information. Then a matrix is returned with these columns:'
              r,←⊂' [;1] Namespace name'
              r,←⊂' [;2] Path'
              r,←⊂' [;3] Number of objects in the project'
              r,←⊂' [;4] Alias name (if any)'
          :Case ⎕C'ListAliases'
              r,←⊂'Print all defined aliases together with their folders.'
              r,←⊂''
              r,←⊂'There are two mutually exclusive options available:'
              r,←⊂'-edit   Cider will allow you to edit the file that keeps the alias information'
              r,←⊂'-prune  Cider will delete all aliases for which their folders cannot be found'
              r,←⊂''
              r,←⊂'-quiet  When -prune is specified the user will be asked for confirmation in case there'
              r,←⊂'        is something to prune at all. You can specify -quiet in order to prevent this.'
              r,←⊂'        All reporting to the session will be suppressed as well.'
          :Case ⎕C'ListTatinPackages'
              r,←⊂'Lists all Tatin packages in all install folders of a given project'
              r,←⊂''
              r,←⊂' * If no argument is provided a list with all open projects is presented to the user, unless'
              r,←⊂'   there is only one open anyway.'
              r,←⊂' * If an argument is provided then it must be one of:'
              r,←⊂'   * folder of a Cider-managed project'
              r,←⊂'   * an alias of a Cider-managed porject'
              r,←⊂''
              r,←⊂'The package install folder(s) are established from Cider''s config file.'
              r,←⊂''
              r,←⊂'The purpose of this user command is to check whether the packages got installed from the'
              r,←⊂'desired Tatin Registries.'
          :Case ⎕C'CreateProject'
              r,←⊂'Requires a path to a folder ("source") that is about to become a project.'
              r,←⊂''
              r,←⊂'You might also specify a namespace. If no namespace is provided then the name of the namespace'
              r,←⊂'is derived from the path. If the namespace does not yet exist it will be created.'
              r,←⊂'The namespace will be LINKed to "source", and a namespace CiderConfig, holding the configuration'
              r,←⊂'data, will be injected into the namespace.'
              r,←⊂'For a root project (the whole of #, NOT recommended) you must specify # as 2nd argument.'
              r,←⊂''
              r,←⊂' * Creates a file "',configFilename,'" in that folder'
              r,←⊂' * Lets the user edit that file and makes sure that all mandatory settings are specified correctly'
              r,←⊂' * In case an alias is specified the alias is saved'
              r,←⊂' * Finally it attempts to open the new project'
              r,←⊂''
              r,←⊂'If no path is specified it acts on the current directory, but in that case the user'
              r,←⊂'is prompted for confirmation to avoid mishaps.'
              r,←⊂''
              r,←⊂'-acceptConfig:  By default a file cider.config is created, and an error is thrown in'
              r,←⊂'                case it already exists. You can use -acceptConfig to force CreateProject'
              r,←⊂'                to accept an already existing config file.'
              r,←⊂'-noEdit:        With -noEdit you can prevent the user from being asked to edit the config file.'
              r,←⊂'-alias:         In case you are going to work on the new project frequently you may specify'
              r,←⊂'                -alias=name'
              r,←⊂'-quiet          After a project has been created successfully, the user will be asked whether'
              r,←⊂'                she wants to open the project as well. You can enforce that without the user'
              r,←⊂'                being interrogated by setting the -quiet flag. Mainly useful for test cases.'
              r,←⊂'-ignoreUserExec Suppress execution of a user function defined in Cider''s config file on this occasion'
              r,←⊂'Note that the alias is not case sensitive'
          :Case ⎕C'CloseProject'
              r,←⊂'Breaks the Link between one or more projects and their associated files on disk.'
              r,←⊂''
              r,←⊂'You may specify one of:'
              r,←⊂' 1. One or more projects via a fully qualified namespace name'
              r,←⊂' 2. One or more projects via an [alias]'
              r,←⊂' 3. One or more projects via project path(s)'
              r,←⊂' 4. A mixture of 1, 2 and 3'
              r,←⊂' 5. Nothing; if only one project is open it will be closed.'
              r,←⊂'    If multiple projects are opened a list will be presented to the user'
              r,←⊂' 6. The -all flag, which closes all projects without further ado'
              r,←⊂''
              r,←⊂'Multiple projects must be separated by spaces or by commas.'
              r,←⊂''
              r,←⊂' * In case a particular project was specified a Boolean is reported, 1 indicating success'
              r,←⊂' * Otherwise the closed projects are reported in detail'
          :Case ⎕C'ProjectConfig'
              r,←⊂'Puts the config file of a project on display.'
              r,←⊂'By specifying the -edit flag the user might edit the file rather then just viewing it.'
              r,←⊂''
              r,←⊂'The optional parameter must be the path to a folder holding a cider.config file (a project).'
              r,←⊂'In case no path is provided Cider will present all currently opened projects to the user for'
              r,←⊂'selecting one, except when there is only one project open anyway.'
          :Case ⎕C'RunTests'
              r,←⊂'Prints the statement to the session that is designed to run the project''s test cases, if any.'
              r,←⊂''
              r,←⊂'The optional parameter must be the path to a folder holding a cider.config file (a project).'
              r,←⊂'In case no path is provided Cider will present all currently opened projects to the user for'
              r,←⊂'selecting one, except when there is only one project open anyway.'
          :Case ⎕C'Make'
              r,←⊂'Prints the statement to the session that is designed to run the project''s "make" function, if any.'
              r,←⊂''
              r,←⊂'The optional parameter must be the path to a folder holding a cider.config file (a project).'
              r,←⊂'In case no path is provided Cider will present all currently opened projects to the user for'
              r,←⊂'selecting one, except when there is only one project open anyway.'
          :Case ⎕C'Help'
              r,←⊂'Cider comes with two HTML files with documentation. This user command offers to put'
              r,←⊂'one or both of them on display in the default browser.'
          :EndSelect
      :Case 2
          r,←⊂'There is no additional help available'
      :EndSelect
    ∇

    ∇ r←AtLeastVersion min;currentVersion
      :Access Public Shared
      ⍝ Returns 1 if the currently running version is at least `min`.\\
      ⍝ If the current version is 17.1 then:\\
      ⍝ `1 1 1 0 ←→ AtLeastVersion¨16 17 17.1 18`\\
      ⍝ You may specify a version different from the currently running one via `⍺`:\\
      ⍝ `1 1 0 0 ←→ 17 AtLeastVersion¨16 17 17.1 18`
      currentVersion←{⊃⊃(//)⎕VFI ⍵/⍨2>+\⍵='.'}2⊃'.'⎕WG'aplversion'
      'Right argument must be length 1'⎕SIGNAL 11/⍨1≠≢min
      r←⊃min≤currentVersion
    ∇

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),11}

    ∇ r←r AddTitles titles
    ⍝ `r` is a matrix with data. `titles` is put on top of that matrix, followed by a row with `-` matching the lengths of each title
      r←⍉↑(⊂¨titles),¨' ',¨↓⍉r
      r[2;]←(≢¨r[1;])⍴¨'-'
    ∇

    ∇ path←AddSlash path
      path,←(~(¯1↑path)∊'/\')/'/'
    ∇

    ∇ r←ProcessAliases(prune edit quiet);bool;flag
      r←P.GetAliasFileContent
      :If prune
          :If 0<≢r
              bool←⎕NEXISTS¨r[;2]
          :AndIf ~∧/bool
              flag←0
              :Repeat
                  :If quiet
                      ⎕←'Pruning Cider aliases:'
                      ⎕←' ',' ',(~bool)⌿r
                  :OrIf 1 YesOrNo'Sure you want to prune ',((1+1<+/~bool)⊃'this' 'these'),'?'
                      :If 0=≢r←bool⌿r
                          ⎕NDELETE P.GetCiderAliasFilename
                      :Else
                          (⊂⊃¨{⍺,'=',⍵}/¨↓r)⎕NPUT P.GetCiderAliasFilename 1
                      :EndIf
                      flag←1
                  :Else
                      flag←1
                      r←0 2⍴''
                      :If ~quiet
                          ⎕←'Nothing done'
                      :EndIf
                  :EndIf
              :Until flag
          :Else
              :If ~quiet
                  ⎕←'Nothing to prune'
              :EndIf
              r←0 2⍴''
          :EndIf
      :EndIf
    ∇

    ∇ r←{namespace}CreateProject_(folder acceptFlag noEditFlag quietFlag ignoreUserExec);filename;success;config;projectFolder;parms;list
      :Access Public Shared
      r←''
      :If 0≡folder
          folder←⊃1 ⎕NPARTS''
          :If ~0 YesOrNo'Sure that you to convert ',folder,' into a project?'
              :Return
          :EndIf
      :EndIf
      :If (⊂,folder)∊,¨'.' './'
          folder←⊃1 ⎕NPARTS'./'
          :If ~YesOrNo'Sure you want to create the project in ',folder,' ?'
              :Return
          :EndIf
      :EndIf
      filename←(AddSlash folder),configFilename
      :If 0=⎕NC'namespace'
      :OrIf 0=≢namespace
          namespace←{{⍵↑⍨1+-⌊/(⌽⍵)⍳'/\'}¯1↓⍵}1⊃1 ⎕NPARTS filename
      :EndIf
      :If acceptFlag
          ('The -acceptConfig flag was set but no file "',configFilename,'" was found')Assert ⎕NEXISTS filename
      :Else
          :If ~⎕NEXISTS folder
              'Invalid path: parent must exist'Assert{0=≢⍵:1 ⋄ ⎕NEXISTS ⍵}1⊃⎕NPARTS{⍵↓⍨-(¯1↑⍵)∊'/\'}folder  ⍝ Parent folder must exist
              folder←∊1 ⎕NPARTS folder
              :If 1 YesOrNo'"',folder,'" does not exist yet - create?'
                  ⎕MKDIR folder
              :Else
                  r←'Cancelled by user' ⋄ →0
              :EndIf
          :EndIf
          CreateConfigFile filename namespace
      :EndIf
      :If ~noEditFlag
          1 P.ProjectConfig filename
          config←⊃⎕NGET filename 1
          :If success←0<≢(∊config)~' '
              config←⎕JSON⍠('Dialect' 'JSON5')⊣¯1↓∊config,¨⎕UCS 10
          :Else
              ⎕NDELETE filename
              :Return
          :EndIf
      :Else
          success←1
          config←⎕JSON⍠('Dialect' 'JSON5')⊣⊃⎕NGET filename
          PerformConfigChecks config
      :EndIf
      :If success
          :If namespace≢⍬
              projectFolder←1⊃⎕NPARTS filename
              :If 0=(⍎config.CIDER.parent).⎕NC config.CIDER.projectSpace
                  config.CIDER.projectSpace(⍎config.CIDER.parent).⎕NS''
              :Else
                  :If 0<≢((⍎config.CIDER.parent)⍎config.CIDER.projectSpace).⎕NL⍳16
                      :If 1<≢list←⊃P.##.F.Dir projectFolder
                      :OrIf 'cider.config'≢{1≠≢⍵:0 ⋄ ⊃,/1↓⎕NPARTS⊃⍵}list
                          :If quietFlag
                      ⍝ With quietFlag on there is nothing we can do but throw an error
                              'Both the target namespace and the source folder are not empty'Assert 0
                          :Else
                              :If YesOrNo'Target namespace "',(config.CIDER.parent,'.',config.CIDER.projectSpace),'" is not empty. Delete contents?'
                                  ((⍎config.CIDER.parent)⍎config.CIDER.projectSpace).{⎕EX ⎕NL⍳16}⍬
                              :Else
                                  'Both the target namespace and the source folder are not empty'Assert 0
                              :EndIf
                          :EndIf
                      :EndIf
                  :EndIf
              :EndIf
              parms←P.CreateOpenParms ⍬
              parms.folder←projectFolder
              parms.projectSpace←config.CIDER.projectSpace
              parms.parent←config.CIDER.parent
              parms.alias←{0≡⍵:'' ⋄ ⍵}Args.alias
              parms.quietFlag←quietFlag
              parms.watch←config.LINK.watch
              parms.ignoreUserExec←ignoreUserExec
          :AndIf {⍵:1 ⋄ 1 YesOrNo'Project successfully created; open as well?' ⋄ 1}quietFlag
          :AndIf ⊃P.OpenProject parms
              r←'Project created and opened'
          :Else
              r←'Project created'
          :EndIf
      :Else
          ⎕NDELETE filename
          r←'*** No action taken'
      :EndIf
    ∇

    ∇ {name}←CreateConfigFile(filename name);config;globalCiderConfigFilename
    ⍝ Copies the config template file over and injects the last part of the path of "filename" as "projectSpace"
      ('The folder already hosts a file "',configFilename,'"')Assert~⎕NEXISTS filename
      globalCiderConfigFilename←⎕SE.Cider.GetCiderGlobalConfigHomeFolder,'cider.config.template'
      :If 0=⎕NEXISTS globalCiderConfigFilename
          globalCiderConfigFilename(⎕NCOPY P.##.F.ExecNfunction)P.##.TatinVars.HOME,'/cider.config.template'
      :EndIf
      config←⎕JSON⍠('Dialect' 'JSON5')⊣⊃P.##.F.NGET globalCiderConfigFilename
      :If ~⎕SE.Cider.HasDotNet
          config.LINK.watch←'ns'
      :EndIf
      :If (⊃name)∊'#⎕'
          name←{⍵↓⍨⍵⍳'.'}name
      :EndIf
      ((~name∊⎕D,⎕A,'_∆⍙',⎕C ⎕A)/name)←'_'
      config.CIDER.projectSpace←⍕name
      config←⎕JSON⍠('Dialect' 'JSON5')('Compact' 0)⊣config
      (⊂config)P.##.F.NPUT filename
    ∇

    ∇ r←GetUserConfigFileTemplate;folder;filename
    ⍝ Checks whether the user has already a personal config file template.
    ⍝ If not the generic Cider config file template is copied into the user's Cider home folder,
    ⍝ Eventually the template is returned.
      folder←⎕SE.Cider.GetCiderGlobalConfigHomeFolder
      filename←folder',/cider.config.template'
      :If ~P.##.F.Exists filename
          :If 0<##.⎕NC'TatinVars'
              filename ⎕NCOPY ##.TatinVars.HOME,'/cider.config.template'
          :Else
              filename ⎕NCOPY CiderConfig.HOME,'/cider.config.template'
          :EndIf
      :EndIf
      :If
     
      :EndIf
      r←⎕JSON⍠('Dialect' 'JSON5')⊣⊃⎕NGET filename
    ∇

    ∇ (opCode path)←OpenFileDialogBox caption;ref;res;filename
    ⍝ opCodes:
    ⍝ ¯1 = Cancelled by user
    ⍝  1 = File found
    ⍝  0 = File not found
      opCode←¯1
      path←''
      ref←⎕NEW⊂'FileBox'
      ref.Caption←caption
      ref.(onFileBoxOK onFileBoxCancel)←1
      ref.File←'cider.config'
      res←ref.Wait
      :If 'FileBoxOK'≡2⊃res
          opCode←1
      :AndIf 0<≢ref.File
          :If ⎕NEXISTS filename←⊃,/ref.(Directory File)
              path←⊃1 ⎕NPARTS filename
          :Else
              opCode←0
          :EndIf
      :EndIf
    ∇


    ∇ r←CloseProject Args;list;bool;row;invalid;noop;report;projectID;buff;ind
      r←''
      report←1
      :If 0=≢Args.Arguments
          :If 0=noop←≢list←⎕SE.Cider.ListOpenProjects 0   ⍝ noop ←→ NoOf Open Projects
              ⎕←'There are no open Cider projects that could be closed'
              :Return
          :Else
              :If 1=noop
                  :If 1 YesOrNo'Sure you want to close the project <',(⊃list[1;]),'>?'
                      r←buff←P.CloseProject ⍬
                  :Else
                      r←'Cancelled by user' ⋄ →0
                  :EndIf
              :Else
                  :If 0<≢ind←'Select Cider project(s) to be closed' 1 Select list[;1]
                      r←+/P.CloseProject list[ind;1]
                      'Something went wrong'Assert r=≢ind
                      r←1↓∊(⎕UCS 13),¨↓⎕FMT list[ind;]
                  :EndIf
              :EndIf
          :EndIf
      :Else
          projectID←⊃{⍺,' ',⍵}/Args.Arguments  ⍝ Can be a namespace, a path or an alias
          ((projectID=',')/projectID)←' '
          projectID←' '(≠⊆⊢)projectID
          projectID←TranslateAlias¨projectID
          :If 0∊invalid←(~∨/¨'/\'∘∊¨projectID)∧~({1 ⎕C ⍵↑⍨¯1+⍵⍳'.'}¨projectID)∊,¨'#' '⎕SE'
              (invalid/projectID)←(⊂'#.'),¨invalid/projectID
          :EndIf
          :If 1∊invalid←~{(⎕NS'').{0=⎕NC ⍵}⍵~'[]'}¨projectID
              11 ⎕SIGNAL⍨'Invalid project name(s): ',⊃{⍺,',',⍵}/invalid/projectID
          :EndIf
          list←P.ListOpenProjects 0
          invalid←~((⎕C projectID)∊⎕C list[;1])∨(P.##.F.NormalizePath projectID)∊P.##.F.NormalizePath list[;2]
          :If 1∊invalid
              ('Not an open Cider project: ',⊃{⍺,',',⍵}/invalid/projectID)Assert∧/~invalid
          :EndIf
          r←+/list∘P.CloseProject¨projectID
      :EndIf
      :If 0<≢r
          :If ' '=1↑0⍴∊r
              r←'These projects were closed: ',(⎕UCS 13),r
          :Else
              r←'Number of projects closed: ',⍕r
          :EndIf
          report←0
      :EndIf
      :If 0=≢⎕SE.Cider.ListOpenProjects 0
      :AndIf YesOrNo'Do you wish to )CLEAR the workspace?'
          :If report
              :If ' '=1↑0⍴∊r
                  r←('These projects were closed:'),(⎕UCS 13),r,(⎕UCS 13),(6⍴' '),')CLEAR  ⍝ Execute this for a clear WS'
              :Else
                  r←('One project was closed.'),(⎕UCS 13),(6⍴' '),')CLEAR  ⍝ Execute this for a clear WS'
              :EndIf
          :Else
              :If ' '=1↑0⍴∊r
                  r,←(⎕UCS 13),(6⍴' '),')CLEAR  ⍝ Execute this for a clear WS'
              :Else
                  r,←(6⍴' '),')CLEAR  ⍝ Execute this for a clear WS'
              :EndIf
          :EndIf
      :Else
          :If report
              :If ' '=1↑0⍴∊r
                  r←('These projects were closed:'),(⎕UCS 13),r
              :Else
                  r←'One project was closed.'
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←TranslateAlias alias;aliase;row
      :If '[]'≡alias[1,≢alias]
          aliase←⎕SE.Cider.GetAliasFileContent
          row←aliase[;1]⍳⊂alias~'[]'
          ('Unknown alias: ',alias)Assert row≤≢aliase
          r←2⊃aliase[row;]
      :Else
          r←alias
      :EndIf
    ∇

    ∇ r←ShowHelp dummy;list;folder;flag;answer;msg
      r←''
      folder←1⊃⎕NPARTS ##.SourceFile
      list←⊃⎕NINFO⍠('Wildcard' 1)⊣folder,'*'
      folder←⊃(∨/'aplteam-Cider'⍷↑list)/list
      folder,←'/html/'
      :If 0=≢list←⊃⎕NINFO⍠('Wildcard' 1)⊣folder,'*.html'
          r←'No documentation found for Cider in ',folder
      :Else
          list←{⊃,/1↓⎕NPARTS ⍵}¨list
          flag←0
          :Repeat
              msg←'Select document to be viewed:'
              answer←msg 1 Select 2⊃∘⎕NPARTS¨list
              :If (⊂answer)∊1 2(1 2)
                  :Select answer
                  :Case 1
                      {}⎕SE.UCMD'Open file://',folder,1⊃list
                  :Case 2
                      {}⎕SE.UCMD'Open file://',folder,2⊃list
                  :Case 1 2
                      {}{⎕SE.UCMD'Open file://',⍵}¨folder∘,¨list
                  :EndSelect
                  flag←1
              :Else
                  flag←1
              :EndIf
          :Until flag
      :EndIf
    ∇

    ∇ (rc msg)←CheckConfig json;dmx
    ⍝ Reads the config file and performs basic checks on it
    ⍝ Returns:
    ⍝  0 in case all is fine
    ⍝  1 in case something is wrong. In this case `msg` is not empty and carries a message
      msg←''
      :If 0=json.CIDER.⎕NC'projectSpace'
          msg←'"projectSpace" is missing in the [Cider] section'
      :ElseIf '?'∊json.CIDER.projectSpace
      :OrIf 0=≢json.CIDER.projectSpace
          msg←'"projectSpace" is not defined properly in the [Cider] section'
      :ElseIf ∨/'#⎕'∊json.CIDER.projectSpace
          msg←'"projectSpace" carries either a "#" or a "⎕" but must not'
      :ElseIf 0∨.≠{⊃(⎕NS'').⎕NC ⍵}¨⊆{'.'(≠⊆⊢)⍵}json.CIDER.projectSpace
          msg←'"projectSpace" is not the name of a namespace (like "foo" or "foo.goo")'
      :ElseIf 0=json.CIDER.⎕NC'parent'
          msg←'"parent" is not defined in the [Cider] section'
      :ElseIf ~{('#'=1⍴⍵)∨('⎕SE'≡1 ⎕C 3⍴⍵)}json.CIDER.parent
          msg←'"parent" starts with neither "#" nor "⎕SE"'
      :ElseIf {('#'=1⍴⍵)∨('⎕SE'≡1 ⎕C 3⍴⍵)}json.CIDER.parent
      :AndIf 0∨.≠{⊃(⎕NS'').⎕NC ⍵}¨⊆1↓{'.'(≠⊆⊢)⍵}json.CIDER.parent
          msg←'"parent" is not a proper definition (like "#" or "⎕SE" or "#.foo" etc.)'
      :EndIf
      rc←0≠≢msg
    ∇

    ∇ {r}←EditAliasFile dummy;filename;data_;Local;aliases;b;report;buff;b2;b3;flag;b4;b5;aliases_;b6
      r←''
      filename←P.GetCiderAliasFilename
      :If ~⎕NEXISTS filename
          3 ⎕MKDIR 1⊃⎕NPARTS filename
          (⊂'')⎕NPUT filename
      :EndIf
      aliases_←P.GetAliasFileContent
      :If 0<≢aliases←⍕aliases_
          aliases_←⊃¨{⍺,'=',⍵}/¨↓aliases_
          :Repeat
              ⎕ED'aliases'
              aliases←{'⍝'∊⍵:⍵↑⍨¯1+⍵⍳'⍝' ⋄ ⍵}¨↓aliases   ⍝ Cider might inject comments to highlight problems, see below.
              aliases←(aliases∨.≠¨' ')⌿aliases
              aliases←{b←' '=⍵ ⋄ ⍵/⍨~(∧\b)∨(⌽∧\⌽b)∨'  '⍷⍵}¨aliases
              aliases←{' '(≠⊆⊢)⍵}¨aliases
              aliases←⊃¨{⍺,'=',⍵}/¨aliases
              flag←0
              :If aliases≢aliases_
                  aliases_/⍨←({⍵↑⍨¨⍵⍳¨'='}aliases_)∊{⍵↑⍨¨⍵⍳¨'='}aliases   ⍝ Get rid of deleted ones
                  report←(≢aliases)⍴⊂''
                  :If ∨/b←~1=aliases+.=¨'='
                      (b/report)←⊂' ⍝ Does not carry exactly one "="'
                  :EndIf
                  buff←↑{'='(≠⊆⊢)⍵}¨(~b)/aliases
                  :If ∨/b2←~{∧/⍵∊⎕A,(⎕C ⎕A),⎕D,'-'}¨buff[;1]
                      b3←(~b)\b2
                      (b3/report){'⍝'∊⍺:⍺,'; ',⍵ ⋄ ⍺,' ⍝ ',⍵}←⊂'An alias must consist of nothing but A-Z, a-z, 0-9 and a hyphen'
                  :EndIf
                  :If ∨/b2←~⎕NEXISTS buff[;2]
                      b3←(~b)\b2
                      (b3/report){'⍝'∊⍺:⍺,'; ',⍵ ⋄ ⍺,' ⍝ ',⍵}←⊂'Folder does not exist'
                  :EndIf
                  :If ∨/b4←(~b2)\~⎕NEXISTS(~b2)/buff[;2],¨⊂'/cider.config'
                      b5←(~b)\b4
                      (b5/report){'⍝'∊⍺:⍺,'; ',⍵ ⋄ ⍺,' ⍝ ',⍵}←⊂'Folder does not contain a Cider config file'
                  :EndIf
                  :If {(≢⍵)>≢∪⍵}buff←{⍵↓⍨⍵⍳'='}¨aliases
                      b6←~{(⍳≢⍵)=⍵⍳⍵}buff
                      (b6/report)←⊂'⍝ Path has already an alias'
                  :EndIf
                  :If 0=≢∊report
                      flag←1
                  :Else
                      aliases←(1+⌈/≢¨aliases)↑¨aliases
                      aliases←aliases{0=≢⍵:⍺ ⋄ ⍺,'⍝ ',⍵}¨report
                  :EndIf
                  :If ~flag
                      aliases←⍕↑{'='(≠⊆⊢)⍵}¨aliases
                  :EndIf
              :Else
                  flag←1
              :EndIf
          :Until flag
          (⊂aliases)⎕NPUT filename 1
      :Else
          r←'There are no aliases defined in ',filename
      :EndIf
    ∇

    YesOrNo←{⍺←⊢ ⋄ ⍺ ⎕SE.Cider.##.C.YesOrNo ⍵}

    ∇ r←{caption}SelectFromAliases data;row
      r←⍬
      caption←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'caption'
      :If 0=≢data
          data←P.GetAliasFileContent
      :EndIf
      :If 0<≢data
          data[;1]←{'[',⍵,']'}¨data[;1]
          caption←'Select project to be opened',({0=≢⍵:⍵ ⋄ ' ',⍵,' '}caption),':'
      :AndIf ⍬≢row←'Select project to be opened:'SelectOneItem↓⎕FMT data
          r←row⊃data[;2]
      :EndIf
    ∇

    ∇ index←{caption}SelectOneItem options;flag;answer;question;index;bool;value
    ⍝ Presents `options` as a numbered list and allows the user to select exactly one of them.\\
    ⍝ If the user aborts `index` is `⍬`.
      caption←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'caption'
      flag←0
      :Repeat
          ⎕←(⎕PW-1)⍴'-'
          :If 0<≢caption
              ⎕←caption
          :EndIf
          ⎕←⍪{((⊂'. '),¨⍨(⊂3 0)⍕¨⍳⍴⍵),¨⍵}options
          ⎕←''
          :If 0<≢answer←⍞,0/⍞←question←'Select one item (q=quit) : '
              answer←(⍴question)↓answer
              :If 1=≢answer
              :AndIf answer∊'Qq'
                  :If answer∊'Qq'
                      index←⍬
                      :Return
                  :Else
                      index←⍳≢options
                      flag←1
                  :EndIf
              :ElseIf 0<≢answer
                  (bool value)←⎕VFI answer
                  :If ∧/bool
                      value←bool/value
                  :AndIf ∧/value∊⍳⍴options
                      index←value
                      flag←1
                  :EndIf
              :EndIf
          :EndIf
      :Until flag
      index←{1<≢⍵:⍵ ⋄ ⊃⍵}index
    ∇

    Select←{⍺←⊢ ⋄ ⍺ ⎕SE.Cider.##.C.Select ⍵}

    ∇ {r}←PerformConfigChecks config;buff;namespace;path
      r←0
      :If 0<≢buff←config.CIDER.dependencies.tatin
          :If '='∊buff
              'Invalid config parameter ("dependencies.tatin" has more than one "=")'Assert 1='='+.=buff
              (path namespace)←'='(≠⊆⊢)buff
              'Invalid config parameter ("dependencies.tatin")'Assert 0=(⎕NS'').{⎕NC ⍵}namespace
          :EndIf
      :EndIf
      :If 0<≢buff←config.CIDER.dependencies_dev.tatin
          :If '='∊buff
              'Invalid config parameter ("dependencies_dev.tatin" has more than one "=")'Assert 1='='+.=buff
              (path namespace)←'='(≠⊆⊢)buff
              'Invalid config parameter ("dependencies_dev.tatin")'Assert 0=(⎕NS'').{⎕NC ⍵}namespace
          :EndIf
      :EndIf
    ∇

    ∇ path←{verb}GetProjectPath Args;list;index;aliasDefs;bool;alias;info
      path←''
      verb←{0<⎕NC ⍵:⍎⍵ ⋄ 'open'}'verb'
      :If 0≡Args._1
          list←⎕SE.Cider.ListOpenProjects 0
          :Select ≢list
          :Case 0
              'No open projects found'Assert 0
          :Case 1
              path←⊃list[1;2]
          :Else
              :If 0=≢index←'Select a Cider project:'Select↓⎕FMT list
                  :Return
              :EndIf
              path←2⊃list[index;]
          :EndSelect
      :Else
          aliasDefs←P.GetAliasFileContent
          path←Args._1
          :If (⊂,path)∊,¨'[' '[?' '[?]'
              :If 0=≢path←SelectFromAliases aliasDefs
                  :Return
              :EndIf
          :ElseIf '['=1⍴path
          :AndIf '*'=¯1↑path~'[]'
              bool←(¯1↓path~'[]'){(⎕C(≢⍺)↑[2]⍵)∧.=⎕C ⍺}↑aliasDefs[;1]
              :Select +/bool
              :Case 0
                  :Return
              :Case 1
                  (alias path)←aliasDefs[bool⍳1;]
                  :If 0=1 YesOrNo'Sure you want to ',verb,' "',path,'" ?'
                      :Return
                  :EndIf
              :Else
                  info←'(',((⍕+/bool),' of ',(⍕≢aliasDefs)),')'
                  :If 0=≢path←info SelectFromAliases bool⌿aliasDefs
                      :Return
                  :EndIf
              :EndSelect
          :EndIf
      :EndIf
    ∇

:EndClass
