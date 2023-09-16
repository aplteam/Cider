[parm]:width             = 1000
[parm]:lang              = en
[parm]:leanpubExtensions = 1
[parm]:collapsibleTOC    = 1
[parm]:title             = 'Styles'
[parm]:toc               = 2 3 4 5 6
[parm]:numberHeaders     = 6
[parm]:printCSS          = 'BlackOnWhite_screen.css'
[parm]:screenCSS         = 'BlackOnWhite_screen.css'
[parm]:linkToCSS         = 0
[parm]:saveHTML          = 0


MarkAPL Styles
==============

Overview
--------

MarkAPL comes with two sets of style sheets:

* MarkAPL_screen.css and MarkAPL_print.css
* BlackOnWhite_screen.css and BlackOnWhite_print.css

Both sets include the necessary style definitions for the LeanPub extensions.

The screen style sheet contains over 800 lines, while the print style sheet contains over 300 lines. The difference arises from the inclusion of CSS from the "Normalize" project[^normalyze] in the screen definition, ensuring consistent appearance across browsers.

When embedding style definitions into the HTML, comments and white spaces are removed, resulting in two lines for each style sheet. Combined, both style definitions occupy less than 12KB.


Replace the MarkAPL style sheets
--------------------------------

You have two options for using your own style sheets:

* Copy one of the provided style sheet sets and make necessary changes.
* Create a new style sheet, add changes, and define both screenCSS and printCSS using comma-separated text vectors. Ensure your style sheet is defined last to resolve conflicts.

For a completely different layout, choose the first option. For amendments or additions, use the second option.


Suggestions for developing a new style sheet
------------------------------------------------

### General suggestions

While you can use a media query for all media types in one CSS file, separate files for "print" and "screen" are recommended for easier debugging. 

To test changes, open your HTML document with the required parameters:

I> MarkAPL's own reference (MarkAPL.html) is a good choice for this because it takes advantage of all features of MarkAPL, therefore missing or ill-defined styles will quickly become apparent.
I>
I> Just ensure that you save it with linked CSS files rather than embedding the CSS.

Set the following parameters in the first lines of the HTML document you want to use for the development:

~~~
[parm]:linkToCSS    = 1
[parm]:screenCSS    = '/pathToMyStyleSheetFolder/MySyles_screen.css'
[parm]:printCSS     = '/pathToMyStyleSheetFolder/MySyles_print.css'
~~~

Note that `cssURL` is not defined and there for empty because that's the default.

You can achieve the same _with_ `cssURL`:
~~~
[parm]:linkToCSS    = 1
[parm]:cssURL       = 'file:///pathToMyStyleSheetFolder'
[parm]:screenCSS    = 'MySyles_screen.css'
[parm]:printCSS     = 'MySyles_print.css'
~~~

Don't forget that all `[parm]` lines must be defined at the top of the document in order to be recognized as a parameter definition, although any lines starting with an APL lamp symbol (`⍝`) do not count.

When you now make changes to the CSS file then --- after pressing F5 --- the changes are reflected in the "Preview" area of Meddy, Microsoft's WebBrowser control --- which is used for the Preview --- but it does not offer access to the developer tools available in all modern browsers. To get around this follow these steps:

1. Select "View HTML in default browser" from Meddy's "Edit" menu.
1. Fire up your favourite CSS editor and start changing the CSS file. 
1. Force the browser to reflect your changes by pressing F5 (Refresh) when appropriate.

All modern browsers will give you access to their development tools, usually invoked via F12 or with a right-click on a particular area on the screen and then selecting "Inspect" or something similar. That gives you invaluable support when something does not work as you expect it to.

### "Print" style sheets

In case something is not going to your liking the development tools all modern browsers come with are of great help. When it comes to printing however they are pretty useless: even Chrome, the only browser which offers a "Print Preview", does not allow you to invoke them on the print preview, at least not in a useful way.

Having two different files for the CSS allows using the print style sheet to temporarily for display purposes (screen) as shown here:

~~~
[parm]:linkToCSS
leanpub-start-insert
[parm]:screenCSS='/pathToMyStyleSheetFolder/print.css'
leanpub-end-insert
[parm]:printCSS='/pathToMyStyleSheetFolder/print.css'
~~~

Now you can check the impact of your print style sheet, and you can also take advantage of the browser's development tools.


Styling
-------

There are a few <div>s injected into the HTML and CSS classes assigned to HTML tags which are not really necessary but make styling their contents much easier.

Some HTML tags get class names or IDs assigned.

There are also some CSS classes available that can be used for common tasks by simply assigning them as special attributes in your Markdown.

### <div>s injected into the HTML by MarkAPL

All <div>s that are injected into the HTML by MarkAPL get either a class names or an ID name assigned -- that's the whole purpose of those <div>s: being able to style them or any decendent.

#### Footnotes

| ID names                |
|-------------------------|
|div#external_link_report |   
|div#footnotes_div        |

* All external (=non-bookmark) links in a document are printed at the end of the document --- but above any footnotes --- as a list under the header "Link report". They are embraced by a <div> with the class `external_link_report`.

* Footnotes go to the very end of a dcoument. They are embraced by a <div> with the class `footnotes_div`.

#### Link report

If `reportLinks` is 1 all links are listed at the very end of the document (but before any footnotes) with their URLs and link text. These are embraced by a single <div> with the ID "external_link_collection". 

MarkAPL's own style sheet sets both style the contents of those <div>s, but you might have different ideas.

### Class names and IDs assigned by MarkAPL

There are a few HTML elements that get a class name assigned by **_MarkAPL_** in order to make styling them easy:

* All footnote links in the document get the class "footnote_link" assigned . 
  These are the links pointing to the list of footnotes at the very end of the document.
* All footnote anchors get the class "footnote_anchor" assigned. 
  These anchors are positioned at the very end of the document.
* All anchors automatically injected around headers get the class name "autoheader_anchor" assigned.
* All bookmark links created by the user via the `[header](#)` syntax get a 
  class name "bookmark_link" assigned.
* All external links get the class name "external_link" assigned.
* All "mailto" links get the class name "mailto_link" assigned.
* If `toc` is 1 then MarkAPL injects a table-of-contents into the HTML. The toc is embraced by a <nav> tag which, in order to make it styleable, gets the id "main_nav" assigned when `collapsibleTOC` is 1 and `main_nav_no_collapse` otherwise.

Naturally you must not use these class names for different purposes when defining your own CSS.


### CSS styles available for assigning as special attributes

| Class name           | Domain | Meaning                                                 |
|----------------------|--------|---------------------------------------------------------|
| `.center`            | both   | Centers text                                            |
| `.left`              | both   | Aligns text to the left                                 |
| `.right`             | both   | Aligns text to the right                                |
| `.no_display`        | screen | Prevent the element from showing. It will print however |
| `.no_print`          | print  | Prevent the element from printing. It will show however |
| `.avoid_page_break`  | print  | Avoid page breaks if possible                           | 
| `.page_break_before` | print  | Enforce a page break before the current tag             | 
| `.red`               | both   | Sets "colour" to "red"                                  |

The "Domain" column explains in which style sheet a class is defined.

I> Why do tables not avoid page breaks by default? Because it could well be that as a result very little would go onto the page where the table would start without avoiding page breaks, something that would be particularly ridiculous in case the table needs to break anyway because of its size.
I>
I> It's therefore better to assign the class `avoid_page_break` when appropriate. That's far from perfect but then CSS is not for print.

### Examples

Let's assume that there is a table in your Markdown that should not show on screen but rather be 
printed without a page break and the table should be centered; this can be easily achieved:

~~~
| Language | Comment |{.no_display .avoid_page_break .center}
|----------|------------------|
| APL      | Excellent choice |
| COBOL    | Oh dear          |
~~~

This would do the trick. 

| Language | Comment          |{.avoid_page_break .center}
|----------|------------------|
| APL      | Excellent choice |
| COBOL    | Oh dear          |


| Language | Comment          |{.avoid_page_break .center}
|----------|:----------------:|
| APL      | Excellent choice |
| COBOL    | Oh dear          |

You cannot see the table on screen but when you select "View HTML in default browser" from Meddy's "Edit" menu (or just press F11) in order to view this page and then do a print preview (at the time of writing this is a Chrome-only feature) you will actually see this table making an appearance.

Note that assigning `.center` to the table is inherited by the table cells, there cell content is centered as well. If you do not want this you need to specify it per column. Watch out for the `:` in the row after the column headers:

~~~
| Language | Comment |{.no_display .avoid_page_break .center}
|:----------|:------------------|
| APL      | Excellent choice |
| COBOL    | Oh dear          |
~~~


## Assigned classes

There are classes assigned automatically to some tags. This is caused by the fact that there is no selector available to catch them.

### <p> in the first <dd> of a <dll>

There is no selector available at the time of writing (2018-02) that allows one to style the <p> in the first <dd> child of a <dl> (definition list).

For that reason the class "first_dd" is assigned.

Example:

~~~
<dl>
    <td>Foo</dt>
    <dd class="first_dd"><p>This</p></dd>
    <dd><p>This</p></dd>
</dl>
~~~

[^normalyze]:<https://necolas.github.io/normalize.css/>


