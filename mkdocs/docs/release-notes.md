---
title: Cider release notes
description: The version history of Cider, the project manager for Dyalog APL software authors.
keywords: api, apl, cider, dyalog, link, source, tatin, versions
---
# Release notes


!!! abstract "Version history"

For a full list of fixes, see [Cider on GitHub](https://github.com/aplteam/Cider/releases).

<style>
  .nowrap {
    white-space: nowrap;
  }
</style>

-------|------------|--------------
0.44.0 | 2024-11-16 | `]OpenProject`’s report of Git status enhanced and streamlined.<br><br>Some bug fixes.
0.43.2 | 2024-13  <!-- FIXME Correct the date. --> | Bug fixes.
0.43.1 | 2024-09-25 | Bug fixes.
0.43.0 | 2024-09-23 | The `-raw` option removed from the `]ListTatinDependencies` user command
0.42.4 | 2024-09-07 | Bug fixes.
0.42.3 | 2024-09-05 | Bug fixes.
0.42.2 | <span class="nowrap">2024-08-04</span> | Bug fixes.
0.42.1 | 2024-07-12 | Previously Cider injected a reference `TatinVars` into a child space of the project defined by Cider's `tatinVars` property, pointing to `TatinVars` in the project space.<br><br>With version 0.42.1, if `tatinVars` specifies a child space, `TatinVars` is not injected into the project space but into the child space defined by the `tatinVars` property.<br><br>The `]Cider.ProjectConfig` user command `-print` option replaced by `-edit` option. By default it prints the global config to the session.<br><br>Aligns this user command syntactically with `]CIDER.Config` and similar Tatin commands.













