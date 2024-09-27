:Class APLGit2_uc
⍝ User Command class for "APLGit2"
⍝ Kai Jaeger

    ⎕IO←1 ⋄ ⎕ML←1
    MinimumVersionOfDyalog←'18.0'
    _errno←811

    ∇ r←List;c ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
      r←⍬
      :If AtLeastVersion⊃(//)⎕VFI MinimumVersionOfDyalog
     
          c←⎕NS''
          c.Name←'Add'
          c.Desc←'Executes the git "Add" commands'
          c.Group←'APLGit2'
          c.Parse←'1 -project='
          c._Project←0
          r,←c
     
          c←⎕NS''
          c.Name←'AddGitIgnore'
          c.Desc←'Create a file .gitignore, or merge default values with existing one'
          c.Group←'APLGit2'
          c.Parse←'1s'
          c._Project←0
          r,←c
     
          c←⎕NS''
          c.Name←'ListBranches'
          c.Desc←'Lists all branches for a Git-managed project'
          c.Group←'APLGit2'
          c.Parse←'1s -a -r'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'ChangeLog'
          c.Desc←'Takes an APL name and list all commits the object was part of'
          c.Group←'APLGit2'
          c.Parse←'1 -project='
          c._Project←0
          r,←c
     
          c←⎕NS''
          c.Name←'Commit'
          c.Desc←'Performs a commit on the current branch'
          c.Group←'APLGit2'
          c.Parse←'1s -m= -add -amend'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'CompareCommits'
          c.Desc←'Compares two different commits'
          c.Group←'APLGit2'
          c.Parse←'2s -project= -use= -files'
          c._Project←0
          r,←c
     
          c←⎕NS''
          c.Name←'Diff'
          c.Desc←'Compares the working directory with HEAD'
          c.Group←'APLGit2'
          c.Parse←'1s -verbose'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'GetDefaultProject'
          c.Desc←'Returns namespace and folder of the current default project, if any'
          c.Group←'APLGit2'
          c.Parse←'0'
          c._Project←0
          r,←c
     
          c←⎕NS''
          c.Name←'GetTagOfLatestRelease'
          c.Desc←'Returns the tag of the latest release'
          c.Group←'APLGit2'
          c.Parse←'1s -verbose -username='
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'Init'
          c.Desc←'Initialises a folder for managing it by Git'
          c.Group←'APLGit2'
          c.Parse←'1s -quiet'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'IsDirty'
          c.Desc←'Reports whether there are uncommited changes'
          c.Group←'APLGit2'
          c.Parse←'1s'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'IsGitProject'
          c.Desc←'Returns "yes" or "no" depending on whether there is a ./.git folder'
          c.Group←'APLGit2'
          c.Parse←'1s'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'Log'
          c.Desc←'Shows the commit logs'
          c.Group←'APLGit2'
          c.Parse←'2s -verbose -name= -commit='
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'NoOfUntrackedFiles'
          c.Desc←'Returns the number of untracked files'
          c.Group←'APLGit2'
          c.Parse←'1s'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'OpenGitShell'
          c.Desc←'Opens a Git shell for a Git managed project'
          c.Group←'APLGit2'
          c.Parse←'1s'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'RefLog'
          c.Desc←'List reference log entries (RefLogs)'
          c.Group←'APLGit2'
          c.Parse←'1s -max= -all -branch= -project='
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'SetDefaultProject'
          c.Desc←'Specifies the project to be used in case no project is specified'
          c.Group←'APLGit2'
          c.Parse←'1s'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'Squash'
          c.Desc←'Squashes some commits in the current branch into a single one'
          c.Group←'APLGit2'
          c.Parse←'2s -m='
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'Status'
          c.Desc←'Reports all untracked files and/or all uncommitted changes'
          c.Group←'APLGit2'
          c.Parse←'1s -short'
          c._Project←1
          r,←c
     
          c←⎕NS''
          c.Name←'Version'
          c.Desc←'Returns name, version number and version date as a three-element vector'
          c.Group←'APLGit2'
          c.Parse←''
          c._Project←0
          r,←c
      :EndIf
    ∇

    ∇ r←Run(Cmd Args);folder;G;space;max;ns;msg;noOf;noProjectSelected
      :Access Shared Public
      :If 0=⎕SE.⎕NC'APLGit2'
          {}⎕SE.Tatin.LoadDependencies(⊃⎕NPARTS ##.SourceFile)'⎕SE'
      :EndIf
      G←GetRefToAPLGit2 ⍬
      :If (⊂⎕C Cmd)∊⎕C'Log' 'Squash'
          :If 0≢Args._1
          :AndIf ~⊃⊃⎕VFI Args._1~'-'  ⍝ Neither a positive integer nor "yyyy-mm-dd"
              (r space folder)←GetSpaceAndFolder Cmd Args
          :Else
              ns←⎕NS''
              ns._1←0
              (r space folder)←GetSpaceAndFolder Cmd ns
          :EndIf
      :Else
          (r space folder)←GetSpaceAndFolder Cmd Args
      :EndIf
      noProjectSelected←∧/space folder∊''⍬
      :Select ⎕C Cmd
      :Case ⎕C'Add'
          →noProjectSelected/0
          r←Add space folder Args
      :Case ⎕C'AddGitIgnore'
          →noProjectSelected/0
          r←AddGitIgnore folder
      :Case ⎕C'ChangeLog'
          →noProjectSelected/0
          r←ChangeLog space folder Args
      :Case ⎕C'Commit'
          →noProjectSelected/0
          r←Commit space folder Args
      :Case ⎕C'CompareCommits'
          →noProjectSelected/0
          r←CompareCommits space folder Args
      :Case ⎕C'Diff'
          →noProjectSelected/0
          r←Diff space folder Args
      :Case ⎕C'GetDefaultProject'
          r←GetDefaultProject ⍬
      :Case ⎕C'GetTagOfLatestRelease'
          →noProjectSelected/0
          r←GetTagOfLatestRelease space folder Args
      :Case ⎕C'RefLog'
          →noProjectSelected/0
          r←RefLog space folder Args
      :Case ⎕C'Init'
          →noProjectSelected/0
          r←Init space folder Args
      :Case ⎕C'IsDirty'
          →noProjectSelected/0
          r←IsDirty space folder Args
      :Case ⎕C'IsGitProject'
          →noProjectSelected/0
          r←IsGitProject space folder Args
      :Case ⎕C'ListBranches'
          →noProjectSelected/0
          r←ListBranches space folder Args
      :Case ⎕C'Log'
          r←Log space folder Args
      :Case ⎕C'NoOfUntrackedFiles'
          →noProjectSelected/0
          r←NoOfUntrackedFiles folder
      :Case ⎕C'OpenGitShell'
          {}OpenGitShell space folder Args
          r←''
      :Case ⎕C'RefLog'
          →noProjectSelected/0
          r←RefLog space folder Args
      :Case ⎕C'SetDefaultProject'
          r←G.SetDefaultProject{⍵/⍨0≠⍵}Args._1
      :Case ⎕C'Squash'
          →noProjectSelected/0
          msg←''Args.Switch'm'
          noOf←⊃(//)⎕VFI(⍕(1+∧/Args._1∊⎕D)⊃Args.(_2 _1)),' +0'
          r←⍪folder Squash msg noOf
      :Case ⎕C'Status'
          →noProjectSelected/0
          r←⍪Status space folder Args
      :Case ⎕C'Version'
          r←G.Version
      :Else
          ∘∘∘ ⍝ Huh?!
      :EndSelect
    ∇

    ∇ r←GetTagOfLatestRelease(project path args);username;wsPathRef;project;l
      r←''
      :If 0≡args.username
          wsPathRef←⍎{l←⎕SE.Cider.ListOpenProjects 0 ⋄ ⊃l[l[;2]⍳⊂⍵;]}path
          username←{(¯1+≢⍵)⊃⍵}'/'(≠⊆⊢)wsPathRef.CiderConfig.CIDER.project_url
      :Else
          username←args.username
      :EndIf
      project←wsPathRef.CiderConfig.CIDER.projectSpace
      r←args.verbose G.GetTagOfLatestRelease username project
    ∇

    ∇ r←AddGitIgnore folder
      r←G.AddGitIgnore folder
    ∇

    ∇ r←Log(space folder args);parms;buff
      parms←⎕NS''
      parms.verbose←args.verbose
      parms.max←¯1
      parms.since←''
      parms.name←''args.Switch'name'
      parms.commit←''args.Switch'commit'
      parms(ProcessLogParms)←(1+0≡args._2)⊃args.(_2 _1)
      r←parms G.Log folder
    ∇

    ∇ parms←parms ProcessLogParms data;max
      :If 0≢data
          :If {(10=≢⍵)∧∧/(({⊃⍵↑⍨1⌈≢⍵}1↑(⍵~'-')∊⎕D)('-'=⊃1↑∪⍵~⎕D))}data ⍝ Is it something like "1934-01-31"?
              parms.since←data
          :ElseIf ⊃⊃⎕VFI data   ⍝ Max?!
          :AndIf 0<max←⊃(//)⎕VFI data
              parms.max←max
          :EndIf
      :EndIf
    ∇

    ∇ {(filename1 filename2)}←CompareCommits(space folder args);hash1;hash2;flag;exe;parms;qdmx;name;default;hash1_;msg;rc;hash2_;buff
      (hash1 hash2)←{0≡⍵:'' ⋄ ⍵}¨args.(_1 _2)
      :If (,'.')≡,hash1
          'Argument is invalid'Assert 0=≢hash2
      :EndIf
      'Argument is invalid'Assert(,'.')≢hash2
      buff←folder G.CompareCommits hash1 hash2
      (filename1 filename2 hash1 hash2)←4↑buff,'' ''    ⍝ Because old versions of CompareCommit did not return the hashes
      (hash1 hash2)←{⍵↑⍨¨8⌊≢¨⍵}hash1 hash2              ⍝ Short version suffices
      :If 0<+/⎕NEXISTS filename1 filename2
          :If args.files
              ⎕←filename1 filename2
          :Else
              :If flag←9=⎕SE.⎕NC'CompareFiles'
                  default←''args.Switch'use'
                  :Trap 911
                      (exe name)←⎕SE.CompareFiles.EstablishCompareEXE default
                  :Else
                      qdmx←⎕DMX
                      ⎕←'Comparison with "CompareFiles" crashed'{0=≢⍵:⍺ ⋄ ⍺,' with "',⍵,'"'}qdmx.EM
                      :Return
                  :EndTrap
              :AndIf 0<≢exe
                  parms←⎕SE.CompareFiles.ComparisonTools.⍎'CreateParmsFor',name
                  parms.(file1 file2)←filename1 filename2
                  :If (,'.')≡hash1
                      parms.caption1←'Working area'
                  :Else
                      (rc msg hash1_)←folder G.##.U.RunGitCommand'show ',hash1,' -q'
                      parms.caption1←(hash1,{⍵↓⍨⍵⍳' '}{⍵↓⍨⍵⍳' '}1⊃hash1_),' from ',{⍵↓⍨⍵⍳' '}3⊃hash1_
                  :EndIf
                  (rc msg hash2_)←folder G.##.U.RunGitCommand'show ',hash2,' -q'
                  msg Assert rc=0
                  parms.caption2←(hash2,{⍵↓⍨⍵⍳' '}{⍵↓⍨⍵⍳' '}1⊃hash2_),' from ',{⍵↓⍨⍵⍳' '}3⊃hash2_
                  {}⎕SE.CompareFiles.Compare parms
                  ⎕DL 1.2×{0=⍵.⎕NC'edit1':0 ⋄ 0=⍵.(edit1+edit2)}parms ⍝ Avoild deletion/early deletion
                  ⎕NDELETE filename1 filename2
                  (filename1 filename2)←⊂''
              :Else
                  ⎕←filename1 filename2
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ (r space folder)←GetSpaceAndFolder(Cmd args)
      r←0 0⍴''
      space←folder←''
      :If ~(⊂Cmd)∊'GetDefaultProject' 'SetDefaultProject' 'Version'
          :If ({⍵⊃⍨⍸⍵.Name≡¨⊂Cmd}List)._Project
          :AndIf 0≢args._1
              (space folder)←GetSpaceAndFolder_ args._1
              ('Project <',args._1,'> not found on disk')Assert 0<≢folder
          :ElseIf 2=args.⎕NC'project'
          :AndIf (,0)≢,args.project
          :AndIf 0<≢args.project
              (space folder)←GetSpaceAndFolder_ args.project
          :Else
              (space folder)←G.EstablishProject''
          :EndIf
          :If 0=≢space,folder
              :If (⊂Cmd)∊'OpenGitShell' ''
                  folder←'.'
              :Else
                  r←'No project provided/selected'
              :EndIf
          :ElseIf ~(⊂Cmd)∊,⊂'OpenGitShell'
              ('<',folder,'> not found on disk')Assert ⎕NEXISTS folder
          :EndIf
      :EndIf
    ∇

    ∇ r←GetDefaultProject dummy
      r←G.GetDefaultProject dummy
    ∇

    ∇ r←Diff(space folder args);filter
      r←⍪args.verbose G.Diff folder
    ∇

    ∇ r←Add(space folder args);filter
      'Not a URL on GitHub'Assert 0<≢args._1
      filter←args._1
      'Invalid filter'Assert 0<≢filter
      {}filter G.Add folder
      r←0 0⍴''
    ∇

    ∇ r←ChangeLog(space folder args);msg;name;⎕TRAP
      name←args._1
      :If ~(⊃name)∊'#⎕'
          name←(⍕space),'.',name
      :EndIf
      ('Not an APL object: ',name)Assert 0<⎕NC name
      r←folder G.ChangeLog name
    ∇

    ∇ r←Init(space folder args)
      ('This folder is already managed by Git: ',folder)Assert~G.IsGitProject folder
      :If args.quiet
      :OrIf ⎕SE.CommTools.YesOrNo'Sure that you want to make ',folder,' a Git-managed folder?'
          r←args.quiet G.Init folder
      :EndIf
    ∇

    ∇ r←IsDirty(space folder args)
      r←G.IsDirty folder
      r←(r+1)⊃'Clean' 'Dirty'
    ∇

    ∇ r←NoOfUntrackedFiles folder
      r←G.NoOfUntrackedFiles folder
    ∇

    ∇ r←IsGitProject(space folder args)
      r←(1+G.IsGitProject folder)⊃'no' 'yes'
    ∇

    ∇ r←OpenGitShell(space folder args)
      r←G.OpenGitShell folder
    ∇

    ∇ r←RefLog(space folder args);branch;value;flag
      :If (,0)≡args.branch
          branch←''
      :Else
          branch←args.branch
      :EndIf
      :If (,0)≡,args.max
          r←folder G.RefLog~args.all
      :Else
          r←folder G.RefLog 0
          (flag value)←⎕VFI args.max
          '"max" must be a positive integer'Assert flag
          r←value↑r
      :EndIf
    ∇

    ∇ r←Commit(space folder args);msg;ref;branch;rc;data;flag;status;currentBranch
      branch←G.CurrentBranch folder
      :If 0<G.NoOfUntrackedFiles folder
          :If 1=args.add
          :OrIf 1 ⎕SE.CommTools.YesOrNo'Branch "',branch,'" has unstaged changes etc - shall Git''s "Add -A" command be executed?'
              (rc msg data)←folder G.##.U.RunGitCommand'add -A'
              msg Assert 0=rc
          :Else
              r←'Cancelled by user' ⋄ →0
          :EndIf
      :EndIf
      :If 0 args.Switch'amend'
          status←G.Status folder
          :If ∨/'nothing to commit, working tree clean'⍷∊status
          :AndIf 0=≢''args.Switch'm'
              r←'There is nothing to commit and you have not specified a message either?!' ⋄ →0
          :EndIf
          currentBranch←G.CurrentBranch folder
          :If 'main'≡currentBranch
          :AndIf ~∨/'(use "git push" to publish your local commits)'⍷∊status
              r←'You MUST NOT use the -amend flag when the latest commit has already been pushed' ⋄ →0
          :EndIf
          r←⍪({0≡⍵:'' ⋄ ⍵}Args.m)G.Commit folder 1
      :Else
          :If (,0)≢,args.m
          :AndIf 0<≢args.m
              msg←args.m
          :Else
              flag←0
              :Repeat
                  ref←⎕NS''
                  ref.msg←,⊂''
                  ref.⎕ED'msg'
                  msg←ref.msg{⍺/⍨~(⌽∧\0=⌽⍵)∨(∧\0=⍵)}≢¨ref.msg
                  :If (⊂branch)∊'main' 'master'
                  :AndIf 0=≢(∊msg)~'.'
                      :If 0=1 G.##.CommTools.YesOrNo'You MUST specify a meaningful message for "',branch,'"; try again (no=cancel) ?'
                          r←'Commit cancelled by user'
                          :Return
                      :EndIf
                  :ElseIf 0<≢(∊msg)~'.'
                  :OrIf G.##.CommTools.YesOrNo'Sure you don''t want to provide a message? ("No" cancells the whole operation)'
                      flag←1
                  :Else
                      r←'Operation cancelled by user'
                      :Return
                  :EndIf
                  msg←{0=≢⍵:'...' ⋄ ⍵}msg
                  msg←1↓⊃,/(⎕UCS 10),¨⊆msg
              :Until flag
          :EndIf
          r←⍪msg G.Commit folder
      :EndIf
    ∇

    ∇ r←Status(space folder args);short
      short←args.Switch'short'
      r←short G.Status folder
    ∇

    ∇ r←folder Squash(msg noOf)
      'Number of commits to be squashed must be a positive integer'Assert(⎕DR noOf)∊83 163 323
      'Number of commits to be squashed must be a positive integer'Assert noOf≥0
      r←folder G.Squash msg noOf
    ∇

    ∇ r←ListBranches(space folder args);parms
      :If (,0)≢,args.a
          parms←'-a'
      :ElseIf (,0)≢,args.r
          parms←'-r'
      :Else
          parms←''
      :EndIf
      r←⍪parms G.ListBranches folder
    ∇

    ∇ r←level Help Cmd;ref;⎕TRAP
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          :Select ⎕C Cmd
          :Case ⎕C'Add'
              r,←⊂']APLGit2.add <filter> -project='
          :Case ⎕C'AddGitIgnore'
              r,←⊂']APLGit2.AddGitIgnore [space|folder]'
          :Case ⎕C'ChangeLog <apl-name> -project='
              r,←⊂']APLGit2.ChangeLog <filter> -project='
          :Case ⎕C'Commit'
              r,←⊂']APLGit2.Commit [space|folder] -m= -add -amend'
          :Case ⎕C'CompareCommits'
              r,←⊂']APLGit2.CompareCommits [hash1] [hash2] -project= -use=[name|?] -view'
          :Case ⎕C'CurrentBranch'
              r,←⊂']APLGit2.CurrenBranch [space|folder]'
          :Case ⎕C'Diff'
              r,←⊂']APLGit2.Diff [space|folder] -verbose'
          :Case ⎕C'GetDefaultProject'
              r,←⊂']GetDefaultProject'
          :Case ⎕C'GetTagOfLatestRelease'
              r,←⊂']APLGit2.GetTagOfLatestRelease [space|folder]'
          :Case ⎕C'Init'
              r,←⊂']APLGit2.Init [folder] -quiet'
          :Case ⎕C'IsDirty'
              r,←⊂']APLGit2.IsDirty [space|folder]'
          :Case ⎕C'IsGitProject'
              r,←⊂']APLGit2.IsGitProject [space|folder]'
          :Case ⎕C'ListBranches'
              r,←⊂']APLGit2.ListBranches [space|folder] -a -r'
          :Case ⎕C'Log'
              r,←⊂']APLGit2.Log [space|folder] -since= -verbose -max= -name='
          :Case ⎕C'NoOfUntrackedFiles'
              r,←⊂']APLGit2.NoOfUntrackedFiles [space|folder]'
          :Case ⎕C'OpenGitShell'
              r,←⊂']APLGit2.OpenGitShell [space|folder]'
          :Case ⎕C'RefLog'
              r,←⊂']APLGit2.RefLog [space|folder] -max= -all -branch= -project='
          :Case ⎕C'SetDefaultProject'
              r,←⊂']APLGit2.SetDefaultProject [space|folder]'
          :Case ⎕C'Status'
              r,←⊂']APLGit2.Status -short -path='
          :Case ⎕C'Squash'
              r,←⊂']APLGit2.Squash [space|folder] [noOf] -m=<message>'
          :Else
              r,←⊂'There is no help available'
          :EndSelect
          :If 'Version'≢Cmd
              r,←''(']APLGit2.',Cmd,' -?? ⍝ Enter this for more information ')
          :EndIf
     
      :Case 1
          :Select ⎕C Cmd
          :Case ⎕C'Add'
              r,←⊂'Add files to the index.'
              r,←⊂''
              r,←⊂'You may specify one of:'
              r,←⊂' * A file'
              r,←⊂' * A folder'
              r,←⊂' * A "." (dot), meaning that all so far untracked files should be added'
              r,←⊂''
              r,←AddLevel3HelpInfo'Add'
          :Case ⎕C'AddGitIgnore'
              r,←⊂'Add a file .gitignore to a particular path or project, or merges an existing file with'
              r,←⊂'default values.'
              r,←⊂''
              r,←⊂'The user will be asked a couple of questions, and she will be able to edit the result'
              r,←⊂'of her choices before it is written to file.'
          :Case ⎕C'ChangeLog'
              r,←⊂'Takes an APL name and returns a matrix with zero or more rows and 4 columns with'
              r,←⊂'information regarding all commits the given APL object was changed:'
              r,←⊂' 1. Hash'
              r,←⊂' 2. Commiter''s name'
              r,←⊂' 3. Date of the commit date in strict ISO 8601 format'
              r,←⊂' 4. Message of the commit'
          :Case ⎕C'Commit'
              r,←⊂'Record changes to the repository.'
              r,←⊂'There should not be any untracked files, but if there are anyway the user will be asked'
              r,←⊂'whether she wants to add additions, changes & deletions first, read execute: "add -A"'
              r,←⊂''
              r,←⊂'-add    When the project is dirty then without the -add flag the user will be questioned'
              r,←⊂'        whether a "git add -A" command should be issued first. -add tells the user command'
              r,←⊂'        to do that in any case, without questioning the user.'
              r,←⊂'-m=     If this is specified it is accepted as the message.'
              r,←⊂'        If it is not specified then the command will open an edit window for the message,'
              r,←⊂'        accept when -amend was specified'
              r,←⊂'-amend  If this is specified -m= is ignored. This adds changes to the latest commit, in'
              r,←⊂'        case you forgot something minor after having commited.'
              r,←⊂'        Never to be used when the last commit was already pushed!'
              r,←⊂''
              r,←⊂''
              r,←⊂'Note that a message is epected for the "main" (or the now deprecated "master") branch but'
              r,←⊂'the user will be asked if there is none anyway. Empty messages will become "...".'
              r,←⊂''
              r,←AddLevel3HelpInfo'Commit'
          :Case ⎕C'CompareCommits'
              r,←⊂'Compare changes between two commits or a commit and the working area.'
              r,←⊂''
              r,←⊂'You may specify none, one or two hashes as argument:'
              r,←⊂' * No argument means "compare last commit with the most recent ancestor'
              r,←⊂' * One argument means "compare last commit with the given commit"'
              r,←⊂' * Two arguments mean "compare those commits with each other"'
              r,←⊂'Special syntax: If only a "." is passed as argument, the last commit is compared with the'
              r,←⊂'working area. You must not specify a hash together with the ".".'
              r,←⊂''
              r,←⊂'If the user command ]CompareFiles and its API is available then this is used'
              r,←⊂'for the comparison. Otherwise the names of two files are printed to the session.'
              r,←⊂''
              r,←⊂' * If there is just one open Cider project it is taken'
              r,←⊂' * If there are several open Cider projects the user is interrogated'
              r,←⊂' * If you do not use Cider, or if there are no open Cider projects use -project=, see there'
              r,←⊂''
              r,←⊂'-files     If you just want to get filenames printed to ⎕SE specify this modifier'
              r,←⊂'-use=      Use this to specify a particular comparison utility; see ]CompareFiles for details.'
              r,←⊂'-project=  Use this to specify a particular project with -project=[ProjectName|ProjectFolder]'
          :Case ⎕C'CurrentBranch'
              r,←⊂'Returns the name of the current branch'
              r,←⊂''
              r,←AddLevel3HelpInfo'CurrentBranch'
          :Case ⎕C'Diff'
              r,←⊂'Returns a list of files in the working directory that are different from HEAD.'
              r,←⊂''
              r,←⊂'-verbose:  Specify this to get a full report'
              r,←⊂''
              r,←AddLevel3HelpInfo'Diff'
          :Case ⎕C'GetDefaultProject'
              r,←⊂'Returns the namespace and the folder if there is a default project defined.'
              r,←⊂'See also ]APLGit2.SetDefaultProject'
          :Case ⎕C'Init'
              r,←⊂'Useful to initialize a folder for being managed by Git.'
              r,←⊂''
              r,←⊂'You may add the path to a folder as argument; if you do not then APLGit2 tries to'
              r,←⊂'figure it out.'
              r,←⊂''
              r,←⊂'-quiet is useful to prevent Init to ask any questions, mostly for tests.'
          :Case ⎕C'IsDirty'
              r,←⊂'Returns one of:'
              r,←⊂' * "Clean"'
              r,←⊂' * "Dirty"'
              r,←⊂''
              r,←AddLevel3HelpInfo'IsDirty'
          :Case ⎕C'IsGitProject'
              r,←⊂'Returns:'
              r,←⊂'Project <name> (<path) is [not] managed by Git'
              r,←⊂''
              r,←AddLevel3HelpInfo'IsGitProject'
          :Case ⎕C'GetTagOfLatestRelease'
              r,←⊂'Returns the tag number of the latest release.'
              r,←⊂'Drafts are ignored.'
              r,←⊂''
              r,←⊂'-verbose   If specified the date of the commit & the caption of the release are returned as well'
          :Case ⎕C'ListBranches'
              r,←⊂'List all branches, by default local ones.'
              r,←⊂''
              r,←⊂'You may specify two mutually exclusive options in order to change its behaviour:'
              r,←⊂' * -a stands for "all": list all local and remote branches'
              r,←⊂' * -r stands for "remote": list just remote branches'
              r,←AddLevel3HelpInfo'ListBranches'
          :Case ⎕C'Log'
              r,←⊂'Shows a list of all commits with ⎕ED, by default with --oneline, but check -verbose.'
              r,←⊂''
              r,←⊂'If you need to specify a folder (rather than acting on an open Cider project), then the folder'
              r,←⊂'must be the first argument.'
              r,←⊂''
              r,←⊂'Instead or in addition, you may specify an integer or a date; see below for details.'
              r,←⊂''
              r,←⊂' * Without an argument or just a folder/alias, the full log is printed'
              r,←⊂' * An integer is interpreted as the "max number of log entries" to be listed'
              r,←⊂' * Alternatively one can specify "YYYY-MM-DD" which is treated as "since"'
              r,←⊂''
              r,←⊂'-verbose  By default a short report is provided. Overwrite with -verbose for a detailed report.'
              r,←⊂'-name=    Use this to specify the full name of an APL object. This reduces the list to commits'
              r,←⊂'          that changed the given APL object.'
              r,←⊂'-commit=  Use this to list all commits up to (but not including) the given commit.'
              r,←AddLevel3HelpInfo'Log'
          :Case ⎕C'NoOfUntrackedFiles'
              r,←⊂'Returns the number of untracked files.'
          :Case ⎕C'OpenGitShell'
              r,←⊂'Opens a Git Bash shell, either on the given project or, if no project was provided, the'
              r,←⊂'current directory.'
              r,←⊂''
              r,←⊂'If there are opened Cider projects you can specify a path or a dot (".") for the current directory.'
              r,←AddLevel3HelpInfo'OpenGitShell'
          :Case ⎕C'RefLog'
              r,←⊂'Lists the reference log.'
              r,←⊂''
              r,←⊂'By default the command lists just log entries up to the last checkout.'
              r,←⊂''
              r,←⊂'Reference logs, or "reflogs", record when the tips of branches and other references were'
              r,←⊂'updated in the local repository. Reflogs are useful in various Git commands, to specify'
              r,←⊂'the old value of a reference.'
              r,←⊂''
              r,←⊂'-all   If you want all records then specifiy the -all flag.'
              r,←⊂'-max=  If you want a specific number then specify the max= modifier.'
          :Case ⎕C'SetDefaultProject'
              r,←⊂'Use this to specify a default project.'
              r,←⊂'Commands that require a project will act on the default project in case it was set.'
              r,←⊂'See also ]APLGit2.GetDefaultProject'
          :Case ⎕C'Status'
              r,←⊂'Reports the status from Git''s perspective.'
              r,←⊂'By default a verbose report is printed.'
              r,←⊂'Specify -short for getting just the essentials.'
              r,←AddLevel3HelpInfo'Status'
          :Case ⎕C'Squash'
              r,←⊂'Squashes some commits of the current branch into a single commit.'
              r,←⊂'The current branch MUST be neither "main" nor "master".'
              r,←⊂''
              r,←⊂'If no argument is specifid all suitable commits will be listed.'
              r,←⊂'By specifying a positive integer you can specify the number of commits to be squashed'
              r,←⊂''
              r,←⊂'-m     You may specify a message with -m="my message", but if you don''t you will be given an edit'
              r,←⊂'       window for specifying a message. It will be populated with the messages from the commits'
              r,←⊂'       about to be squashed.'
          :Else
              r,←⊂'There is no additional help available'
          :EndSelect
      :Case 2
          :Select ⎕C Cmd
          :CaseList ⎕C¨'Add' ''
              r,←AddProjectOptions 1
          :CaseList ⎕C¨'Commit' 'CurrentBranch' 'Diff' 'IsDirty' 'IsGitProject' 'ListBranches' 'Log' 'OpenGitShell' 'Status'
              r,←AddProjectOptions 0
          :Else
              r,←⊂'There is no additional help available'
          :EndSelect
     
      :EndSelect
    ∇

    ∇ r←AddLevel3HelpInfo fn
      r←⊂''
      r,←⊂'For more information execute:'
      r,←⊂']APLGit2.',fn,' -???'
    ∇

    ∇ r←AddProjectOptions flag
      r←''
      r,←⊂'The ]APLGit2.* user commands are particularly useful when used in conjunction with the project'
      r,←⊂'manager Cider, but they can be used without Cider as well, though you must then specify the'
      r,←⊂'folder you wish the user command to act on.'
      r,←⊂''
      r,←⊂'Note that APLGit2 does not accept URLs pointing to GitHub, it works only locally.'
      r,←⊂''
      r,←⊂'By default a user command will act on the currently opened Cider project if there is just one.'
      r,←⊂'If there are multiple open Cider projects, the user will be asked which one to act on.'
      r,←⊂''
      r,←⊂'Once a default project got established, and there are several Cider projects opened, the user will'
      r,←⊂'be asked if she wants to act on the default project. If she refuses, a list with all opened Cider'
      r,←⊂'projects will be presented to her.'
      :If flag
          r,←⊂''
          r,←⊂'You may specify a project by setting -project=. It must be one of:'
          r,←⊂' * The fully qualified path to a namespace that is an opened Cider project'
          r,←⊂' * The path to a git-managed folder'
          r,←⊂'   In this case it does not have to be an open Cider project, and not even a closed one.'
      :EndIf
    ∇

    ∇ r←AtLeastVersion min;currentVersion
      :Access Public Shared
      ⍝ Returns 1 if the currently running version is at least `min`.\\
      ⍝ If the current version is 17.1 then:\\
      ⍝ `1 1 1 0 ←→ AtLeastVersion¨16 17 17.1 18`\\
      ⍝ You may specify a version different from the currently running one via `⍺`:\\
      ⍝ `1 1 0 0 ←→ 17 AtLeastVersion¨16 17 17.1 18`
      currentVersion←{⊃⊃(//)⎕VFI ⍵/⍨2>+\⍵='.'}2⊃'.'⎕WG'aplversion'
      'Right argument must be length 1'⎕SIGNAL _errno/⍨1≠≢min
      r←⊃min≤currentVersion
    ∇

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ (∊⍺) ⎕SIGNAL 1↓(⊃∊⍵),_errno}

    ∇ r←r AddTitles titles
    ⍝ `r` is a matrix with data. `titles` is put on top of that matrix, followed by a row with `-` matching the lengths of each title
      r←⍉↑(⊂¨titles),¨' ',¨↓⍉r
      r[2;]←(≢¨r[1;])⍴¨'-'
    ∇

    ∇ path←AddSlash path
      path,←(~(¯1↑path)∊'/\')/'/'
    ∇

    ∇ (space folder)←GetSpaceAndFolder_ data
      :If ∨/'/\:'∊data
      :OrIf ~(⊃data)∊'#⎕'
          folder←data
          space←G.GetProjectFromPath folder
      :Else
          space←data
          folder←G.GetPathFromProject space
      :EndIf
    ∇

    ∇ ref←GetRefToAPLGit2 dummy
      :If 9=#.⎕NC'APLGit2.APLGit2'
      :AndIf 0<⎕SE.APLGit2.⎕NC'DEVELOPMENT'
      :AndIf ⎕SE.APLGit2.DEVELOPMENT
      :AndIf 0={0=⍵.⎕NC'∆TestFlag':0 ⋄ ⍵.∆TestFlag}#.APLGit2.APLGit2
          ref←#.APLGit2.APLGit2.API
      :Else
          ref←⎕SE.APLGit2
      :EndIf
    ∇

:EndClass
