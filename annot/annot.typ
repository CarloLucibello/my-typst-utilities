// Annotations for drafting and editing documents together: comments, briefs and suggested edits.
// Vendored from https://github.com/CarloLucibello/my-typst-utilities: copy it unchanged.
//
//   #import "annot.typ": *
//   #show: annot-setup                  // before the template's show rule
//
// Margin comments (optional `by:` = author initials; `inline: true` keeps a long
// comment in the text flow):
//   #todo[...]  #ask[...]  #check[...]  #note[...]
//   #ask[span][question]                comment on a highlighted span
// Inside an equation, give the annotated part its own `$...$`: $a #del[$+ b$]$
// Drafting instructions:   #brief[what this section should say]
// Suggested edits:         #del[old]  #ins[new]  #repl[old][new]
// Typst swallows a `;` right after `#todo[...]`: put annotations after a semicolon, or write `\;`.
//
// Modes: typst compile --input annot=draft|clean|final
//   draft  annotations visible (default)
//   clean  accepted text only
//   final  clean, and the build fails while any annotation remains

#let _colors = (
  todo: rgb("#c05621"),
  ask: rgb("#2b6cb0"),
  check: rgb("#c53030"),
  note: rgb("#5a6473"),
  brief: rgb("#6b46c1"),
  del: rgb("#c53030"),
  ins: rgb("#2f855a"),
  repl: rgb("#2f855a"),
)
#let _font = ("Noto Sans", "DejaVu Sans")
#let _gap = 3mm
#let _mode-default = sys.inputs.at("annot", default: "draft")
#let _mode = state("annot-mode", _mode-default)
#let _counter = counter("annot")
// An outline repeats heading bodies: there annotations show their accepted text, unnumbered.
#let _in-outline = state("annot-in-outline", false)
#let _mode-here() = if _in-outline.get() { "clean" } else { _mode.get() }

#let _plain(it) = {
  if type(it) == str { it } else if type(it) != content { "" } else if it.has("text") {
    _plain(it.text)
  } else if it == [ ] { " " } else if it.has("children") {
    it.children.map(_plain).join(default: "")
  } else { it.fields().values().map(_plain).join(default: "") }
}

#let _meta(kind, by, body, margin: false) = [#metadata((
    kind: kind,
    by: by,
    body: body,
    text: _plain(body),
    margin: margin,
  ))<annot>]

#let _tag(c, s, size: 5.5pt) = box(move(dy: -0.45em, text(
  font: _font,
  size: size,
  weight: "bold",
  fill: c,
  s,
)))

// highlight, strike and underline skip math, so it gets a box instead. A lone
// `[$...$]` is boxed directly: inside an equation the show rule never fires.
#let _decorate(x, deco, mark) = {
  if type(x) == content and x.func() == math.equation { return mark(x) }
  show math.equation.where(block: false): mark
  deco(x)
}
// One band height for every font (raw text) and for math; needs context.
#let _band(fill, scale: 1) = {
  let (top, bottom) = ((scale * 0.92em).to-absolute(), (scale * 0.28em).to-absolute())
  let mark(it) = context {
    let w = measure(it).width
    box({
      box(width: w, height: 0pt, place(dy: -top, rect(width: w, height: top + bottom, fill: fill, stroke: none)))
      h(-w)
      it
    })
  }
  (highlight.with(fill: fill, top-edge: top, bottom-edge: -bottom), mark)
}
#let _highlighted(fill, x) = _decorate(x, .._band(fill))
#let _struck(x) = {
  let s = 0.7pt + _colors.del
  let mark(it) = context box(it + place(horizon + left, line(length: measure(it).width, stroke: s)))
  text(fill: _colors.del, _decorate(x, strike.with(stroke: s), mark))
}
#let _added(x) = {
  let s = 0.6pt + _colors.ins
  let mark = box.with(stroke: (bottom: s), outset: (bottom: 3pt))
  text(fill: _colors.ins, _decorate(x, underline.with(stroke: s, offset: 1.5pt), mark))
}

#let _header(kind, by, num) = {
  text(fill: _colors.at(kind), weight: "bold")[#num #upper(kind)]
  if by != none [ · #by]
}

#let _note-box(kind, by, num, body, width) = block(
  width: width,
  fill: _colors.at(kind).lighten(90%),
  stroke: (left: 1.2pt + _colors.at(kind)),
  inset: (left: 2pt, right: 1.5pt, y: 1.8pt),
  breakable: false,
  {
    set text(font: _font, size: 6pt, fill: black, hyphenate: true, style: "normal", weight: "regular")
    set par(justify: false, leading: 0.35em, spacing: 0.45em, first-line-indent: 0pt, hanging-indent: 0pt)
    _header(kind, by, num)
    linebreak()
    body
  },
)

#let _margin(kind, by, inline, args) = {
  assert(args.named().len() == 0, message: "annot: unexpected argument " + repr(args.named()))
  let pos = args.pos()
  assert(pos.len() in (1, 2), message: "annot: #" + kind + " takes [comment] or [span][comment]")
  let (span, body) = if pos.len() == 2 { pos } else { (none, pos.first()) }
  let c = _colors.at(kind)
  context {
    let mode = _mode-here()
    if mode == "draft" {
      if span != none { _highlighted(c.lighten(80%), span) }
      _counter.step()
      _meta(kind, by, body, margin: not inline)
      let num = context _counter.display()
      if inline {
        [ ]
        _band(c.lighten(88%), scale: 0.8).first()(text(font: _font, size: 0.8em, {
          _header(kind, by, num)
          [ ]
          body
        }))
      } else { h(0.1em) + _tag(c, num) }
    } else {
      span
      if mode == "final" { _meta(kind, by, body) }
    }
  }
}

#let todo(by: none, inline: false, ..args) = _margin("todo", by, inline, args)
#let ask(by: none, inline: false, ..args) = _margin("ask", by, inline, args)
#let check(by: none, inline: false, ..args) = _margin("check", by, inline, args)
#let note(by: none, inline: false, ..args) = _margin("note", by, inline, args)

#let brief(by: none, body) = context {
  let mode = _mode-here()
  let c = _colors.brief
  if mode == "draft" {
    block(
      width: 100%,
      fill: c.lighten(95%),
      stroke: (paint: c, thickness: 0.8pt, dash: "dashed"),
      inset: 6pt,
      radius: 2pt,
      {
        set text(font: _font, size: 8.5pt, fill: black, style: "normal", weight: "regular")
        set par(justify: false, first-line-indent: 0pt, spacing: 0.6em)
        text(fill: c, weight: "bold")[BRIEF]
        if by != none [ · #by]
        _meta("brief", by, body)
        parbreak()
        body
      },
    )
  } else if mode == "final" { _meta("brief", by, body) }
}

#let _edit(kind, by, draft, accepted, body) = context {
  let mode = _mode-here()
  if mode == "draft" {
    draft
    if by != none { _tag(_colors.at(kind), by, size: 5pt) }
    _meta(kind, by, body)
  } else {
    accepted
    if mode == "final" { _meta(kind, by, body) }
  }
}

#let del(by: none, body) = _edit("del", by, _struck(body), none, body)
#let ins(by: none, body) = _edit("ins", by, _added(body), body, body)
#let repl(by: none, old, new) = _edit(
  "repl",
  by,
  _struck(old) + h(0.2em) + _added(new),
  new,
  [#old → #new],
)

#let _length(x, fallback) = if type(x) == length { x.to-absolute() } else { fallback }

#let _foreground = context {
  let all = query(<annot>)
  if all.len() == 0 { return }
  let pg = here().page()
  let m = page.margin
  let fixed-height = type(page.height) == length
  let auto-margin = 2.5 / 21 * if fixed-height { calc.min(page.width, page.height) } else { page.width }
  let side(k, alt) = if type(m) == dictionary { _length(m.at(k, default: m.at(alt, default: auto)), auto-margin) } else {
    _length(m, auto-margin)
  }
  let (ml, mr, mt, mb) = (side("left", "x"), side("right", "x"), side("top", "y"), side("bottom", "y"))
  let bottom = if fixed-height { page.height - mb } else { 1e5pt }
  let columns = (
    (x: page.width - mr + _gap, width: mr - 2 * _gap, y: 0pt),
    (x: _gap, width: ml - 2 * _gap, y: 0pt),
  )

  place(top + right, dx: -mr, dy: mt / 2, text(font: _font, size: 6.5pt, fill: luma(130))[
    DRAFT · #all.len() annotation#if all.len() > 1 [s] · #datetime.today().display("[day] [month repr:short] [year]")
  ])

  let notes = all.filter(n => n.value.margin and n.location().page() == pg)
  for n in notes.sorted(key: n => n.location().position().y) {
    let v = n.value
    let num = _counter.at(n.location()).first()
    let y0 = n.location().position().y - (0.6em).to-absolute()
    for (i, col) in columns.enumerate() {
      let b = _note-box(v.kind, v.by, num, v.body, col.width)
      let y = calc.max(y0, col.y)
      let h = measure(b).height
      if y + h <= bottom or i == columns.len() - 1 {
        place(top + left, dx: col.x, dy: y, b)
        columns.at(i).y = y + h + 1.5pt
        break
      }
    }
  }
}

#let _gate = context {
  let left = query(<annot>)
  let snippet(s) = if s.clusters().len() > 50 { s.clusters().slice(0, 50).join() + "…" } else { s }
  let items = left.map(n => n.value.kind + " (p. " + str(n.location().page()) + "): " + snippet(n.value.text))
  assert(left.len() == 0, message: "annot: " + str(left.len()) + " annotation(s) remain\n  " + items.join("\n  "))
}

#let annot-setup(mode: "draft", body) = {
  let mode = sys.inputs.at("annot", default: mode)
  assert(mode in ("draft", "clean", "final"), message: "annot: mode must be draft, clean or final, got " + repr(mode))
  if mode != _mode-default { _mode.update(mode) }
  show outline: it => _in-outline.update(true) + it + _in-outline.update(false)
  if mode == "draft" {
    set page(foreground: _foreground)
    body
  } else {
    body
    if mode == "final" { _gate }
  }
}
