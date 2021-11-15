:Class Cider_uc
⍝ User Command class for the project manager "Cider"
⍝ Kai Jaeger ⋄ APL Team Ltd

    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3
    MinimumVersionOfDyalog←'18.0'
    L←⎕SE.Link
    configFilename←'cider.config'

    ∇ r←List;c ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
      r←⍬
      :If AtLeastVersion⊃(//)⎕VFI MinimumVersionOfDyalog
          c←⎕NS''
     
          c.Name←'OpenProject'
          c.Desc←'Load all source files into the WS and keep it linked by default'
          c.Group←'Cider'
          c.Parse←'1s -target= -parent= -alias= -suppressLX -quiet -import -noPkgLoad'
          r,←c
     
          c←⎕NS''
          c.Name←'ListOpenProjects'
          c.Desc←'List all currently open projects'
          c.Group←'Cider'
          c.Parse←'-verbose'
          r,←c
     
          c←⎕NS''
          c.Name←'ListAliases'
          c.Desc←'List all defined aliases with their folders'
          c.Group←'Cider'
          c.Parse←'-prune -edit -quiet'
          r,←c
     
          c←⎕NS''
          c.Name←'CreateProject'
          c.Desc←'Makes the given folder a project folder'
          c.Group←'Cider'
          c.Parse←'2s -alias= -acceptConfig -noEdit'
          r,←c
     
          c←⎕NS''
          c.Name←'CloseProject'
          c.Desc←'Breaks the Link between the workspace and the files on disk'
          c.Group←'Cider'
          c.Parse←'1s -all'
          r,←c
     
          c←⎕NS''
          c.Name←'Help'
          c.Desc←'Offers to put the HTML files on display'
          c.Group←'Cider'
          c.Parse←''
          r,←c
     
          c←⎕NS''
          c.Name←'Version'
          c.Desc←'Returns name, version number and version date as a three-element vector'
          c.Group←'Cider'
          c.Parse←''
          r,←c
      :EndIf
    ∇

    ∇ r←Run(Cmd Args);folder;res;P;path;aplVersion;parent;flags;ns;msg
      :Access Shared Public
      r←0 0⍴''
      ('Cider needs at least version ',MinimumVersionOfDyalog,' of Dyalog APL')Assert AtLeastVersion⊃(//)⎕VFI MinimumVersionOfDyalog
      P←LoadCiderCode ⍬
      :If 18={⊃(//)⎕VFI ⍵↑⍨¯1+⍵⍳'.'}aplVersion←2⊃'.'⎕WG'aplversion'
      :AndIf 44280>⊃(//)⎕VFI 3⊃'.'(≠⊆⊢)aplVersion  ⍝ 44280 has essential ⎕FIX fix for Link to work
          'Version 18 must be at least on build number 44280, otherwise Link won''t work as expected'⎕SIGNAL 11
      :EndIf
      :Select ⎕C Cmd
      :Case ⎕C'OpenProject'
          Args.target←{(,0)≡,⍵:'' ⋄ ⍵}Args.target
          :If 0≡Args._1
              path←⊃1 ⎕NPARTS''
              :If ⎕NEXISTS path,'cider.config'
                  :If ~1 YesOrNo'Sure that you want to open ',path,'?'
                      :Return
                  :EndIf
              :ElseIf 0=≢path←OpenFileDialogBox'Open cider.config'
                  :Return
              :EndIf
          :Else
              path←Args._1
          :EndIf
          :If (⊂,path)∊,¨'[' '[?' '[?]'
              :If 0=≢path←SelectFromAliases ⍬
                  :Return
              :EndIf
          :EndIf
          path←⎕C⍣('['∊path)⊣path
          Args.parent←{(,0)≡,⍵:'#' ⋄ ⍵}Args.parent
          Args.alias←⎕C''Args.Switch'alias'
          flags←BitsToInt Args.(quiet suppressLX import noPkgLoad)
          {}P.OpenProject(⊂path),Args.(target parent alias),flags
      :Case ⎕C'ListOpenProjects'
          r←P.ListOpenProjects Args.verbose
          :If Args.verbose
              r(AddTitles)←'Namespace name' 'Path' 'No. of objects' 'Alias'
          :EndIf
      :Case ⎕C'ListAliases'
          :If Args.edit
              EditAliasFile ⍬
              r←ProcessAliases 0 0 0
          :Else
              r←ProcessAliases Args.(prune edit quiet)
          :EndIf
      :Case ⎕C'CreateProject'
          :If 0=≢Args._1
              folder←''
          :Else
              folder←Args._1
          :EndIf
          :If 0=≢Args._2
          :OrIf 0≡Args._2
              r←CreateProject folder(Args.acceptConfig)(Args.noEdit)
          :Else
              r←Args._2 CreateProject folder(Args.acceptConfig)(Args.noEdit)
          :EndIf
          :If 0≢Args.alias
              :If 0<≢msg←P.AddAlias folder Args.alias
                  r,←(⎕UCS 13)msg
              :EndIf
          :EndIf
      :Case ⎕C'CloseProject'
          r←CloseProject Args.(_1 all)
      :Case ⎕C'Version'
          r←P.Version ⍬
      :Case ⎕C'Help'
          r←ShowHelp ⍬
      :Else
          ∘∘∘ ⍝ Huh?!
      :EndSelect
    ∇

    ∇ r←level Help Cmd;ref
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          :Select ⎕C Cmd
          :Case ⎕C'OpenProject'
              r,←⊂'Load all source files into the WS and keep it linked by default'
              r,←⊂']Cider.OpenProject [folder] [-target=] [-parent=] [-alias=] [-suppressLX] [-quiet] [-import] [-noPkgLoad]'
          :Case ⎕C'ListOpenProjects'
              r,←⊂'List all currently open projects'
              r,←⊂']Cider.ListOpenProjects [-verbose]'
          :Case ⎕C'ListAliases'
              r,←⊂'List all defined aliases with their folders'
              r,←⊂']Cider.ListAliases [-prune] [-edit] [-quiet]'
          :Case ⎕C'CreateProject'
              r,←⊂'Makes the given folder a project folder'
              r,←⊂']Cider.CreateProject <folder> [<project-namespace>] [-alias=] [-acceptConfig] [-noEdit]'
          :Case ⎕C'CloseProject'
              r,←⊂'Breaks the Link between the project space and the files on disk'
              r,←⊂']Cider.CloseProject [<project-namespace>] [-all]'
          :Case ⎕C'Help'
              r,←⊂'Offers to put the HTML files on display'
              r,←⊂']Cider.Help'
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
              r,←⊂'Takes a path to a folder that must contain a file "',configFilename,'" (JSON5).'
              r,←⊂''
              r,←⊂'The config file must specify all variables required by Cider, including "source".'
              r,←⊂'The contents of "source" is then linked to "ProjectSpace" by default.'
              r,←⊂''
              r,←⊂'If no folder is specified Cider looks for a file "',configFilename,'" in the'
              r,←⊂'current directory. If no such file is found then...'
              r,←⊂' * under Windows a dialog box is opened that allows you to navigate to the right folder'
              r,←⊂' * an error is thrown on non-Windows platforms'
              r,←⊂''
              r,←⊂'-quiet:     The user command prints messages to the session unless -quiet is specified.'
              r,←⊂'-parent:    The project is loaded into Cider.(parent.projectSpace) unless this is (usually'
              r,←⊂'            temporarily) overwritten by setting the -target= and/or the -parent= options.'
              r,←⊂'-import:    By default the files on disk are Linked to a namespace. By specifying the -import'
              r,←⊂'            flag this can be avoided: the code is then loaded into the workspace with the'
              r,←⊂'            Link.Import method.'
              r,←⊂'-alias:     In case you are going to work on a project frequently you may specify'
              r,←⊂'            -alias=name'
              r,←⊂'-noPkgLoad: By default the Tatin packages from the installation folder(s) defined in the'
              r,←⊂'            config will be loaded. If you don''t want this specify -noPkgLoad'
              r,←⊂''
              r,←⊂'Later on you may open the project with:'
              r,←⊂']Cider.OpenProject [name]'
              r,←⊂'You can also ask Cider for a list of all known aliases with:'
              r,←⊂']Cider.OpenProject [?]'
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
          :Case ⎕C'CreateProject'
              r,←⊂'Requires a path to a folder ("source") that is about to become a project.'
              r,←⊂''
              r,←⊂'One might also specify a namespace. Then the namespace is Linked to "source",'
              r,←⊂'and a namespace CiderConfig is injected into the namespace, holding configuration data.'
              r,←⊂''
              r,←⊂' * Creates a file "',configFilename,'" in that folder'
              r,←⊂' * Lets the user edit that file and makes sure that all mandatory settings are done and'
              r,←⊂'   also that those are correct'
              r,←⊂' * In case an alias is specified the alias is saved'
              r,←⊂''
              r,←⊂'If no path is specified it acts on the current directory, but in that case the user'
              r,←⊂'is prompted for confirmation to avoid mishaps.'
              r,←⊂''
              r,←⊂'-acceptConfig: By default a file cider.config is created, and an error is thrown in'
              r,←⊂'               case it already exists. You can use -acceptConfig to overwrite this and'
              r,←⊂'               force CreateProject to accept an already existing config file.'
              r,←⊂'-noEdit:       With -noEdit you can prevent the user from being asked to edit the config file.'
              r,←⊂'-alias:        In case you are going to work on that project frequently you may specify'
              r,←⊂'               -alias=name'
              r,←⊂'Note that the alias is not case sensitive'
          :Case ⎕C'CloseProject'
              r,←⊂'Breaks the Link between the project and the files on disk.'
              r,←⊂'You may specify a particular project (namespace name) or the -all flag.'
              r,←⊂'In the latter case all projects in # are closed.'
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

    ∇ P←LoadCiderCode dummy;res;debugFlag;folder;msg
      :If debugFlag←'Is ON'≡⎕SE.UCMD'UDEBUG'
      :OrIf 0=⎕SE.⎕NC'_Cider'
          P←'_Cider'⎕SE.⎕NS''
          :If debugFlag
              ⎕EX P
              folder←¯1↓1⊃⎕NPARTS ##.SourceFile
              msg←⎕SE.Link.Create P folder
              'Could not Link the Cider application code'Assert∨/'Linked:'⍷msg
          :Else
              folder←(1⊃⎕NPARTS ##.SourceFile),'\Cider.aplc'
              res←({⍵.overwrite←1 ⋄ ⍵}⎕NS'')⎕SE.Link.Import P folder
              'Could not import the Cider application code'Assert∨/'Imported:'⍷res
          :EndIf
          ⎕SE.Cider←⎕SE._Cider.Cider            ⍝ Establish the API
      :Else
          P←⍕⎕SE._Cider
      :EndIf
      P←⍎P,'.Cider'
    ∇

    ∇ r←{namespace}CreateProject(folder acceptFlag noEditFlag);filename;success;config;projectFolder;parms
      :Access Public Shared
      namespace←{0<⎕NC ⍵:⍎⍵ ⋄ ⍬}'namespace'
      r←''
      :If 0≡folder
          folder←⊃1 ⎕NPARTS''
          :If ~0 YesOrNo'Sure that you to convert ',folder,' into a project?'
              :Return
          :EndIf
      :EndIf
      filename←(AddSlash folder),configFilename
      :If acceptFlag
          ('The -accepConfig flag was set but no file "',configFilename,'" was found')Assert ⎕NEXISTS filename
      :Else
          :If ~⎕NEXISTS folder
              'Invalid path'Assert ⎕NEXISTS 1⊃⎕NPARTS{⍵↓⍨-(¯1↑⍵)∊'/\'}folder
              :If 1 YesOrNo'"',folder,'" does not exist yet - create?'
                  ⎕MKDIR folder
              :EndIf
          :EndIf
          CreateConfigFile filename
      :EndIf
      :If ~noEditFlag
          (success config)←EditCiderConfig filename
      :Else
          success←1
          config←⎕JSON⍠('Dialect' 'JSON5')⊣⊃⎕NGET filename
      :EndIf
      :If success
          :If namespace≢⍬
              projectFolder←1⊃⎕NPARTS filename
              (⍎namespace).{⎕EX ⎕NL⍳16}⍬
              parms←P.CreateOpenParms ⍬
              parms.folder←projectFolder
              parms.projectSpace←config.CIDER.projectSpace
              parms.parent←config.CIDER.parent
              parms.quietFlag←1
          :AndIf P.OpenProject parms
              r←'Project created and opened'
          :Else
              r←'Project created'
          :EndIf
      :Else
          ⎕NDELETE filename
          r←'*** No action taken'
      :EndIf
    ∇

    ∇ {name}←CreateConfigFile filename;config
    ⍝ Copies the config template file over and injects the last part of the path of "filename" as "projectSpace"
      ('The folder already hosts a file "',configFilename,'"')Assert~⎕NEXISTS filename
      config←⊃⎕NGET(⊃⎕NPARTS ##.SourceFile),configFilename,'.RemoveMe'
      name←2⊃⎕NPARTS ¯1↓1⊃⎕NPARTS filename
      ((~name∊⎕D,⎕A,'_∆⍙',⎕C ⎕A)/name)←'_'
      config←'"projectSpace": "\?\?"'⎕R('"projectSpace": "',name,'"')⊣config
      (⊂config)⎕NPUT filename
    ∇

    ∇ path←OpenFileDialogBox caption;ref;res;filename
      path←''
      ref←⎕NEW⊂'FileBox'
      ref.Caption←caption
      ref.(onFileBoxOK onFileBoxCancel)←1
      ref.File←'cider.config'
      res←ref.Wait
      :If 'FileBoxOK'≡2⊃res
      :AndIf 0<≢ref.File
      :AndIf ⎕NEXISTS filename←⊃,/ref.(Directory File)
          path←⊃1 ⎕NPARTS filename
      :EndIf
    ∇

    ∇ r←CloseProject(arg all);list
      r←''
      :If 0≡arg
          :If all
              r←P.CloseProject ⍬
          :Else
              'Neither a project nor -all was specified'⎕SIGNAL 11
          :EndIf
      :Else
          r←P.CloseProject arg
      :EndIf
    ∇

    ∇ r←ShowHelp dummy;list;folder;flag;answer
      r←''
      folder←1⊃⎕NPARTS ##.SourceFile
      :If 0=≢list←⊃⎕NINFO⍠('Wildcard' 1)⊣folder,'*.html'
          r←'No documentation found for Cider in ',folder
      :Else
          list←{⊃,/1↓⎕NPARTS ⍵}¨list
          flag←0
          :Repeat
              ⎕←(⎕PW-1)↑'--- Cider help ',⎕PW⍴'-'
              ⎕←'Which one would you like to view?'
              ⎕←' ',' ',↑(⍳≢list){(⍕⍺),'.',' ',⍵}¨2⊃∘⎕NPARTS¨list
              ⎕←''
              answer←⊃¯1↑⍞,0/⍞←'Enter a single number or "a" for all or "q" for quit: '
              :If answer∊'12aAqQ'
                  :Select answer
                  :Case '1'
                      ⎕SE.UCMD'Open ',folder,1⊃list
                  :Case '2'
                      ⎕SE.UCMD'Open ',folder,2⊃list
                  :CaseList 'aA'
                      {⎕SE.UCMD'Open ',⍵}¨folder∘,¨list
                  :CaseList 'qQ'
                      ⍝ Nothing to do
                  :EndSelect
                  flag←1
              :EndIf
          :Until flag
      :EndIf
    ∇

    ∇ {(isOkay json)}←EditCiderConfig filename;config;dmx;config;rc;msg;flag
    ⍝ Allows the user to edit the contents of the file in Dyalog's editor and checks the changes afterwards.
    ⍝ Returns a 1 in case the contents of the file os valid and 0 otherwise
      isOkay←0
      config←''
      ('File "',filename,'" does not exist')Assert ⎕NEXISTS filename
      config←⊃⎕NGET filename
      flag←0
      :Repeat
          ⎕ED'config'
          :If 0=≢config
              :If YesOrNo'Sure you want to quit without creating the file cider.config?'
                  ⎕NDELETE filename
                  :Return
              :Else
                  json←⊃⎕NGET filename
                  :Continue
              :EndIf
          :EndIf
          :Trap 0
              json←⎕JSON⍠('Dialect' 'JSON5')⊣config
          :Else
              dmx←⎕DMX
              ⎕←'*** Error - could not convert JSON into a namespace: ',dmx.Message
              :Continue
          :EndTrap
          (rc msg)←CheckConfig json
          :If 0=rc
              flag←isOkay←1
          :Else
              ⎕←msg
              flag←0=1 YesOrNo'Would you like to correct the error? ("n"= save as is)'
          :EndIf
      :Until flag
      :If isOkay
          (⊂config)⎕NPUT filename 1
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
      r←⍬
      filename←P.GetCiderAliasFilename
      :If ~⎕NEXISTS filename
          3 ⎕MKDIR 1⊃⎕NPARTS filename
          (⊂'')⎕NPUT filename
      :EndIf
      aliases_←P.GetAliasFileContent
      aliases←⍕aliases_
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
    ∇

    ∇ yesOrNo←{default}YesOrNo question;isOkay;answer;add;dtb;answer2
    ⍝ Ask a simple question and allows just "Yes" or "No" as answers.
    ⍝ You may specify a default via the optional left argument which when specified
    ⍝ rules what happens when the user just presses <enter>.
    ⍝ `default` must be either 1 (yes) or 0 (no).
    ⍝ Note that this function does not work as expected when traced!
      isOkay←0
      default←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'default'
      isOkay←0
      :If 0≠≢default
          'Left argument must be a scalar'⎕SIGNAL 11/⍨1≠≢default
      :AndIf ~default∊0 1
          'The left argument. if specified, must be a Boolean or empty'⎕SIGNAL 11
      :EndIf
      :If 0=≢default
          add←' (y/n) '
      :Else
          :If default
              add←' (Y/n) '
          :Else
              add←' (y/N) '
          :EndIf
      :EndIf
      :If 1<≡question
          ((≢question)⊃question)←((≢question)⊃question),add
          question←⍪question
      :Else
          question←question,add
      :EndIf
      :Repeat
          ⍞←question
          answer←⍞
          :If answer≡question                        ⍝ Did...  (since version 18.0 trailing blanks are not removed anynmore)
          :OrIf (≢answer)=¯1+≢question               ⍝ ..the ...
          :OrIf 0=≢answer                            ⍝ ...user just...
              dtb←{⍵↓⍨-+/∧\' '=⌽⍵}
              answer2←dtb answer
          :OrIf answer2≡((-≢answer2)↑(⎕UCS 10){~⍺∊⍵:⍵ ⋄ ' ',dtb ⍺{⌽⍵↑⍨1+⍵⍳⍺}⌽⍵}question)   ⍝ ...press <enter>?
              :If 0≠≢default
                  yesOrNo←default
                  isOkay←1
              :EndIf
          :Else
              answer←¯1↑{⍵↓⍨-+/∧\' '=⌽⍵}answer
              :If answer∊'YyNn'
                  isOkay←1
                  yesOrNo←answer∊'Yy'
              :EndIf
          :EndIf
      :Until isOkay
    ∇

    ∇ r←SelectFromAliases dummy;data;row
      r←⍬
      :If 0<≢data←P.GetAliasFileContent
          data[;1]←{'[',⍵,']'}¨data[;1]
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

    BitsToInt←{(32⍴2)⊥⌽32↑⍵}
    IntToBits←{⌽(32⍴2)⊤⍵}

:EndClass
