:Class  CodeBrowser_uc
⍝ User Command script for "CodeBrowser"
⍝ Kai Jaeger
⍝ Version 5.0.0 - 2023-06-17

    ∇ r←List;⎕IO;⎕ML
      :Access Shared Public
      ⎕IO←⎕ML←1
      r←⍬
     
      :If IfAtLeastVersion 18
          r←⎕NS''
          r.Name←'CodeBrowser'
          r.Desc←'Starts "CodeBrowser"'
          r.Group←'Tools'
          r.Parse←'-ignore= -caption= -filename= -footer= -info= -r= -view -twosided -pfs= -obj= -lang= -p -gui -version -lines='
      :EndIf
    ∇

    ∇ r←Run(Cmd Args);⎕IO;⎕ML;C;parms;flags;values
      :Access Shared Public
      ⎕IO←1 ⋄ ⎕ML←1
      Args←ProcessLinesParameter Args
      C←⎕SE.CodeBrowser
      :If ' '={⎕ML←3 ⋄ 1↑0⍴∊⍵}Args.lines
          (flags values)←⎕VFI Args.lines
      :Else
          flags←1
          values←Args.lines
      :EndIf
      'Invalid: "lines"'⎕SIGNAL 11/⍨1≠≢flags
      'Invalid: "lines"'⎕SIGNAL 11/⍨((,¯1)≢,values)∧(,¯1)≡,×values
      :If 0=values
          values←20  ⍝ The default
      :EndIf
      Args.lines←values
      :If Args.version
          r←C.Version
          :Return
      :ElseIf Args.gui
          'The -gui flag is available under Windows only'⎕SIGNAL 11/⍨~##.WIN
          r←C.##.GUI.Run Args.Arguments ''
      :Else
          'No namespace(s) specified'⎕SIGNAL 11/⍨0=≢Args.Arguments
          parms←C.CreateParms ''
          parms←parms Args2Parms Args
          :If 0≠≢parms.ignore
              parms.ignore←' 'C.##.A.Split C.##.A.DMB parms.ignore
              parms.ignore←({⊃⍵↓⍨+/∧\'⎕'=⊃¨⍵}⎕NSI)∘{0<⎕NC ⍵:⍵ ⋄ ⍺,'.',⍕⍵}¨parms.ignore
          :EndIf
          r←parms C.Run Args.Arguments
      :EndIf
    ∇

    ∇ r←level Help Cmd;⎕IO;⎕ML;ref;parms;C
      ⎕IO←1 ⋄ ⎕ML←1
      :Access Shared Public
      r←''
      :Select level
      :Case 0
          r,←⊂']CodeBrowser <namespace(s)> -version! -gui! -ignore= -caption= -filename= -footer= -info= -lang= -lines= -p -r=[0|1] -view - -towsided -pfs= -obj='
      :Case 1
          r,←⊂'Starts CodeBrowser. Specify namespace(s) to be investigated as argument.'
          r,←⊂'Loads CodeBrowser and any dependencies into ⎕SE and starts it.'
          r,←⊂''
          r,←⊂'There are plenty of switches available to make CodeBrowser suit your needs:'
          r,←⊂''
          r,←⊂'-ignore=     List of space- or comma-separated namespaces/scripts to be ignored.'
          r,←⊂'-caption=    Defaults to the list of namespaces to be scanned.'
          r,←⊂'-filename=   Defaults to a temp filename.'
          r,←⊂'-footer=     No default. If specified it goes underneath a horizontal line at the bottom of the document.'
          r,←⊂'-gui         Puts a GUI on display that lets you specify all parameters. Everything else is ignored.'
          r,←⊂'             Note that the GUI allows you to specify parameters that are not available via the user command.'
          r,←⊂'-info=       No default. Ordinary text that goes underneath the main header ("caption"). No HTML please.'
          r,←⊂'-lang=       "language"; defaults to "en".'
          r,←⊂'-lines=      Defaults to ¯1 which means "no limit". Instead you can set a max number of lines.'
          r,←⊂'-p           Add table with parameters to the end of the document with a page break before the table.'
          r,←⊂'-r=          Recursive; defaults to 1. Must be a Boolean.'
          r,←⊂'-view        View in default browser.'
          r,←⊂'-twosided    Two-side prints have different left margins on odd/even pages.'
          r,←⊂'-pfs=        Print Font Size. Defaults to 8. Must be numeric (pt).'
          r,←⊂'-obj=        f=function, g=GUI (only when KeepOnClose is 1), o=operators, v=variables, s=scripts.'
          r,←⊂'-version     If you specify this flag then all other flags are ignored. Returns CodeBrowser''s version number.'
          r,←⊂''
          r,←⊂'For processing CodeBrowser''s code by CodeBrowser execute ⎕se.CodeBrowser.Selfie ⍬'
          r,←⊂'For getting CodeBrowser''s internal documentation execute ]CodeBrowser -???'
      :Case 2
          {}⎕SE.UCMD'ADOC ⎕SE.CodeBrowser'
      :EndSelect
    ∇

    ∇ r←{default}ReadRegKey key;wsh;⎕WX
     ⍝ Read a registry key. Uses a particular default path which can be overridden via the left argument
      :Access public shared
      ⎕WX←1
      default←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'default'
      'wsh'⎕WC'OLEClient' 'WScript.Shell'
      :Trap 11
          r←wsh.RegRead key
      :Else
          r←default
      :EndTrap
    ∇

      Split←{
          ⎕ML←⎕IO←1
          ⍺←⎕UCS 13 10 ⍝ Default is CR+LF
          (⍴,⍺)↓¨⍺{⍵⊂⍨⍺⍷⍵}⍺,⍵
      }

    ∇ parms←parms Args2Parms args
      parms.lines←args.lines  ⍝ Already processed
      :If 0≢args.ignore
          '"ignore": invalid data type'⎕SIGNAL 11/⍨' '≠1↑0⍴∊args.ignore
          parms.ignore←args.ignore
      :EndIf
      :If 0≢args.caption
          '"caption": invalid data type'⎕SIGNAL 11/⍨' '≠1↑0⍴∊args.caption
          parms.caption←args.caption
      :EndIf
      :If 0≢args.footer
          '"footer": invalid data type'⎕SIGNAL 11/⍨' '≠1↑0⍴∊args.footer
          parms.footer←args.footer
      :EndIf
      :If 0≢args.filename
          '"filename": invalid data type'⎕SIGNAL 11/⍨' '≠1↑0⍴∊args.filename
          parms.filename←args.filename
      :EndIf
      :If 0≢args.info
          '"info": invalid data type'⎕SIGNAL 11/⍨' '≠1↑0⍴∊args.info
          parms.info←args.info
      :EndIf
      :If 0≢args.pfs
          '"pfs" (print font size) is not numeric'⎕SIGNAL 11/⍨(,1)≢,⊃⎕VFI args.pfs
          parms.printFontSize←args.pfs
      :EndIf
      :If 0≢args.obj
          '"obj": invalid data type'⎕SIGNAL 11/⍨' '≠1↑0⍴∊args.obj
          parms.processScripts←∨/'sS'∊args.obj
          parms.processFunctions←∨/'fF'∊args.obj
          parms.processOperators←∨/'Oo'∊args.obj
          parms.processVars←∨/'Vv'∊args.obj
          parms.processGuiInstances←∨/'Gu'∊args.obj
      :EndIf
      :If 0≢args.r
          '"recursive" is not a Boolean'⎕SIGNAL 11/⍨0=1↑∊⎕VFI args.r
          '"recursive" is not a Boolean'⎕SIGNAL 11/⍨~(∊(//)⎕VFI args.r)∊0 1
          parms.recursive←∊(//)⎕VFI args.r
      :EndIf
      :If 0≢args.lang
          '"lang" is not text like "en"'⎕SIGNAL 11/⍨~(1=≡args.lang)∧(' '=1↑0⍴∊args.lang)∧(2=⍴,args.lang)
          parms.lang←args.lang
      :EndIf
      parms.viewInBrowser←Args.Switch'view'
      parms.showParms←Args.Switch'p'
      parms.twoSidedPrint←Args.Switch'twosided'
    ∇

    ∇ Args←ProcessLinesParameter Args;flags;values
      :If ' '={⎕ML←3 ⋄ 1↑0⍴∊⍵}Args.lines
          (flags values)←⎕VFI Args.lines
      :Else
          flags←1
          values←Args.lines
      :EndIf
      'Invalid: "lines"'⎕SIGNAL 11/⍨1≠≢flags
      'Invalid: "lines"'⎕SIGNAL 11/⍨((,¯1)≢,values)∧(,¯1)≡,×values
      :If 0=values
          values←¯1  ⍝ The default
      :EndIf
      Args.lines←values
    ∇

    IfAtLeastVersion←{⍵≤{⊃(//)⎕VFI ⍵/⍨2>+\'.'=⍵}2⊃# ⎕WG'APLVersion'}

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⍺ ⎕SIGNAL 1↓(⊃∊⍵),_errno}

:EndClass
