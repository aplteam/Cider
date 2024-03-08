:Namespace Cider_UC
⍝ This script directs calls to the Cider user commands to Cider itself.
⍝ It's just an interface that does not do anything by itself.
⍝ Version 0.1.0 ⋄ 2024-03-07 ⋄ Kai Jaeger

    ∇ PrintError dummy;msg
      msg←''
      :If 3=⎕NC'⎕SE.Cider.Version'
          msg←' Cider is not installed correctly. Please remove and install again.'
      :EndIf
      ⎕←msg
    ∇

    ∇ r←List;ref
      r←''
      :If 9=⎕NC'⎕SE.Cider'
          ref←GetRefToCider''
          :If 3=ref.UC.⎕NC'List'
              r←ref.UC.List
          :Else
              PrintError''
          :EndIf
      :EndIf
    ∇

    ∇ r←level Help cmd;ref
      r←0⍴⊂''
      :If 9=⎕NC'⎕SE.Cider'
          ref←GetRefToCider''
          :If 3=ref.⎕NC'UC.Help'
              r←level ref.UC.Help cmd
          :Else
              PrintError''
          :EndIf
      :Else
          ⎕←'Cider not found'
      :EndIf
    ∇

    ∇ r←Run(cmd args);ref
      r←''
      :If 9=⎕NC'⎕SE.Cider'
          ref←GetRefToCider''
          :If 3=ref.⎕NC'UC.Run'
              r←ref.UC.Run(cmd args)
          :Else
              PrintError''
          :EndIf
      :Else
          ⎕←'Cider not found'
      :EndIf
    ∇


    ∇ ref←GetRefToCider dummy;statuse
      :If 0<⎕SE.⎕NC'Link'
          statuse←⎕SE.Link.Status''
      :AndIf 2=⍴⍴statuse
      :AndIf (⊂'#.Cider')∊statuse[;1]
      :AndIf 0<⎕SE.Cider.⎕NC'DEVELOPMENT'
      :AndIf 0<⎕SE.Cider.DEVELOPMENT
          ref←#.Cider.Cider
      :Else
          ref←⎕SE.Cider.##
      :EndIf
    ∇

:EndNamespace
