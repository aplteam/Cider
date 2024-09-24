:Namespace CompareFiles_UC
⍝ This script directs calls to the CompareFiles user commands to CompareFiles itself.
⍝ It's just an interface that does not do anything by itself.
⍝ Version 0.1.0 ⋄ 2024-05-20 ⋄ Kai Jaeger

    ∇ PrintError dummy;msg
      msg←''
      :If 3=⎕NC'⎕SE.CompareFiles.Version'
          msg←' CompareFiles is not installed correctly. Please remove and install again.'
      :EndIf
      ⎕←msg
    ∇

    ∇ r←List;c
      r←⎕NS''
      r.Group←'TOOLS'
      r.Name←'CompareFiles'
      r.Parse←'2s -edit1 -edit2 -caption1= -caption2= -use= -save -version -config -editconfig'
      r.Desc←'Compare two files with each other.'
    ⍝Done
    ∇

    ∇ r←level Help cmd;ref
      r←0⍴⊂''
      :If 0=⎕NC'⎕SE.CompareFiles'
          {}⎕SE.UCMD'CompareFiles -version'
      :Else
          ref←GetRefToCompareFiles''
          :If 3=ref.⎕NC'UC.Help'
              r←level ref.UC.Help cmd
          :Else
              PrintError''
          :EndIf
      :EndIf
    ∇

    ∇ r←Run(cmd args);ref
      r←''
      :If 0=⎕NC'⎕SE.CompareFiles'
          {}⎕SE.Tatin.LoadDependencies(1⊃⎕NPARTS ##.SourceFile)⎕SE
      :EndIf
      ref←GetRefToCompareFiles''
      :If 3=ref.⎕NC'UC.Run'
          r←ref.UC.Run(cmd args)
      :Else
          PrintError''
      :EndIf
    ∇


    ∇ ref←GetRefToCompareFiles dummy;statuse
      :If 0<⎕SE.⎕NC'Link'
          statuse←⎕SE.Link.Status''
      :AndIf 2=⍴⍴statuse
      :AndIf (⊂'#.CompareFiles')∊statuse[;1]
      :AndIf 0<⎕SE.CompareFiles.⎕NC'DEVELOPMENT'
      :AndIf 0<⎕SE.CompareFiles.DEVELOPMENT
          ref←#.CompareFiles.CompareFiles
      :Else
          ref←⎕SE.CompareFiles.##
      :EndIf
    ∇

:EndNamespace
