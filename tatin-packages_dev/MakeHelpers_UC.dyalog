:Class MakeHelpers_UC
⍝ Puts MakeHelper's internal documentation on display
⍝ Everything else is available via MakeHelper's API

    ⎕IO←⎕ML←1

    ∇ r←List;c
      :Access Shared Public
      r←⍬
     
      c←⎕NS''
      c.Name←'MakeHelpers'
      c.Desc←'MakeHelpers offers helpers for creating a new version of a package or an application or something in between via its API'
      c.Group←'TOOLS'
      c.Parse←'0'
      r,←c
    ∇

    ∇ r←Run(Cmd Args)
      :Access Shared Public
      r←''
      {}⎕SE.UCMD'ADOC ',(⍕⎕SE.MakeHelpers),' -title=MakeHelpers'
    ∇

    ∇ r←level Help Cmd;⎕IO;⎕ML
      ⎕IO←⎕ML←1
      :Access Shared Public
      r←''
      r,←⊂']MakeHelpers'
      r,←⊂'Puts the internal documentation on display. All the functionality is available via the API.'
    ∇

:EndClass
