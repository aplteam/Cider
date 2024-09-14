:Class  Latest_uc

    ∇ r←List;⎕IO;⎕ML ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
      ⎕IO←⎕ML←1
      r←⎕NS''
      r.Name←'Latest'
      r.Desc←'Prints some/all objects found in either a folder or in the workspace, sorted by their "Changed" date'
      r.Group←'FN'
     ⍝ Parsing rules for each:
      r.Parse←' -recursive∊0 1 -stats -allFiles -version -days= -se'
    ∇

    ∇ r←Run(Cmd Args);⎕IO;⎕ML;stats;noOf;flag;value;ref;recursive;path;allFiles;version;from;to;b;list;row;L;openCiderProjects;caption;name;f1;f2;days;includeQSE
      :Access Shared Public
      ⎕IO←1 ⋄ ⎕ML←3
      version←0 Args.Switch'version'
      f2←0
      :If f1←0<⎕SE.⎕NC'Latest.∆EXEC_IN_PROJECT'
          f1←1≡⎕SE.Latest.∆EXEC_IN_PROJECT
      :EndIf
      :If ~f1
      :AndIf f2←9=⎕SE.⎕NC'Cider'
      :AndIf f2←0<≢openCiderProjects←⎕SE.Cider.ListOpenProjects 0
      :AndIf f2←(⊂'#.Latest')∊openCiderProjects[;1]
          f2←1 ⎕SE.Latest.CommTools.YesOrNo'Would you like to execute code in #.Latest rather than ⎕SE.Latest?'
      :EndIf
      :If f1∨f2
          L←#.Latest.Latest
      :Else
          L←⎕SE.Latest
      :EndIf
      :If version
          r←L.Version ⋄ →0
      :EndIf
      recursive←1 Args.Switch'recursive'
      stats←Args.Switch'stats'              ⍝ default is empty
      allFiles←0 Args.Switch'allFiles'
      days←0 Args.Switch'days'
      includeQSE←0 Args.Switch'se'
      path←''
      :If 2=≢Args.Arguments
          path←1⊃Args.Arguments
          :If ∧/('-'~⍨2⊃Args.Arguments)∊⎕D
          :AndIf '-'∊2⊃Args.Arguments
              (from to)←2↑'-'(≠⊆⊢)2⊃Args.Arguments
              :If to∧.=' '
                  to←↑,/4 2 2{(-⍺)↑'000',⍕⍵}¨3↑⎕TS
              :EndIf
              ('Invalid argument',(1<0+.=b)/'s')⎕SIGNAL 11/⍨~∧/b←{↑↑⎕VFI ⍵}¨from to
              noOf←{2⊃⎕VFI ⍵}¨from to
          :Else
              (flag value)←⎕VFI 1⊃Args.Arguments
              :If flag
                  noOf←value
              :Else
                  path←1⊃Args.Arguments
              :EndIf
              (flag value)←⎕VFI 2⊃Args.Arguments
              :If flag
                  noOf←value
              :ElseIf (,'⍬')≡,2⊃Args.Arguments
                  noOf←⍬
              :Else
                  path←2⊃Args.Arguments
                  noOf←¯1
              :EndIf
          :EndIf
      :ElseIf 1=≢Args.Arguments
          :If 5='-'+.=↑Args.Arguments
              (↑Args.Arguments)←{('-'~⍨10↑⍵),'-',('-'~⍨11↓⍵)}↑Args.Arguments
          :ElseIf ('-'+.=↑Args.Arguments)∊2 3
              (↑Args.Arguments)←'-'~⍨10↑↑Args.Arguments
          :EndIf
          :If ∧/('-'~⍨↑Args.Arguments)∊⎕D
          :AndIf ∧/10000000<↑(//)⎕VFI↑Args.Arguments
              'Invalid Argument'⎕SIGNAL 11/⍨~('-'+.=↑Args.Arguments)∊0 1
              (from to)←2↑'-'(≠⊆⊢)1⊃Args.Arguments,'-'
              :If 0=≢to~' '
                  to←↑,/4 2 2{(-⍺)↑'000',⍕⍵}¨3↑⎕TS
              :EndIf
              noOf←{2⊃⎕VFI ⍵}¨from to
          :Else
              (flag value)←⎕VFI 1⊃Args.Arguments
              :If flag
                  noOf←value
              :ElseIf (,'⍬')≡,1⊃Args.Arguments
                  noOf←⍬
              :Else
                  path←1⊃Args.Arguments
                  noOf←¯1
              :EndIf
          :EndIf
      :ElseIf 0≠≢Args.Arguments
          'Invalid number of arguments'⎕SIGNAL 11
      :EndIf
      :If 0=⎕SE.⎕NC'Latest'
          ref←LoadCode ⍬
          ref.⎕IO←0 ⋄ ref.⎕ML←3
      :EndIf
      :If 0=≢Args.Arguments
          noOf←¯1
          path←''
      :EndIf
      :If 0≠days
          noOf←-|days
      :EndIf
      (r name)←L.Run(path recursive stats allFiles noOf includeQSE)
      →(0=+/≢¨r name)/0
      :If stats
          :If 0<≢name
              caption←']Latest statistics on:' ''name
          :Else
              caption←']Latest statistics on:' ''path
          :EndIf
          r←caption⍪r,⊂''
      :Else
          :If 0<≢name
              caption←']Latest on ',name
          :Else
              caption←']Latest on ',path
          :EndIf
          :If 2=⍴⍴r
              'Nothing found'⎕SIGNAL 6/⍨0=≢r
              r←((⊂caption),(⊂'≢ ←→ ',⍕≢r),(¯2+2⊃⍴r)⍴⊂'')⍪r
          :Else
              r←caption,'   ≢ ←→ 0'
          :EndIf
      :EndIf
      ⍝Done
    ∇

    ∇ r←level Help Cmd;⎕IO;⎕ML
      ⎕IO←⎕ML←1
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂']Latest [<no arg>|<int>|<txt>|<int&txt] -recursive=1|0 -allFiles -stats -version -days='
      :Case 1
          r,←⊂'Lists the latests changes. Is mainly designed to act on LINKed namespaces but can also'
          r,←⊂'deal with the workspace or with any folder on disk. However, when acting on the workspace'
          r,←⊂'it reports only functions and operators not stemming from a script, since only those'
          r,←⊂'carry a timestamp.'
          r,←⊂''
          r,←⊂'May be called with:'
          r,←⊂' * no argument at all'
          r,←⊂' * an integer'
          r,←⊂' * a character vector'
          r,←⊂' * both an integer and a character vector'
          r,←⊂' * 20230807'
          r,←⊂' * 2023-08-07'
          r,←⊂' * 20220101-20221231'
          r,←⊂' * 2022-01-01-2022-12-31'
          r,←⊂''
          r,←⊂'A character vector may specify either a namespace or a folder on disk.'
          r,←⊂''
          r,←⊂' * An integer smaller than 1E7 is treated as number of items to be reported'
          r,←⊂' * An integer greater than 1E7 is treated as a specific date (YYYYMMDD)'
          r,←⊂' * A negative integer is treated as number of days'
          r,←⊂' * 20230807 is treated as "from 2023-08-07 till now"'
          r,←⊂' * 20220101-20221231 is treated as "from-to" (inclusive)'
          r,←⊂''
          r,←⊂'Options:'
          r,←⊂'-allFiles       By default only APL source files are considered (by extension).'
          r,←⊂'                Change by specifying this flag.'
          r,←⊂'-days=          Number of days changes should be reported on.'
          r,←⊂'                You must not specify an integer when specifying this.'
          r,←⊂'-recursive=0|1  Defaults to 1, meaning that the path is searched recursively.'
          r,←⊂'-se             By default linked namespaces in ⎕SE are ignored. Change with -se.'
          r,←⊂'-stats          If this flag is specified you get a matrix with change statistics;'
          r,←⊂'                any other flag is ignored'
          r,←⊂'-version        Prints the version number of the user command to the session.'
          r,←⊂'                If this is specified any argument and all other flags are ignored.'
      :Case 2
          r←⎕SE.UCMD'ADOC ⎕SE.Latest'
      :EndSelect
    ∇

    ∇ {r}←LoadCode dummy
      r←⎕SE.Tatin.LoadDependencies⊂'[MyUCMDs]Latest'
    ∇

    ∇ r←GetHomeFolder
      r←1⊃⎕NPARTS ##.SourceFile
    ∇

:EndClass
