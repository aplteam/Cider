:Class Cider
⍝ This script contains Cider's application code.\\
⍝ Cider is a project manager for Dyalog APL.\\
⍝ For details see <https://github.com/aplteam/Cider>

    ⎕IO←1 ⋄ ⎕ML←1
    L←⎕SE.Link
    CR←⎕UCS 13

    ∇ r←Version
      :Access Public Shared
      r←'0.29.0-beta-2+410'
      ⍝ * 0.29.0 ⋄ 2023-06-18
      ⍝   * BREAKING CHANGE: the user command and API function `ViewConfig` was renamed to `ProjectConfig` in order
      ⍝     to bring it in line with Tatin which has ]PackageConfig
      ⍝   * Problems when editing a project config file are now explained
      ⍝   * Bug fixes
      ⍝     * Opening a project showed a mutilated question; introduced with 0.28.1
      ⍝     * The checks when editing the Cider project config file allowed `projectSpace` and `make` to be fully
      ⍝       qualified. That's no longer possible, but `RunTests` and `RunMake` allow for that
      ⍝ * 0.28.0 ⋄ 2023-06-14
      ⍝   * `]CloseProjects` now presents a list of open projects if no argument is provided and there are
      ⍝     multiple projects currently open
      ⍝   * `CloseProjects` now accepts multiple projects as argument
      ⍝ * 0.27.1 ⋄ 2023-06-02
      ⍝   * Bug fixes
      ⍝     * `CloseProject` produced an error when the question "Do you wish to )CLEAR the workspace?" was negated
      ⍝     * An attempt to open a project "foo" when there is alreday a class "foo" was doomed.
      ⍝       Similarly, when an object "foo" already exists but is not a namespace, class or interface it failed.
      ⍝     * Documentation improved regarding installing and updating Cider
      ⍝ * 0.27.0 ⋄ 2023-05-17
      ⍝   * `]ListTatinPackages` now marks all URLs that do not point to https://tati.dev
      ⍝   * `]CIDER.CloseProject` now offers to delete project namespace(s) from the workspace in case not
      ⍝     all projects are closed.
      ⍝   * Syntax change: an alias is only recognized with an openeing AND a closing square bracket as in [foo]
      ⍝   * Internal fix in `CheckTatinFoldersForLaterVersions`
      ⍝ * 0.26.1 ⋄ 2023-05-06
      ⍝   * Bug fix regarding the handling of dependencies.tatin and dependencies_dev.tatin
      ⍝   * Help page for CreateProject corrected and enhanced
      ⍝ * 0.26.0 ⋄ 2023-05-02
      ⍝   * BREAKING CHANGE: `GetCiderConfigFilename` renamed to `GetCiderGlobalConfigFilename`
      ⍝   * BREAKING CHANGE: `GetCiderConfigHomeFolder` renamed to `GetCiderGlobalConfigHomeFolder`
      ⍝   * Cider injects now a namespace `TatinVars` into the root of any project becoming eventually a package
      ⍝   * New project config parameter `distributionFolder` introduced which is automatically injected
      ⍝     into any opened Cider project
      ⍝   * Shared public function `GetCiderGlobalConfigFileContent` introduced
      ⍝   * Documentation corrected regarding the global Cider config file.
    ∇

    :Field Private Shared ReadOnly    FAILURE←0
    :Field Private Shared ReadOnly    SUCCESS←1

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),11}

    ∇ (successFlag ∆LOG)←OpenProject y;parms;configFilename;config;bool;res;linkOptions;source;p;dmx;projectSpace_;parms;fn;qdmx;pkgStatus;buff
    ⍝ Open a Cider project.\\
    ⍝ `y` must be one of:
    ⍝  * a namespace holding all required parameters. Such a namespace can be created by calling `CreateOpenParms`
    ⍝  * A character vector holding the full path to a project
      :Access Public Shared
      successFlag←FAILURE ⋄ ∆LOG←''
      :If 80=⎕DR y
          parms←CreateOpenParms''
          parms.folder←y
      :Else
          parms←CreateOpenParms y
      :EndIf
      '"folder" must be specified'Assert 0<parms.⎕NC'folder'
      '"folder" must be specified'Assert 0<≢parms.folder
      '"projectSpace" must be specified'Assert 0<parms.⎕NC'projectSpace'
      '"watch" must be one of: ns|dir|both'Assert(⊂⎕C parms.watch)∊'ns' 'dir' 'both' 0
      p←{⍺←~parms.quietFlag ⋄ ⍺ PrintToSession ⍵}
      parms←(p GetFolderFromAlias)parms
      ('Folder does not exist: ',parms.folder)Assert ##.FilesAndDirs.Exists parms.folder
      p((1+parms.importFlag)⊃'Loading' 'Importing'),' project from ',parms.folder
      parms.projectSpace←⍕parms.projectSpace
      :If 0<≢parms.parent
          parms.parent←,parms.parent
          'First level of parent must be either "#" or "⎕SE"'Assert(⊆1 ⎕C{⍵↑⍨¯1+⍵⍳'.'}parms.parent)∊,¨'#' '⎕SE'
          ('Parent namespace "',parms.parent,'" does not exist')Assert(9=⎕NC parms.parent)∨(⊂,1 ⎕C parms.parent)∊,¨'#' '⎕SE'
      :EndIf
      :If 0<≢parms.projectSpace
          ('"projectSpace" must not carry a "." (see "parent"')Assert 0='.'+.=parms.projectSpace
          'Project space is not a valid APL name'Assert{0::0 ⋄ 0=(⎕NS'').⎕NC ⍵}⍕parms.projectSpace
      :EndIf
      parms.alias←⎕C parms.alias
      :If parms.alias≡'.'
          parms.alias←⎕C 2⊃{1 ⎕NPARTS(-(¯1↑⍵)∊'/\')↓⍵}parms.folder
      :EndIf
      AddAlias parms.folder parms.alias
      configFilename←parms.folder,'/cider.config'
      ('No file "cider.config" found in ',parms.folder)Assert ##.FilesAndDirs.Exists configFilename
      config←Get_JSON5 configFilename
      :If 0=≢parms.projectSpace                                                         ⍝ Was it specified as argument?
      :AndIf 0=≢parms.projectSpace←config.CIDER.projectSpace                            ⍝ Nope, so the config file rules...
          parms.projectSpace←'#'                                                        ⍝ ... but only is it is not empty
      :EndIf
      :If 0=≢parms.parent                                                               ⍝ Was it specified as argument?
          parms.parent←config.CIDER.parent                                              ⍝ Nope, so the config file rules
      :EndIf
      :If 0=≢parms.projectSpace
          projectSpace_←⍎parms.parent                                                   ⍝ Is either # or ⎕SE
      :Else
          :If ~(,⊂1 ⎕C parms.parent)∊,¨'#' '⎕SE'
              ('Namespace <',parms.parent,' does not exist')Assert 9=⎕NC parms.parent
          :EndIf
          projectSpace_←⍎parms.projectSpace(⍎parms.parent).⎕NS''                        ⍝ Create project space from "parent" to avoid problems
      :EndIf
      config←projectSpace_.⎕NS config
      'Already opened?!'Assert~CheckForAlreadyOpened projectSpace_
      config←parms.folder PolishProperties config
      config←CheckParameters config
      configFilename HandleSysVars config
      source←parms.folder,(0<≢config.CIDER.source)/'/',config.CIDER.source              ⍝ For linking we are only interested in the code folder
      ('Source folder does not exist: ',parms.folder)Assert ##.FilesAndDirs.Exists parms.folder
      linkOptions←ExtractLinkOptions config                                             ⍝ Merge the default options with Cider's options
      :If 0≢parms.watch
          config.LINK.watch←linkOptions.watch←parms.watch
      :EndIf
      p'Bringing in the source code...'
      projectSpace_←CheckTargetNamespaceAndLinkFolder projectSpace_ parms config.CIDER.source
      :If parms.importFlag
          res←linkOptions ⎕SE.Link.Import projectSpace_ source                          ⍝ Get the code into the WS
          dmx←⎕DMX
          ('LINK failed to import the code (,',dmx.EM,')')⎕SIGNAL dmx.EN/⍨∨/'Error:'⍷res
      :Else
          res←linkOptions ⎕SE.Link.Create projectSpace_ source                          ⍝ Get the code into the WS
          dmx←⎕DMX
          ('LINK failed to load the code (',dmx.EM,')')⎕SIGNAL dmx.EN/⍨∨/'Error:'⍷res
          :If ∨/'ERRORS ENCOUNTERED:'⍷res
              1 p↓Frame CR(≠⊆⊢)res
          :EndIf
      :EndIf
      p'  Code established, "watch" is "',linkOptions.watch,'"'
      :If 0=parms.noPkgLoad
          pkgStatus←parms.folder CheckForTatinPackages config
          :If 0<pkgStatus
              :If 0=parms.importFlag
                  :Trap 0
                      CheckPackagesStatus config parms pkgStatus
                  :Else
                      qdmx←⎕DMX
                      buff←''
                      buff,←⊂'ERROR: Checking Tatin package status in ',parms.folder
                      buff,←⊂'       failed: ',{(1⊃⍵),' in ',{⍵↑⍨⍵⍳']'}(2⊃⍵)}qdmx.DM
                      1 p↓Frame buff
                  :EndTrap
              :EndIf
              :Trap 0
                  {}LoadTatinPackages config parms.folder(⍕projectSpace_)
              :Else
                  qdmx←⎕DMX
                  buff←''
                  buff,←⊂'ERROR: loading Tatin packages from ',parms.folder
                  buff,←⊂'       failed: ',{(1⊃⍵),' in ',{⍵↑⍨⍵⍳']'}(2⊃⍵)}qdmx.DM
                  1 p↓Frame buff
              :EndTrap
          :EndIf
      :EndIf
      InjectConfigDataIntoProject config projectSpace_ parms.folder
      InjectTatinVars projectSpace_ parms.folder
      {}ExecProjectInitFunction⍣(~parms.suppressInit)⊣config projectSpace_
      ExecUserFunction config
      successFlag←SUCCESS
      :If 0=parms.quietFlag
      :AndIf 0=parms.importFlag
          p'*** Project successfully ',((1+parms.importFlag)⊃'loaded' 'imported'),' and established in "',parms.parent,,{(,'#')≡,⍵:'"' ⋄ '.',⍵,'"'}parms.projectSpace
          CheckForGit parms.folder config
      :EndIf
      ⍝Done
    ∇

    ∇ {r}←InjectTatinVars(projectRoot folder);cfg
    ⍝ When a package is loaded a namespace `TatinVars` is injected into the root of the package by Tatin.
    ⍝ In case `projectSpace` is a Tatin package Cider is injecting this into the root of the project in order
    ⍝ to make it as simple as possible for the user.
    ⍝ Whether the project is a going to be a package is determined by looking for a file ⎕se._Tatin.Registry.CFG_Name.
    ⍝ In case `TatinVars` as injected a ` is returned, otherwise a 0.
    ⍝ This allows a developer working on the project to acces `TatinVars` as if it were loaded as a package.
      r←0
      :If ⎕NEXISTS folder,'/',⎕SE._Tatin.Registry.CFG_Name
          cfg←⎕SE._Tatin.Registry.ReadPackageConfigFile folder
          ⎕SE._Tatin.Client.EstablishStuffInTatinVars projectRoot cfg folder
          r←1
      :EndIf
    ∇

    ∇ config←projectHome PolishProperties config;buff;noOfCommas;folders;question;errorFlag;errMsg;f1;f2;f3
    ⍝ Temporary solution for several problems:
    ⍝ I.
    ⍝ With version 0.25.0 Cider expects "dependencies" and/or "dependencies_dev" instead of "tatinFolder".
    ⍝ This function looks for "tatinFolder", and if it is found suggests an automated conversion.
    ⍝ It expects to find either a single comma or no comma at all in "tatinFolder", otherwise it throws an error.
    ⍝ II.
    ⍝ The property `githubUsername` is deleted from the config file because is not used anymore
    ⍝ III.
    ⍝ With version 0.26.0 the property `distributionFolder` was introduced.
    ⍝ If not found it is injected as an empty character vector.
    ⍝ Note that with the introduction of Cider version 1.0 this function can be removed  ⍝TODO⍝
      errorFlag←0
      errMsg←''
      f1←f2←f3←0
      :If 0<config.CIDER.⎕NC'tatinFolder'
          question←''
          question,←⊂'AutoConversion@This project carries the (now deprecated) property "tatinFolder".'
          question,←⊂'Would you like to convert it automatically into the new format?'
          :If 1 YesOrNo question
              'dependencies' 'dependencies_dev'config.CIDER.⎕NS¨⊂''
              config.CIDER.(dependencies dependencies_dev).tatin←⊂''
              folders←config.CIDER.tatinFolder
              :If (noOfCommas←','+.=folders)∊0 1
                  :If ','=1⍴folders
                  ⍝ This project has only development dependencies
                      config.CIDER.dependencies_dev.tatin←' '~⍨1↓folders
                  :ElseIf 0=noOfCommas
                  ⍝ This project has dependencies but not for development
                      config.CIDER.dependencies.tatin←folders~' '
                  :Else
                  ⍝ This project has ordinary as well as development dependencies
                      config.CIDER.(dependencies dependencies_dev).tatin←' '~¨⍨','(≠⊆⊢)folders
                      config.CIDER.⎕EX'tatinFolder'
                  :EndIf
                  f1←1
              :Else
                  errorFlag←1
                  errMsg,←⊂'Project carries old (now deprecated) property "tatinfolder" but with an invalid syntax:'
                  errMsg,←⊂'It has ',(⍕noOfCommas),' commas: must be zero or one.'
              :EndIf
              config.CIDER.⎕EX'tatinFolder'
          :Else
              errorFlag←1
              errMsg,←⊂'Project carries old (now deprecated) property "tatinfolder" but user refused to convert:'
              errMsg,←⊂'The project cannot be opened.'
          :EndIf
      :EndIf
      :If 0<config.CIDER.⎕NC'githubUsername'
          config.CIDER.⎕EX'githubUsername'
          f2←1
      :EndIf
      :If 0=config.CIDER.⎕NC'distributionFolder'
          config.CIDER.distributionFolder←''
          f3←1
      :EndIf
      :If f1∨f2∨f3
          config Put_JSON5(##.FilesAndDirs.AddTrailingSep projectHome),'cider.config'
          p'   Modified file "cider.config" saved in ',projectHome
      :EndIf
      :If errorFlag
          1 p↓Frame errMsg
          ⎕SIGNAL 11
      :EndIf
    ∇

    ∇ status←path CheckForTatinPackages config;folders;list;bool;report;this;parms
    ⍝ Checks whether at least one Tatin install folder is defined, does exist and is not empty, in which case a 1 is returned.
    ⍝ In case at least one install folder contains just a dependency file and a build file but nothing else then...
    ⍝ * when the user goes for re-installing the packages, a 2 is returned
    ⍝ * when she does not a 3 is returned
      status←0
      folders←GetTatinDepedencyFolders config
      :If 0<≢folders
          folders←{'='∊⍵:⍵↑⍨¯1+⍵⍳'=' ⋄ ⍵}¨folders
      :AndIf 0<≢folders←(0<≢¨folders)/folders
      :AndIf 0<≢folders←(##.FilesAndDirs.Exists(⊂path,'/'),¨folders)/folders
          status←0<+/≢¨list←{⊃0 ⎕NINFO⍠('Wildcard' 1)⊣⍵}¨(⊂path,'/'),¨folders,¨⊂'/*'
      :AndIf 1∊bool←0=≢¨ListDirs¨(⊂path,'/'),¨folders,¨'/'
          :If YesOrNo'Tatin install folder(s) do no contain packages - do you want them re-installed?'
              status←2
              parms←⎕SE.Tatin.CreateReInstallParms
              parms.update←YesOrNo'Would you like to install later version, if available?'
              folders←bool/folders
              :For this :In (⊂path,'/'),¨folders
                  report←parms ⎕SE.Tatin.ReInstallDependencies this
              :EndFor
          :Else
              status←3
          :EndIf
      :EndIf
    ∇

    ∇ r←GetTatinDepedencyFolders config
    ⍝ Returns a vector of two-item vectors with (path namespaceName) from the project `config` namespace.
    ⍝ `r` might be empty in case there are no Tatin dependencies, otherwise it is a vector character vectors
    ⍝ with relative path and optionally the name of a target namespace (separated by "=").
      r←''
      r,←⊂'dependencies'GetDependencies config
      r,←⊂'dependencies_dev'GetDependencies config
      r~←⊂''
    ∇

    ∇ ok←CheckTargetNamespace projectSpace
      :If 0=⎕NC⍕projectSpace
          ok←1
      :ElseIf 0=≢projectSpace.⎕NL 2 3 4 9
          ok←1
      :Else
          ok←0
      :EndIf
    ∇

    ∇ r←name GetDependencies config;ref
    ⍝ Use this to return the content of "tatin" in either "dependencies" or "dependencies_dev" (defined by "name")
    ⍝ but an empty vector in case the "tatin" sub-key does not exist
      :Access Public Shared
      r←''
      :If 0<config.CIDER.⎕NC name
          ref←config.CIDER.⍎name
          r,←ref⍎'tatin'
      :EndIf
    ∇

    ∇ parms←CreateOpenParms y;list;b;l
    ⍝ Creates a namespace with all parameters one might pass to `OpenProject`.\\
    ⍝ `y` might be an empty vector or a namespace with some such parameters.
    ⍝ Any parameters passed this way overwrite defaults.
      :Access Public Shared
      parms←(1⊃1↓⎕RSI,⎕THIS).⎕NS''      ⍝ Create namespace where we got called from
      parms.folder←''
      parms.projectSpace←''
      parms.quietFlag←0
      parms.alias←''
      parms.parent←''
      parms.suppressInit←0
      parms.importFlag←0
      parms.noPkgLoad←0
      parms.watch←(1+HasDotNet)⊃'ns' 'both'
      parms.checkPackageVersions←⍬      ⍝ ⍬ means the user will be asked; 0 means don't. 1 means yes, check, but ask before updating, 2 means update
      parms.githubUsername←''
      :If ~(⊂y)∊''⍬
      :AndIf 9=⎕NC'y'
          :If 9=y.⎕NC'projectSpace'
              y.projectSpace←⍕y.projectSpace
          :EndIf
          :If 9=y.⎕NC'parent'
              y.parent←⍕y.parent
          :EndIf
          '⍵ must not contain references'Assert 0=≢y.⎕NL 9
          (b{0=+/b:'' ⋄ 'Invalid parameter: ',⊃{⍺,',',⍵}/⍺/⍵}l)Assert 0=+/b←~(l←' '~⍨¨↓y.⎕NL 2)∊' '~⍨¨↓parms.⎕NL 2
          :If 0<≢list←' '~⍨¨↓y.⎕NL 2
              parms⍎¨list{' '=1↑0⍴⍵:⍺,'←''',⍵,'''' ⋄ ⍵≡⍬:⍺,'←⍬' ⋄ ⍺,'←',⍕⍵}¨y.{⍎⍵}¨list
          :EndIf
      :EndIf
    ∇

    ∇ report←RenameInfo_url folder
    ⍝ With version 0.80.0 of Tatin the property "info_url" was renamed to "project_url".
    ⍝ Cider was amended accordingly with version 0.22.0.
    ⍝ This function takes a folder and searches for Cider config file in all sub folders.
    ⍝ In every file found `info_url` is renamed to `project_url`.
    ⍝ The names off all files that got changed are returned as a matrix.
      :Access Public Shared
      ('Is not a directory: ',folder)Assert ##.FilesAndDirs.IsDir folder
      report←''
      RenameInfo_url_ folder
      report←⍪report
      ⍝Done
    ∇

    ∇ RenameInfo_url_ folder;filename;list;ns
      filename←folder,'/cider.config'
      :If ##.FilesAndDirs.IsFile filename
          ns←ReadProjectConfigFile filename
          :If 0<ns.CIDER.⎕NC'info_url'
              ns.CIDER.project_url←ns.CIDER.info_url
              ns.CIDER.⎕EX'info_url'
              ns WriteProjectConfigFile filename
              report,←⊂filename
          :EndIf
      :EndIf
      list←##.FilesAndDirs.ListDirs folder
      :If 0<≢list
          RenameInfo_url_¨list
      :EndIf
      ⍝Done
    ∇

    ∇ report←Remove_githubUsername folder
    ⍝ With version 0.24.0 of Cider the property "githubUsername" was removed from the config file.
    ⍝ Cider now establishes the "owner" of a project on GitHub by investigating `project_url`.
      :Access Public Shared
      ('Is not a directory: ',folder)Assert ##.FilesAndDirs.IsDir folder
      report←''
      Remove_githubUsername_ folder
      report←⍪report
      ⍝Done
    ∇

    ∇ Remove_githubUsername_ folder;filename;list;ns
      filename←folder,'/cider.config'
      :If ##.FilesAndDirs.IsFile filename
          ns←ReadProjectConfigFile filename
          :If 0<ns.CIDER.⎕NC'githubUsername'
              ns.CIDER.⎕EX'githubUsername'
              ns WriteProjectConfigFile filename
              report,←⊂filename
          :EndIf
      :EndIf
      list←##.FilesAndDirs.ListDirs folder
      :If 0<≢list
          RenameInfo_url_¨list
      :EndIf
      ⍝Done
    ∇

    ∇ path←GetProjectPath project;list;index;aliasDefs;bool;alias;info
      :Access Public Shared
      path←''
      :If 0≡project
      :OrIf 0=≢project
          list←ListOpenProjects 0
          :Select ≢list
          :Case 0
              ⎕←'No open Cider project found'
              :Return
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
          :If path≡'[?]'
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
      :EndIf
    ∇

    ∇ r←GetValidLinkParams
      r←⍬
      r,←⊂'arrays'
      r,←⊂'beforeRead'
      r,←⊂'beforeWrite'
      r,←⊂'caseCode'
      r,←⊂'codeExtensions'
      r,←⊂'fastLoad'
      r,←⊂'flatten'
      r,←⊂'forceExtensions'
      r,←⊂'forceFilenames'
      r,←⊂'getFilename'
      r,←⊂'typeExtensions'
      r,←⊂'watch'
    ∇

    ∇ r←GetValidCiderParams
      r←⍬
      r,←⊂'source'
      r,←⊂'init'
      r,←⊂'parent'
      r,←⊂'projectSpace'
      r,←⊂'dependencies'
      r,←⊂'dependencies_dev'
      r,←⊂'distributionFolder'
      r,←⊂'project_url'
      r,←⊂'tests'
      r,←⊂'make'
    ∇

    ∇ options←ExtractLinkOptions config;C;overWrite
      options←L.U.DefaultOpts ⎕NS''
      C←config.LINK
      overWrite←{0=≢⍵:⍺ ⋄ ⍵}
      options.arrays(overWrite)←C.arrays
      options.beforeRead(overWrite)←C.beforeRead
      options.beforeWrite(overWrite)←C.beforeWrite
      options.caseCode(overWrite)←C.caseCode
      options.codeExtensions(overWrite)←C.codeExtensions
      options.fastLoad(overWrite)←C.fastLoad
      options.flatten(overWrite)←C.flatten
      options.forceExtensions(overWrite)←C.forceExtensions
      options.forceFilenames(overWrite)←C.forceFilenames
      options.getFilename(overWrite)←C.getFilename
      options.typeExtensions(overWrite)←↑C.typeExtensions
      options.watch←C.watch
      options.fastLoad←config.LINK.fastLoad
    ∇

    ∇ {config}←CheckParameters config;list;bool;list2
    ⍝ Check the parameters for being complete and valid
      :If 0=config.CIDER.⎕NC'githubUsername'
          config.CIDER.githubUsername←''
      :EndIf
      p'Checking parameters...'
      list←' '~⍨¨⊃,/↓¨config.(LINK CIDER).⎕NL 2 9
      list2←list~GetValidCiderParams
      bool←(list~GetValidCiderParams)∊GetValidLinkParams
      ('Invalid LINK parameter',((1<+/~bool)/'s'),': ',{0=≢⍵:'' ⋄ ⊃{⍺,',',⍵}/⍵}(~bool)/list2)Assert∧/bool
      bool←GetValidLinkParams∊list2
      ('Missing LINK parameter',((1<+/~bool)/'s'),': ',{0=≢⍵:'' ⋄ ⊃{⍺,',',⍵}/⍵}(~bool)/GetValidLinkParams)Assert∧/bool
      list2←list~GetValidLinkParams
      bool←(list~GetValidLinkParams)∊GetValidCiderParams
      ('Invalid Cider parameter',((1<+/~bool)/'s'),': ',{0=≢⍵:'' ⋄ ⊃{⍺,',',⍵}/⍵}(~bool)/list2)Assert∧/bool
      list←' '~⍨¨↓config.CIDER.⎕NL 2 9
      bool←GetValidCiderParams∊list
      ('Missing Cider parameter',((1<+/~bool)/'s'),': ',{0=≢⍵:'' ⋄ ⊃{⍺,',',⍵}/⍵}(~bool)/GetValidCiderParams)Assert∧/bool
      p'  All fine'
    ∇

    ∇ {r}←CheckForGit(path config);status;dmx;success
    ⍝ Checks whether the project is managed by Git, and if so offers some help
      r←⍬
      success←0
      :If ##.FilesAndDirs.Exists(AddSlash path),'.git'
          :If 9=⎕SE.⎕NC'APLGit2'
              :Trap 0
                  status←⎕SE.APLGit2.Status path
                  success←1
              :Else
                  dmx←⎕DMX
                  :If 127=dmx.EN
                      p'The project appears to be managed by Git but Git is not installed?!'
                  :ElseIf 0<≢dmx.Message
                      ⎕←'The Git status of the project could not be determined due to an error:'
                      ⎕←dmx.Message,'; rc=',⍕dmx.EN
                  :Else
                      ⎕←'The Git status of the project could not be determined due to an error'
                  :EndIf
              :EndTrap
              :If success
                  :If ∧/∨/¨'nothing to commit' 'working tree clean'⍷¨⊂∊status
                  :AndIf ~∨/∨/¨'on branch main' 'on branch master'⍷¨⊂⎕C∊status
                      ⎕←'Git: ',(1⊃status),', ',⊃{⍺,', ',⍵}/1↓status
                  :Else
                      status←(↓(,[0.5]'Git status report')⍪'='),status
                      {{}(#.⎕NS'').(⎕ED⍠('ReadOnly' 1)&{'GIT_Status_Report'}GIT_Status_Report←⍵)}⍪status
                  :EndIf
              :Else
                  p'The project appears to be managed by Git but the user command ]APLGit2 and'
                  p'it''s API are missing, therefore no information can be provided regarding Git'
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ {r}←configFilename HandleSysVars config;json;name;name_
    ⍝ For inheritance we specify the system vars early
      r←⍬
      :If 9=config.⎕NC'SYSVARS'     ⍝ Was introduced in version 0.4.0
          :For name :In ' '~⍨¨↓config.SYSVARS.⎕NL 2
              name_←1 ⎕C name
              :Trap 0
                  projectSpace_.⍎'⎕',name_,'←',⍕⍎'config.SYSVARS.',name
              :Else
                  1 p Frame'Assigning system variable "',name,'" failed'
              :EndTrap
          :EndFor
      :Else                         ⍝ SysVars prior to version 0.3.0
          projectSpace_.(⎕IO ⎕ML)←config.CIDER.(io ml)
          :If 1 YesOrNo'Convert old system vars definition to new one?'
              'SYSVARS'config.⎕NS''
              config.SYSVARS.(io ml)←config.CIDER.(io ml)
              config.CIDER.⎕EX¨'io' 'ml' 'wx'
              json←Put_JSON5 configFilename
          :EndIf
      :EndIf
    ∇

    ∇ {r}←CheckPackagesStatus(config parms pkgStatus);checkFlag;folder;folders;folder_;updateFlag;updateParms;report;buff;plural
    ⍝ Check whether Tatin packages should be updated in case parms.importFlag is not 1.
    ⍝ When pkgStatus is 2 it means that packages have just been re-installed, so no need to check for later versions.
    ⍝ This is ruled by parms.checkPackageVersions:
    ⍝ ⍬ means the user will be asked for both checking and updating
    ⍝ 0 means don't update
    ⍝ 1 means yes, check, but ask before updating
    ⍝ 2 means update without further ado
      r←⍬
      folders←GetTatinDepedencyFolders config
      :If 0<≢folders
          :If 0≢parms.checkPackageVersions
          :AndIf 2>pkgStatus
              :If (⊂parms.checkPackageVersions)∊⍬ 1
              :AndIf ~parms.quietFlag
                  checkFlag←0 YesOrNo' Report availability of later versions of installed Tatin packages?'
              :Else
                  checkFlag←2≡parms.checkPackageVersions
              :EndIf
          :Else
              checkFlag←0
          :EndIf
          :If checkFlag
              report←⍬
              1 ⎕SE._Tatin.Client.EstablishRumbaClients ⍬
              :If 0<≢report←report CheckTatinFoldersForLaterVersions parms folders
              :AndIf 0=+/⊃,/4⌷[2]¨report
                  p'   No later versions found '
                  :If 0<≢buff←(⊂'https://tatin.dev/')~⍨⊃,/3⌷[2]¨report
                      plural←1<≢buff
                      1 p Frame{'Note that ',(⍕≢⍵),' package',(plural/'s'),((1+plural)⊃' was' ' were'),' loaded from ',⊃{⍺,',',⍵}/∪⍵}buff
                  :EndIf
              :Else
                  report←{⍵[;4]⌿⍵}¨report
                  UpdatePackages folders report parms
              :EndIf
              ⎕SE._Tatin.Client.CloseConnections 1
          :EndIf
      :EndIf
    ∇

    ∇ report←report CheckTatinFoldersForLaterVersions(parms folders);folder;folder_;qdmx;msg
    ⍝ Loop through all Tatin install folders
      :For folder :In folders
          folder_←⊃'='(≠⊆⊢)folder
          :If ##.FilesAndDirs.Exists parms.folder,'/',folder_
              p'  Checking Tatin packages in <',(AddSlash folder_),'> ...'
              folder_←parms.folder,'/',folder_
              :If 0<≢⊃0 ⎕NINFO⍠('Wildcard' 1)⊣folder_,'/*'
                  :Trap 998
                      report,←⊂⎕SE.Tatin.CheckForLaterVersion folder_
                  :Else
                      qdmx←⎕DMX
                      :If qdmx.EM≡'The build list carries entries that are not on the Tatin Registry search path'
                          msg←''
                          msg,←⊂'ERROR: Checking for later versions of Tatin packages failed:'
                          msg,←⊂'       ',qdmx.EM
                          1 p Frame msg
                      :Else
                          qdmx.EM ⎕SIGNAL 998
                      :EndIf
                  :EndTrap
              :Else
                  p'     Folder is empty'
              :EndIf
          :EndIf
      :EndFor
    ∇

    ∇ {r}←UpdatePackages(folders reports parms);i;folder;updateFlag;report;updateParms
    ⍝ Update Tatin install folders by running ReInstallDependencies with the updateFlag set
    ⍝ Returns the number of install folders updated.
      r←0
      updateParms←⎕SE.Tatin.CreateReInstallParms
      updateParms.update←1
      updateParms.quiet←parms.quietFlag
      :For i :In ⍳≢reports
          report←i⊃reports
          :If 0<≢report
              folder←{⍵↑⍨¯1+⍵⍳'='}i⊃folders
              p'   Later versions in <',(AddSlash folder),'> :'
              p' ',' ',' ',⎕FMT↑{(1⊃⍵),' ==> ',(2⊃⍵)}¨↓report
              :If ~updateFlag←2≡parms.checkPackageVersions
                  updateFlag←1 YesOrNo'Re-install latest versions in <',(AddSlash folder),'> ?'
              :EndIf
              :If updateFlag
                  p'  Re-installing all packages in <',(AddSlash folder),'> ...'
                  updateParms ⎕SE.Tatin.ReInstallDependencies parms.folder,'/',folder
                  r+←1
              :EndIf
          :EndIf
      :EndFor
    ∇

    ∇ {r}←LoadTatinPackages(config folder projectSpace);pkgFolders;pkgFolder;folder2;target;pkgFolder_;noOf;p
    ⍝ Load all installed packages (if any) into their designated host namespaces.
      r←FAILURE
      p←{⍺←~parms.quietFlag ⋄ ⍺ PrintToSession ⍵}
      pkgFolders←GetTatinDepedencyFolders config
      :If 0<≢pkgFolders
          :For pkgFolder :In pkgFolders
              :If '='∊pkgFolder
                  (pkgFolder_ target)←SplitTatinFolders pkgFolder
                  'Target namespace for Tatin packages is addressed with absolute path (invalid)'Assert~(⊃target)∊'#⎕'
                  target←projectSpace,'.',target
              :Else
                  target←projectSpace
                  pkgFolder_←pkgFolder
              :EndIf
              p'Attempting to load Tatin packages from ',pkgFolder_,' into ',target,'...'
              folder2←folder,'/',pkgFolder_
              :If ##.FilesAndDirs.Exists folder2
                  :If 0<0<≢⊃0 ⎕NINFO⍠('Wildcard' 1)⊣folder2,'/*'
                      p ReportPackageOrigins folder2
                      noOf←≢⎕SE.Tatin.LoadDependencies folder2 target
                      p(⍕noOf),' Tatin package',((1<noOf)/'s'),' loaded'
                  :Else
                      p'Tatin installation folder "',folder2,'" is empty, therefore no packages loaded'
                  :EndIf
              :Else
                  p'Tatin installation folder "',folder2,'" does not exists, therefore no packages loaded'
              :EndIf
              r←SUCCESS
          :EndFor
      :EndIf
    ∇

    ∇ {r}←flag PrintToSession msg
      r←0 0⍴⍬
      :If flag
      :AndIf 0<≢msg
          ⎕←⍪⊆msg
      :EndIf
      :If 0<⎕NC'∆LOG'
          ∆LOG,←⊆msg
      :EndIf
    ∇

    ∇ {r}←ExecProjectInitFunction(config projectSpace);fns
    ⍝ Check whether a function "lx" is specified in the configuration and if so execute it.
      r←0
      :If 0<≢config.CIDER.init
          :If '⋄'∊config.CIDER.init
              (⊂projectSpace config)ExecProjectFunction_¨'⋄'(≠⊆⊢)config.CIDER.init
          :Else
              (projectSpace config)ExecProjectFunction_ config.CIDER.init
          :EndIf
      :EndIf
    ∇

    ∇ {r}←x ExecProjectFunction_ init;fns;config;projectSpace;qdmx
      r←⍬
      (projectSpace config)←x
      :If 3=projectSpace.⎕NC init
          p'Executing the project''s initialising function "',(init~' '),'"...'
          :Select 1 2⊃projectSpace.⎕AT init
          :Case 0
              :Trap 0
                  projectSpace.⍎init
              :Else
                  qdmx←⎕DMX
                  1 p Frame'Executing "init" crashed: ',qdmx.EM
              :EndTrap
          :CaseList 1 ¯2
              fns←projectSpace.⍎init
              :Trap 0
                  fns config
              :Else
                  qdmx←⎕DMX
                  1 p Frame'Executing "init" crashed: ',qdmx.EM
              :EndTrap
          :Else
              1 p Frame'Invalid function valence: is ambivalent'
          :EndSelect
      :Else
          1 p Frame'Could not execute "',init,'": function not found; check config file!'
      :EndIf
    ∇

    ∇ {r}←ExecUserFunction config;fn;qdmx;msg
    ⍝ Check whether the config parameter "ExecuteAfterProjectOpen" is defined in Cider's global config file
    ⍝ and execute it if it's a function.
      r←⍬
      msg←''
      :If 0<≢fn←GetFunctionNameFromCiderConfigFile ⍬
          :If 1=1 1⊃⎕AT fn
              :Trap 0
                  ⍎'{}',fn,' config'
              :Else
                  qdmx←⎕DMX
                  msg←'Executing "ExecuteAfterProjectOpen" crashed: ',qdmx.EM
              :EndTrap
          :Else
              :Trap 0
                  ⍎fn,' config'
              :Else
                  qdmx←⎕DMX
                  msg←'Executing "ExecuteAfterProjectOpen" crashed: ',qdmx.EM
              :EndTrap
          :EndIf
          :If 0=≢msg
              p'User function successfully executed'
          :Else
              1 p Frame msg
          :EndIf
      :EndIf
    ∇

    ∇ {r}←InjectConfigDataIntoProject(config projectSpace_ folder)
    ⍝ Create a namespace "CiderConfig" inside projectSpace and populate it with the configuration data.
    ⍝ Main purpose is to avoid any "Session namespace is referenced by #" problems.
      r←⍬
      'CiderConfig'projectSpace_.⎕NS config
      projectSpace_.CiderConfig.CIDER←projectSpace_.CiderConfig.⎕NS projectSpace_.CiderConfig.CIDER
      projectSpace_.CiderConfig.LINK←projectSpace_.CiderConfig.⎕NS projectSpace_.CiderConfig.LINK
      projectSpace_.CiderConfig.USER←projectSpace_.CiderConfig.⎕NS projectSpace_.CiderConfig.USER
      projectSpace_.CiderConfig.SYSVARS←projectSpace_.CiderConfig.⎕NS projectSpace_.CiderConfig.SYSVARS
      projectSpace_.CiderConfig.HOME←⊃,/1 ⎕NPARTS folder
    ∇

    ∇ {r}←{editFlag}ProjectConfig path;filename;ns;orig;flag;edit;data
    ⍝ By default the contents of the file cider.config in "path" is put into the editor in read-only mode.
    ⍝ The user may edit the contents if `⍺` is 1 rather than anything else or undefined.
    ⍝ Returns 1 in case the file was modified and 0 otherwise.
      :Access Public Shared
      r←0
      editFlag←{0=⎕NC ⍵:0 ⋄ ⍎⍵}'editFlag'
      :If '['∊path
          path←GetFolderFromAlias path
          ('Alias "',path,'" not found')Assert 0<≢path
      :EndIf
      :If 'cider.config'{⍺≡⎕C(-≢⍺)↑⍵}path
      :AndIf (¯1↑(-≢'cider.config')↓path)∊'/\'
          filename←path
      :Else
          filename←path,'/cider.config'
      :EndIf
      ('Does not exist: "',filename,'"')Assert ##.FilesAndDirs.Exists filename
      ns←⍎'edit'(⍎(1+'⎕'=⊃⊃⎕XSI)⊃'#' '⎕SE').⎕NS''
      MassageConfig filename
      orig←ns.cider_config←⊃##.FilesAndDirs.NGET filename 1
      :If ~CheckJsonSyntax ns.cider_config
      :OrIf ~0 PerformConfigChecks ⎕JSON⍠('Dialect' 'JSON5')('Compact' 0)⊣1↓∊(⎕UCS 10),¨⊆ns.cider_config
          orig←'' ⍝ This can happen in case the user edited the file with a externalm editor and introduced a mistake
      :EndIf
      flag←0
      :Repeat
          ns.⎕ED⍠('ReadOnly'(~(⊂,1)≡⊂,editFlag))⊣'cider_config'
          :If orig≢ns.cider_config
          :AndIf editFlag
          :AndIf 0<≢(∊ns.cider_config)~' '
              :If CheckJsonSyntax ns.cider_config
                  data←⎕JSON⍠('Dialect' 'JSON5')('Compact' 0)⊣1↓∊(⎕UCS 10),¨⊆ns.cider_config
              :AndIf PerformConfigChecks data
                  (⊂ns.cider_config)⎕NPUT⍠('NEOL' 2)⊣filename 1
                  r←flag←1
              :Else
                  :If ~1 YesOrNo'Syntax check failed. Try again? (no=changes are lost)'
                      flag←1
                  :EndIf
              :EndIf
          :Else
              flag←1
          :EndIf
      :Until flag
    ∇

    ∇ r←ListOpenProjects verboseFlag;res;aliases;ind
      :Access Public Shared
      '⍵ must be a Boolean'Assert(⊂verboseFlag)∊0 1
      r←(0(2+2×verboseFlag))⍴''
      res←⎕SE.Link.Status''
      :If 'No active links'≢res
          :If 0<≢res←(∧/'Namespace' 'Directory' 'Files'∊res[1;])↓res   ⍝ Will become superfluous with a proper Link API but don't do damage
              'Link demands a Resync!'Assert~∨/'Link.Resync required'⍷∊res
          :AndIf 0<≢res←({⊃9=⍵.⎕NC'CiderConfig'}∘⍎¨res[;1])⌿res
              r←res[;,1],({6::'' ⋄ ⍎⍵,'.CiderConfig.HOME'}¨res[;1])
              :If verboseFlag
                  r,←res[;3]
              :EndIf
              r←(0<≢¨r[;2])⌿r
              r[;2]←DropTrailingSlash¨r[;2]
              r[;2]←EnforceSlashInPath¨r[;2]
              :If verboseFlag
                  :If 0<≢aliases←GetAliasFileContent
                      aliases[;2]←DropTrailingSlash¨aliases[;2]
                  :AndIf 0<≢aliases←(aliases[;2]∊r[;2])⌿aliases
                      r,←⊂''
                      ind←r[;2]⍳aliases[;2]
                      r[ind;4]←aliases[;1]
                  :Else
                      r,←⊂''
                  :EndIf
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←HasDotNet;buff
    ⍝ Returns a 1 if either .NET Core or .NET is available and the bridge DLL was successfully loaded
      :Access Public Shared
      buff←2250⌶0
      r←(1 2∊⍨1⊃buff)∧2⊃buff
    ∇

    ∇ r←ListTatinPackages y;path;cfgFilename;cfg;buildFilenames;buildLists;b;tatinFolders
      :Access Public Shared
      :If '[]'≡y[1,≢y]
          path←GetFolderFromAlias2 y
      :Else
          path←y
      :EndIf
      cfgFilename←path,'/cider.config'
      'No Cider config file found'Assert ##.FilesAndDirs.Exists cfgFilename
      cfg←ReadProjectConfigFile cfgFilename
      tatinFolders←GetTatinDepedencyFolders cfg
      :If 0=≢tatinFolders
          r←'This Cider project has no Tatin packages'
      :Else
          tatinFolders←{⍵↑⍨¯1+⍵⍳'='}¨tatinFolders
          buildFilenames←((⊂path,'/'),¨tatinFolders),¨⊂'/apl-buildlist.json'
          :If 0∊b←##.FilesAndDirs.Exists¨buildFilenames
              ⎕←'Folder(s) do not exist: ',⊃,/(⊂(⎕UCS 13),' '),¨(~b)/buildFilenames
              buildFilenames←b/buildFilenames
          :EndIf
          'No directory noted on parameter "dependencies/dependencies_dev" found'Assert∨/b
          buildLists←{⎕JSON⍠('Dialect' 'JSON5')⊣⊃##.FilesAndDirs.NGET ⍵}¨buildFilenames
          r←⍉∘↑¨(⊂¨' ',¨¨buildLists.packageID),¨buildLists.(principal url)
          r←{⍵,'? '[1+'https://tatin.dev/'∘≡¨⍵[;3]]}¨r
          r←(⊂' Package-ID' 'Principal' 'URL' '')⍪¨(⊂'' '' '' '')⍪¨r
          (2⌷¨r)←(⊂' ' '' '' ''),¨¨({(¯1 0 0 0)+¨⊃¨((⌈⌿⍴¨,¨⍵))}¨r)⍴¨¨'-'
          r←{w←⍵ ⋄ w[2;4]←' ' ⋄ w}¨r
          r←⊃⍪/((⊂¨'*** '∘,¨(⊂path,'/'),¨tatinFolders),¨⊂'' '' '')⍪¨r
      :EndIf
    ∇

    ∇ r←GetMyUCMDsFolder
      :Access Public Shared
    ⍝ Returns standard path for Dyalog's MyUCMDs folder.
    ⍝ Works on all platforms but returns different results.\\
    ⍝ Under Windows typically:\\
    ⍝ `'C:\Users\{⎕AN}\Documents\MyUCMDs\'  ←→ GetMyUCMDsFolder`
      :If IsWindows
          r←(2 ⎕NQ'.' 'GetEnvironment' 'USERPROFILE'),'\Documents\MyUCMDs'
      :Else
          r←(2 ⎕NQ'.' 'GetEnvironment' 'Home'),'/MyUCMDs'
      :EndIf
    ∇

    ∇ r←GetAliasFileContent;filename;buff
      :Access Public Shared
      r←0 2⍴''
      filename←GetCiderAliasFilename
      :If ##.FilesAndDirs.Exists filename
      :AndIf 0<≢buff←⊃##.FilesAndDirs.NGET filename 1
      :AndIf 0<≢buff←(0<≢¨buff)/buff
          r←↑{'='(≠⊆⊢)⍵}¨buff
          r[;1]←⎕C¨r[;1]
          r[;2]←EnforceSlashInPath¨r[;2]
          r[;2]←{⍵↓⍨¯1×(¯1↑⍵)∊'/\'}¨r[;2]
          r←r[⍋r[;1];]
      :EndIf
    ∇

    ∇ r←{list}CloseProject projects;list;project;ind;res
    ⍝ Simply breaks the Link between a project and its folder on disk.
    ⍝ In case ⍵ is empty ALL projects are closed.
    ⍝ `projects` may be one of:
    ⍝ 1. Empty vector (=close all)
    ⍝ 2. One or more projectName like `#.Foo`
    ⍝ 3. One or more alias names like `[my-alias]`
    ⍝ 4. One or more paths of currently open projects
    ⍝ 5. A mixture of 2, 3 and 4
    ⍝ Returns the number of projects closed.
      :Access Public Shared
      r←0
      list←{0=⎕NC ⍵:ListOpenProjects 1 ⋄ ⍎⍵}'list'
      :If 0<≢list
          :If 0=≢projects
              res←{⎕SE.Link.Break ⍵}¨list
              r←+/{'Unlinked: '{⍺≡(≢⍺)↑⍵}⍵}¨res[;1]
          :Else
              list[;2]←##.FilesAndDirs.NormalizePath list[;2]
              projects←⊆projects
              :For project :In projects
                  :If ∧/'[]'∊project
                      ind←list[;4]⍳⊂⎕C project~'[]'
                  :Else
                      ind←(⎕C list[;1])⍳⊂⎕C project
                  :EndIf
                  :If ind>≢list
                      ind←list[;2]⍳⊂##.FilesAndDirs.NormalizePath project
                  :EndIf
                  :If (≢list)≥ind
                      res←⎕SE.Link.Break 1⊃list[ind;]
                      r+←'Unlinked: '{⍺≡(≢⍺)↑⍵}res
                  :EndIf
              :EndFor
          :EndIf
      :EndIf
    ∇

    ∇ r←ReadProjectConfigFile path;path2
    ⍝ Reads a project config file and returns it as a namespace with variables.
    ⍝ `path` may or may not carry the filename as such.
      :Access Public Shared
      path2←'cider.config'{⍺≡(-≢⍺)↑⍵:⍵ ⋄ ({⍵,'/'/⍨~(¯1↑⍵)∊'/\'}⍵),⍺}path
      r←Get_JSON5 path2
    ∇

    ∇ r←config WriteProjectConfigFile path;path2
    ⍝ Writes project configuration "config" to file.\\
    ⍝ `path` may or may not carry the filename as such.
      :Access Public Shared
      path2←'cider.config'{⍺≡(-≢⍺)↑⍵:⍵ ⋄ ({⍵,'/'/⍨~(¯1↑⍵)∊'/\'}⍵),⍺}path
      r←config Put_JSON5 path2
    ∇

    YesOrNo←{⍺←⊢ ⋄ ⍺ ##.CommTools.YesOrNo ⍵}

    ∇ {r}←AddAlias(folder alias);ciderAliasFilename;data;q;path;folder_;row;path_;ind;msg
    ⍝ Takes a folder and an alias.
    ⍝ If the folder does not exist `msg` carries a corresponding message.
    ⍝ * If the alias is already associated with the folder no action is taken
    ⍝ * If the alias is already defined with a different folder the user is asked to confirm overwriting it
    ⍝ * If the alias is undefined yet it as added
    ⍝ * You cannot delete an alias with this function.
      :Access Public Shared
      r←⍬
      ciderAliasFilename←GetCiderAliasFilename
      msg←''
      alias←⎕C alias~'[]'
      :If 0≠≢alias
      :AndIf 0<≢ciderAliasFilename
          :If ##.FilesAndDirs.Exists ciderAliasFilename
              data←⊃##.FilesAndDirs.NGET ciderAliasFilename 1
              :If ~##.FilesAndDirs.Exists folder
                  1 p Frame'Could not find "',folder,'"'
              :ElseIf 0=+/(alias,'=')∘{⍺≡(≢⍺)↑⍵}¨data
                  ind←({⍵↓⍨⍵⍳'='}¨data)⍳⊂folder
                  :If ind≤≢data
                      DropAlias{⍵↑⍨¯1+⍵⍳'='}ind⊃data
                      data←⊃##.FilesAndDirs.NGET ciderAliasFilename 1
                  :EndIf
                  (⊂data,⊂(⎕C alias),'=',folder)##.FilesAndDirs.NPUT ciderAliasFilename 1
              :Else
                  data←↑{'='(≠⊆⊢)⍵}¨data
                  :If (⊂alias)∊data[;1]
                      row←data[;1]⍳⊂alias
                      path←2⊃data[row;]
                      (path folder)←EnforceSlashInPath¨path folder
                      :If IsWindows
                          (path_ folder_)←⎕C¨path folder
                      :Else
                          (path_ folder_)←path folder
                      :EndIf
                      (path_ folder_)←{⍵↓⍨-'/'=¯1↑⍵}¨path_ folder_
                      :If ≢/path_ folder_
                          q←'Alias [',alias,'] is already defined for:',CR,('   ',path),CR,'Overwrite?'
                          :If YesOrNo q
                              data[row;2]←⊂folder
                              data←⊃¨{⍺,'=',⍵}/¨↓data
                              (⊂data)##.FilesAndDirs.NPUT ciderAliasFilename 1
                          :Else
                              1 p Frame'Alias "',alias,'" is already in use with a different path - alias not assigned'
                          :EndIf
                      :EndIf
                  :EndIf
              :EndIf
          :Else
              (⊂(⎕C alias),'=',folder)##.FilesAndDirs.NPUT ciderAliasFilename
          :EndIf
      :EndIf
    ∇

    ∇ {successFlag}←DropAlias alias;ciderAliasFilename;data;noOf
      :Access Public Shared
      ciderAliasFilename←GetCiderAliasFilename
      successFlag←FAILURE
      :If 0≠≢alias
      :AndIf 0<≢ciderAliasFilename
          :If ##.FilesAndDirs.Exists ciderAliasFilename
              noOf←≢data←⊃##.FilesAndDirs.NGET ciderAliasFilename 1
              data←((⊆⎕C alias),¨'='){⍵/⍨~((⍵↑⍨¨⍵⍳¨'='))∊⍺}data
              :If noOf>≢data
                  (⊂data)##.FilesAndDirs.NPUT ciderAliasFilename 1
                  successFlag←SUCCESS
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ filename←GetCiderAliasFilename;folder
      :Access Public Shared
      filename←''
      folder←GetCiderGlobalConfigHomeFolder
      filename←folder,'aliase.txt'
    ∇

    ∇ r←RunTests path;configFilename;config
      :Access Public Shared
      r←''
      :If '[]'≡path[1,≢path]
          path←GetFolderFromAlias path
      :EndIf
      configFilename←path,'/cider.config'
      ('No file "cider.config" found in ',path)Assert ##.FilesAndDirs.Exists configFilename
      config←Get_JSON5 configFilename
      :If 0<config.CIDER.⎕NC'tests'
      :AndIf 0<≢config.CIDER.tests
          :If (1⍴config.CIDER.tests~' ')∊'])'
              r←config.CIDER.tests,' ⍝ Execute this for running the test suite'
          :ElseIf (⊃config.CIDER.tests)∊'#⎕' ⍝ Was possible until 0.28.1
              r←config.CIDER.tests,' ⍝ Execute this for running the test suite'
          :Else
              r←(config.CIDER.parent),({0=≢⍵:⍵ ⋄ '.',⍵},config.CIDER.projectSpace),'.',config.CIDER.tests,' ⍝ Execute this for running the test suite'
          :EndIf
      :EndIf
    ∇

    ∇ r←RunMake path;configFilename;config;p
      :Access Public Shared
      r←''
      p←{⍺←~parms.quietFlag ⋄ ⍺ PrintToSession ⍵}
      :If '[]'≡path[1,≢path]
          path←GetFolderFromAlias path
      :EndIf
      configFilename←path,'/cider.config'
      ('No file "cider.config" found in ',path)Assert ##.FilesAndDirs.Exists configFilename
      config←Get_JSON5 configFilename
      :If 0<config.CIDER.⎕NC'make'
      :AndIf 0<≢config.CIDER.make
          :If (1⍴config.CIDER.make~' ')∊'])'
              r←config.CIDER.make,' ⍝ Execute this for creating a new version'
          :ElseIf (⊃config.CIDER.make)∊'#⎕'   ⍝ Was possible until 0.28.1
              r←config.CIDER.make,' ⍝ Execute this for creating a new version'
          :Else
              r←(config.CIDER.parent),({0=≢⍵:⍵ ⋄ '.',⍵},config.CIDER.projectSpace),'.',config.CIDER.make,' ⍝ Execute this for creating a new version'
          :EndIf
      :Else
          1 p Frame'No expression found for creating a new version of <',config.CIDER.projectSpace,'>'
      :EndIf
    ∇

    ∇ filename←GetCiderGlobalConfigFilename;folder
    ⍝ Returns the name of the Cider config file.
    ⍝ As a side effect it creates the file with defaults if it does not yet exist.
      :Access Public Shared
      folder←GetCiderGlobalConfigHomeFolder
      filename←folder,'config.json'
    ∇

    ∇ folder←GetCiderGlobalConfigHomeFolder;name;flag;oldFolder;res
    ⍝ Return the full path to (and including) .cider in the user's home directory
    ⍝ Has a side effect: creates the hosting folder in case it does not yet exist
      :Access Public Shared
      name←(1+'win'≡⎕C 3↑1⊃'.'⎕WG'aplversion')⊃'HOME' 'USERPROFILE'
      folder←(2 ⎕NQ #'GetEnvironment'name),'/.cider/'
      1 ⎕MKDIR folder
      ⍝ The remaining code checks whether there is a .cider folder in a different location
      ⍝ and if so copies the content over.
      ⍝ This is a temporary measure since the parent for the .cider folder was changed on
      ⍝ Windows from APPDATA\ to the user's home directory.
      ⍝ Nothing changed on other platform
      :If 'Win'≡3↑##.APLTreeUtils2.GetOperatingSystem ⍬
      :AndIf ~⎕NEXISTS folder,'config.json'
          oldFolder←(2 ⎕NQ #'GetEnvironment' 'APPDATA'),'/.cider/'
          res←folder∘{⍺(⎕NMOVE⍠('IfExists' 'Skip')##.FilesAndDirs.ExecNfunction)⍵}¨##.FilesAndDirs.ListFiles oldFolder
          ##.FilesAndDirs.RmDir oldFolder
      :EndIf
    ∇

    ∇ r←GetCiderGlobalConfigFileContent;filename;json
    ⍝ Returns a namespace with all settings (if any) in the (optional) global Cider config file.
    ⍝ Note that the file might not exist or be empty, in which case `⍬` is returned.
      :Access Public Shared
      r←⍬
      filename←GetCiderGlobalConfigFilename
      :If ##.FilesAndDirs.IsFile filename
          json←##.FilesAndDirs.NGET filename
      :AndIf 0<≢json
          r←⎕JSON⍠('Dialect' 'JSON5')⊣⊃json
      :EndIf
    ∇

    ∇ parms←(fns GetFolderFromAlias)parms;data;alias;msg;alias_;folder
    ⍝ Translates the alias in "folder" (if any) into a path from a parameter namespace.\\
    ⍝ If an alias is defined it is saved, possibly by overwriting the old one.
      :If '[]'≡parms.folder[1,≢parms.folder]
          alias←parms.folder~'[]'
          folder←GetFolderFromAlias2 alias
          :If 0<≢folder
              parms.folder←folder
              :If 0=≢parms.alias
                  parms.alias←alias
              :EndIf
          :Else
              (alias,'" is not a valid alias')⎕SIGNAL 11
          :EndIf
      :EndIf
    ∇

    ∇ folder←GetFolderFromAlias2 alias;filename;data
    ⍝ Translates the alias in "folder" (if any) into a path.\\
    ⍝ In case the alias does not exist an empty vector is returned.\\
    ⍝ If an alias is defined it is saved, possibly by overwriting the old one.
      folder←''
      filename←GetCiderAliasFilename
      :If ##.FilesAndDirs.Exists filename
          :If 0<≢data←⊃##.FilesAndDirs.NGET filename 1
              data←↑{'='(≠⊆⊢)⍵}¨data
              alias←⎕C alias~'[]'
              :If (⊂alias)∊data[;1]
                  folder←2⊃data[data[;1]⍳⊂alias;]
              :Else
                  ('"',alias,'" is not a valid alias')Assert(⎕NS'').{0=⎕NC ⍵}⎕C alias~'[]'
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ txt←DropTrailingSlash txt
      txt↓⍨←-'/\'∊⍨¯1↑txt
    ∇

    ∇ config←Get_JSON5 filename;config;flag;qdmx;json
      :If 0<≢json←⊃##.FilesAndDirs.NGET filename
          :Trap 11
              config←⎕JSON⍠('Dialect' 'JSON5')⊣json
          :Else
              qdmx←⎕DMX
              11 ⎕SIGNAL⍨'JSON import of <',filename,'> failed',{0=≢⍵:⍵ ⋄ ':'∊⍵:(¯1+⍵⍳':')↓⍵ ⋄ ': ',⍵}qdmx.Message
          :EndTrap
      :EndIf
      :If 0<config.⎕NC'CIDER'
          flag←0
          :If 0<config.CIDER.⎕NC'lx'  ⍝ Renamed from `lx` to `init` in 2022-07
              config.CIDER.init←config.CIDER.lx
              config.CIDER.⎕EX'lx'
              flag←1
          :EndIf
          :If 0=config.CIDER.⎕NC'tests'
              config.CIDER.tests←''
              flag←1
          :EndIf
          :If 0=config.CIDER.⎕NC'make'
              config.CIDER.make←''
              flag←1
          :EndIf
          :If flag
              (⊂config)Put_JSON5 filename
          :EndIf
      :EndIf
    ∇

    ∇ {r}←config Put_JSON5 filename;json
      r←0
      json←⎕JSON⍠('Dialect' 'JSON5')('Compact' 0)⊣config
      (⊂json)⎕NPUT⍠('NEOL' 2)⊣filename 1
    ∇

    BitsToInt←{(32⍴2)⊥⌽32↑⍵}

    IntToBits←{⌽(32⍴2)⊤⍵}

    ∇ functionName←GetFunctionNameFromCiderConfigFile dummy;globalUserConfig
      functionName←''
      :If ⍬≢globalUserConfig←GetCiderGlobalConfigFileContent
      :AndIf 2=globalUserConfig.⎕NC'ExecuteAfterProjectOpen'
      :AndIf 0<≢functionName←globalUserConfig.ExecuteAfterProjectOpen
          :If 3=⎕NC functionName
              :If 1≠1 2⊃⎕AT functionName
                  p'   "ExecuteAfterProjectOpen" is not a monadic function, therefore not executed'
                  functionName←''
              :EndIf
          :Else
              p'   "ExecuteAfterProjectOpen" is not a function, therefore not executed'
              functionName←''
          :EndIf
      :EndIf
    ∇

    ∇ flag←CheckJsonSyntax json
      :Trap 0
          {}⎕JSON⍠('Dialect' 'JSON5')('Compact' 0)⊣1↓∊(⎕UCS 10),¨⊆json
          flag←1
      :Else
          flag←0
      :EndTrap
    ∇

    ∇ path←AddSlash path
      path,←(~(¯1↑path)∊'/\')/'/'
    ∇

    ∇ r←IsWindows
      r←'Win'≡3↑⊃'.'⎕WG'APLVersion'
    ∇

    ∇ path←EnforceSlashInPath path;b
      :If 0<+/b←'\'=path
          (b/path)←'/'
      :EndIf
    ∇

    ∇ flag←CheckForAlreadyOpened projectSpace;activeLinks
    ⍝ Returns a 1 in case projectSpace is already LINKed, otherwise 0
      flag←0
      :If 2=⍴⍴activeLinks←⎕SE.Link.Status''
      :AndIf 0<≢activeLinks                                          ⍝ Maybe one day when Link has a real API...
          flag←(⊂⍕projectSpace)∊activeLinks[;1]
      :EndIf
    ∇

    ∇ successFlag←{reportFlag}PerformConfigChecks config;namespace;path;tatinFolders;tatinFolder;i;this;report
      reportFlag←{0<⎕NC ⍵:⍎⍵ ⋄ 1}'reportFlag'
      successFlag←⍬
      report←''
      tatinFolders←('dependencies' 'dependencies_dev'GetDependencies¨⊂config)~⊂''
      :For i :In ⍳≢tatinFolders
          tatinFolder←i⊃tatinFolders
          this←i⊃'dependencies' 'dependencies_dev'
          :If '='∊tatinFolder
              :If 1<'='+.=tatinFolder
                  successFlag,←SUCCESS
              :Else
                  (path namespace)←'='(≠⊆⊢)tatinFolder
                  successFlag,←(1+0=(⎕NS'').{⎕NC ⍵}namespace)⊃FAILURE SUCCESS
                  :If 0=¯1↑successFlag
                      report,←⊂Frame'Something is wrong with "',this,'"'
                  :EndIf
              :EndIf
          :ElseIf ~','∊tatinFolder
              successFlag,←SUCCESS
          :Else
              ⍝ More than one is invalid
              report,←⊂Frame'Something is wrong with "',this,'"'
          :EndIf
      :EndFor
      :If (⊃config.CIDER.make)∊'#⎕'
          successFlag,←FAILURE
          report,←⊂Frame'"make" is defined with an absolute path; must be relative to the project'
      :ElseIf 0<≢config.CIDER.make
      :AndIf 3≠⎕NC{⍵↑⍨¯1+⌊/⍵⍳' ⍝'}config.CIDER.parent,'.',config.CIDER.projectSpace,'.',config.CIDER.make
          successFlag,←FAILURE
          report,←⊂Frame config.CIDER.parent,'.',config.CIDER.make,' not found (check "make")'
      :EndIf
      :If (⊃config.CIDER.tests)∊'#⎕'
          successFlag,←FAILURE
          report,←⊂Frame'"tests" is defined with an absolute path; must be relative to the project (check "make")'
      :ElseIf 0<≢config.CIDER.tests
      :AndIf 3≠⎕NC{⍵↑⍨¯1+⌊/⍵⍳' ⍝'}config.CIDER.parent,'.',config.CIDER.projectSpace,'.',config.CIDER.tests
          successFlag,←FAILURE
          report,←⊂Frame config.CIDER.parent,'.',config.CIDER.make,' not function (check "tests")'
      :EndIf
      successFlag←∧/successFlag
      :If reportFlag
      :AndIf 0<≢report
          ⎕←⍪report
      :EndIf
    ∇

    ∇ {changeFlag}←MassageConfig filename;config
    ⍝ Checks whether the config data comes with all expected antries.
    ⍝ If anything is missing (late arrivals) those are added.
    ⍝ Returns a 1 in case data was added, otherwise 0.
      changeFlag←0
      config←Get_JSON5 filename
      :If 0=config.CIDER.⎕NC'tests'
          config.CIDER.tests←''
          changeFlag∨←1
      :EndIf
     
      :If 0=config.CIDER.⎕NC'make'
          config.CIDER.make←''
          changeFlag∨←1
      :EndIf
      :If changeFlag
          config Put_JSON5 filename
      :EndIf
    ∇

    ∇ ref←CheckTargetNamespaceAndLinkFolder(ref parms source);nsIsEmpty;folderIsEmpty
    ⍝ 1. In case `ref` does not point to a namespace or a script but the name is already taken
    ⍝ 2. In case the namespace `ref` and the folder are both empty no action is taken
    ⍝ 3. In case only the namespace `ref` is empty no action is taken
    ⍝ 4. In case only the folder is empty no action is taken
    ⍝ 5. In case neither the namespace `ref` nor the folder are empty the user is asked
    ⍝    whether she wants the namespace to be recreated; if not an error is thrown.
    ⍝ When `quietFlag` is set however then either the namepace or the folder or both must
    ⍝ be empty, otherwise an error is thrown.
      :If (⎕NC⊂⍕ref)∊9.1 9.4 9.5
          nsIsEmpty←0=≢' '~¨⍨↓ref.⎕NL⍳16
          :If 0=##.FilesAndDirs.Exists parms.folder,'/',source
              folderIsEmpty←1
          :Else
              folderIsEmpty←0=≢⊃⎕NINFO⍠('Wildcard' 1)⊣parms.folder,'/',source,'/*'
          :EndIf
          :If nsIsEmpty∧~folderIsEmpty
          :OrIf folderIsEmpty∧~nsIsEmpty
          :OrIf folderIsEmpty∧nsIsEmpty
              :Return
          :EndIf
          :If parms.quietFlag
          ⍝ With quietFlag being true there is nothing we can do but throw an error
              'Both the target and the source folder are not empty'Assert 0
          :Else
              :If YesOrNo'Target "',(⍕ref),'" is not empty - recreate?'
                  ⎕EX⍕ref                                 ⍝ It might be a class, so we first delete it...
                  ref←⍎(⍕ref)({⍎⍵↑⍨¯1+⍵⍳'.'}⍕ref).⎕NS''   ⍝ ... and then we re-create it
              :Else
                  'Both the target and the source folder are not empty'Assert 0
              :EndIf
          :EndIf
      :Else
          ('The name "',(⍕ref),'" is already in use')Assert 0
      :EndIf
    ∇

    ∇ msg←ReportPackageOrigins folder;data
    ⍝ Report where the package got installed from
      msg←''
      data←Get_JSON5 folder,'/apl-buildlist.json'
      msg←⊂'Packages were originally installed from:'
      msg,←'   '∘,¨∪data.url
    ∇

    Select←{⍺←⊢ ⋄ ⍺ ##.CommTools.Select ⍵ }

    ∇ r←ListDirs path;buff
      buff←(0 1)⎕NINFO⍠('Wildcard' 1)⊣path,'*'
      r←(1=2⊃buff)/1⊃buff
    ∇

    ∇ r←SplitTatinFolders pkgFolder;buff;msg
      msg←'Something is wrong with the "dependencies" or "dependencies_dev" setting in Cider.config'
      :Trap 0
          r←'='(≠⊆⊢)pkgFolder
      :Else
          msg Assert 0
      :EndTrap
      msg Assert 2=≢r
    ∇

      Box←{⍺←⊢
          r←⎕FMT↑⍵
          b←r∊⍺⊣'⌹'
          m←⍉4⊥⍉2⊥↑↑(3,/0,b,0)(3,⌿0⍪b⍪0)
          c←'│  ─  ┌  │  │  └  ├  ─  ┐  ─  ┬  ┘  ┤  ┴  ┼ .'~' '
          n←13 14 15 28 29 30 31 44 45 46 47 60 61 62 63
          (⍴r)⍴(m∊n)⊖(2,⍴r)⍴r⍪(⊂n⍳m)⌷c
⍝ box frame
⍝ [⍺] char(s) to be replaced - dflt '⌹'
⍝  ⍵  char array
⍝  ←  array with ⍺ replaced by boxing chars
⍝ ┌───┬───┬───┬───┬───┬───┬───┬───┐  ┌───┬───┬───┬───┬───┬───┬───┬───┐
⍝ │   │ ∘ │   │ ∘ │   │ ∘ │   │ ∘ │  │   │ │ │   │ │ │   │ │ │   │ │ │
⍝ │ ∘ │ ∘ │ ∘∘│ ∘∘│ ∘ │ ∘ │ ∘∘│ ∘∘│  │ ∘ │ │ │ ──│ └─│ │ │ │ │ ┌─│ ├─│
⍝ │   │   │   │   │ ∘ │ ∘ │ ∘ │ ∘ │  │   │   │   │   │ │ │ │ │ │ │ │ │
⍝ ├───┼───┼───┼───┼───┼───┼───┼───┤  ├───┼───┼───┼───┼───┼───┼───┼───┤
⍝ │   │ ∘ │   │ ∘ │   │ ∘ │   │ ∘ │  │   │ │ │   │ │ │   │ │ │   │ │ │
⍝ │∘∘ │∘∘ │∘∘∘│∘∘∘│∘∘ │∘∘ │∘∘∘│∘∘∘│  │── │─┘ │───│─┴─│─┐ │─┤ │─┬─│─┼─│
⍝ │   │   │   │   │ ∘ │ ∘ │ ∘ │ ∘ │  │   │   │   │   │ │ │ │ │ │ │ │ │
⍝ └───┴───┴───┴───┴───┴───┴───┴───┘  └───┴───┴───┴───┴───┴───┴───┴───┘
⍝ Phil Last 2016-02-12
      }

    ∇ r←Frame y
    ⍝ Surrounds y by a frame.
    ⍝ `y` can be one of:
    ⍝ * Simple char vector
    ⍝ * Simple char matrix
    ⍝ * Nested vector of simple char vectors
    ⍝ `←` is always a simple matrix
      :If 1<|≡y
          y←↑y
      :EndIf
      :If 2≠⍴⍴y
          y←,[0.5]y
      :EndIf
      r←'⌹',('⌹'⍪y⍪'⌹'),'⌹'
      r←Box r
    ∇

:EndClass
