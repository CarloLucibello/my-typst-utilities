// Demo of annot.typ.
//   typst compile demo.typ                        (draft)
//   typst compile --input annot=clean demo.typ
//   typst compile --input annot=final demo.typ    (fails: annotations remain)

#import "annot.typ": *

#set page(paper: "a4", margin: 25mm, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#show: annot-setup

= Annotations for collaborative drafting

Every annotation takes an optional `by:` with the author's
initials#note(by: "CL")[Signed.], and without it the annotation is
unsigned#note[No `by:` here.]. Margin comments come in four kinds: a
task#todo(by: "CL")[Add a reference.], a question#ask(by: "AB")[Why the factor
2?], a claim to verify#check(by: "CL")[Rerun the benchmark.] and a plain
remark#note(by: "AB")[Nice.]. A comment can also be attached to a span:
#ask(by: "CL")[the cost grows as $O(n log n)$][Same as in Table 1?] is
highlighted and numbered. A comment too long for the margin can stay in the
text flow#note(by: "AB", inline: true)[Kept inline with `inline: true`: it
breaks across lines like ordinary text and shifts the layout.] instead.

Suggested edits read like tracked changes: the method #del(by: "CL")[very]
quickly #repl(by: "AB")[gives][yields] the #ins[exact] solution
#repl[$x = A^(-1) b$][$x = A^+ b$], also inside math:
$f(x) = x^2 #ins[$+ c x$] #del[$+ O(x^3)$]$. The clean PDF shows the
accepted text.

== A section still to be written

#brief(by: "CL")[One paragraph, about 150 words. Motivate the problem with a
  concrete example; mention the two standard approaches and why neither applies
  here. No equations.]

#lorem(250)

Crowded margins: comments are stacked below each other#todo[One.]#todo[Two.]#todo[Three
  is a longer comment that needs several lines in the narrow margin.]#todo[Four.]#todo[Five.]#todo[Six.]#todo[Seven.]#todo[Eight.]#todo[Nine.]#todo[Ten.]#todo[Eleven.]
and continue in the left margin when they would run past the bottom of the text area.
