:Class APLGit2_uc
⍝ User Command class for "APLGit2"
⍝ Kai Jaeger

    ⎕IO←1 ⋄ ⎕ML←1

    ∇ r←List;c;G ⍝ this function usually returns 1 or more namespaces (here only 1)
      :Access Shared Public
      r←⍬
      G←GetRefToAPLGit2 ⍬
      r←G.##.UC.List ⍬
    ∇

    ∇ r←Run(Cmd Args);folder;G;space;ns;noProjectSelected;func
      :Access Shared Public
      :If 0=⎕SE.⎕NC'APLGit2'
          {}⎕SE.Tatin.LoadDependencies(⊃⎕NPARTS ##.SourceFile)'⎕SE'
      :EndIf
      G←GetRefToAPLGit2 ⍬
      :If (⊂⎕C Cmd)∊⎕C'Log' 'Squash'
          :If 0≢Args._1
          :AndIf ~⊃⊃⎕VFI Args._1~'-'  ⍝ Neither a positive integer nor "yyyy-mm-dd"
              (r space folder)←G.##.UC.GetSpaceAndFolder Cmd Args
          :Else
              ns←⎕NS''
              ns._1←0
              (r space folder)←G.##.UC.GetSpaceAndFolder Cmd ns
          :EndIf
      :Else
          (r space folder)←G.##.UC.GetSpaceAndFolder Cmd Args
      :EndIf
      noProjectSelected←∧/space folder∊''⍬
      func←G.##.UC⍎Cmd
      r←func space folder Args
    ⍝Done
    ∇

    ∇ r←level Help cmd;ref
      :Access Shared Public
      r←0⍴⊂''
      :If 9=⎕NC'⎕SE.APLGit2'
          ref←GetRefToAPLGit2''
          :If 3=ref.##.⎕NC'UC.Help'
              r←level ref.##.UC.Help cmd
          :Else
              PrintError''
          :EndIf
      :Else
          ⎕←'APLGit2 not found'
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

    ∇ PrintError dummy;msg
      msg←''
      :If 3=⎕NC'⎕SE.APLGit2.Version'
          msg←' APLGit2 is not installed correctly. Please remove and install again.'
      :EndIf
      ⎕←msg
    ∇

:EndClass
