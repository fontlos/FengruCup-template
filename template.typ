// 伪加粗, 支持正则表达式, 可自选字重
#let bold(reg: ".", base-weight: none, body) = {
    show regex(reg): it => {
        set text(stroke: 0.02857em)
        set text(weight: base-weight) if base-weight != none
        it
    }
    body
}

// 针对中文的伪加粗
#let bold-cn(s) = {
    bold(reg: "[\p{script=Han} ！-･〇-〰—]", base-weight: "regular", s)
}

// Show 全局加粗规则
#let bold-rule(reg: ".", base-weight: none, body) = {
    show text.where(weight: "bold").or(strong): it => {
        bold(reg: reg, base-weight: base-weight, it)
    }
    body
}

// 针对中文的 Show 全局加粗规则
#let bold-cn-rule(s) = {
    bold-rule(reg: "[\p{script=Han} ！-･〇-〰—]", base-weight: "regular", s)
}

// https://github.com/typst/typst/issues/2749
#let _skew(angle, vscale: 1, body) = {
    let (a, b, c, d) = (1, vscale * calc.tan(angle), 0, vscale)
    let E = (a + d) / 2
    let F = (a - d) / 2
    let G = (b + c) / 2
    let H = (c - b) / 2
    let Q = calc.sqrt(E * E + H * H)
    let R = calc.sqrt(F * F + G * G)
    let sx = Q + R
    let sy = Q - R
    let a1 = calc.atan2(F, G)
    let a2 = calc.atan2(E, H)
    let theta = (a2 - a1) / 2
    let phi = (a2 + a1) / 2
    set rotate(origin: bottom + center)
    set scale(origin: bottom + center)
    box(rotate(phi, scale(x: sx * 100%, y: sy * 100%, rotate(theta, body))))
}

// 伪斜体, 支持正则表达式, 考虑到斜体后可能与后面的字重叠, 可自行设置间距
#let italic(reg: "[^ ]", ang: -0.32175, spacing: none, body) = {
    show regex(reg): _skew.with(ang)
    body
    if spacing != none {h(spacing)}
}

// Show 全局斜体规则
#let italic_rule(reg: "[^ ]", ang: -0.32175, spacing: none, body) = {
    show text.where(style: "italic").or(emph): it => {
        italic(reg: reg, ang: ang, spacing: spacing, it)
    }
    body
}

#let frb(
    title: none,
    subtitle: none,
    header: none,
    author: "Fontlos",
    abstract-CN: none,
    keyword-CN: none,
    abstract-EN: none,
    keyword-EN: none,
    bibliography-file: none,
    bibliography-title: "参考文献",
    bibliography-style: "gb-7714-2015-numeric",
    auto-num-title: true,
    body
) = {
    // 设置文档基本内容
    set document(author: (author, ), title: title)
    // 设置页边距
    set page(
        margin: (
            top: 2.5cm,
            bottom: 2.5cm,
            left: 3cm,
            right: 2cm,
        )
    )
    // 设置正文, 公式与代码块字体
    set text(font: ("Times New Roman" ,"SimSun"), size: 12pt)
    show math.equation: set text(font: "New Computer Modern Math", weight: 400)
    show raw : set text(font: ("DejaVu Sans Mono", "SimSun"), weight: 400, size: 9pt)

    // 代码块背景
    show raw.where(block: false): box.with(
        fill: luma(240),
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2pt,
    )
    show raw.where(block: true): block.with(
        fill: luma(240),
        inset: 10pt,
        radius: 4pt,
    )

    // 设置封面
    v(0.3em)
    align(left, image("svg/logo.svg", width: 20%))
    v(3.5em)
    align(center, image("svg/name.svg", width: 80%))
    v(4em)
    align(center, text(22pt, title, stroke: 0.06em))
    v(2em)
    if subtitle != none{
        let subtitle = "——" + subtitle
        align(right, text(16pt, subtitle, font:("Times New Roman", "STXinwei")))
    }

    // 设置摘要与目录页页码
    set page(
        // 设置页码
        numbering: "i",
        number-align: center,
    )
    pagebreak()
    counter(page).update(1)
    set par(
        leading: 1em,
        first-line-indent: 2em,
    )

    // 摘要, 关键字与目录
    if abstract-CN != none and keyword-CN != none {
        align(center, text(16pt, font: "SimHei")[摘要])
        [
            #abstract-CN

            #text(font: "SimHei", "关键词：")
            #keyword-CN
        ]
        pagebreak()
    }
    if abstract-EN != none and keyword-EN != none {
        align(center, text(16pt, weight: "bold")[Abstract])
        [
            #abstract-EN

            *Keywords: *
            #strong(keyword-EN)
        ]
        pagebreak()
    }

    // 目录设置
    show outline.entry: it => {
        it
        v(0.5em, weak: true)
    }
    set par(
        first-line-indent: 0em,
    )
    align(center, text(16pt, font: "SimHei")[目录])
    outline(
        title: none,
        depth: 3,
        indent: 2em,
        fill: box(width: 1fr, repeat[.#h(0.5em)])
    )

    // 设置正文页页码与页眉
    set page(
        numbering: "1",
        number-align: center,
        header-ascent: 14pt,
        header: {
            set text(size: 9pt, font: "STSong")
            align(center, header)
            v(-2em)
            line(start:(0%,25%),end:(100%,25%),length:100%,stroke: 0.5pt)
        },
    )
    pagebreak()
    counter(page).update(1)

    // 主体
    // 设置段间距
    show par: set block(above: 1.5em, below: 1.5em)
    // 插入空行以辅助首行缩进
    show heading: it => {
        v(2em, weak: true)
        it;
        v(0em, weak: true)
        h(0em)
    }
    show list: it => {
        it;
        v(0em, weak: true)
        h(0em)
    }
    show enum: it => {
        it;
        text()[#v(0em, weak: true)];
        text()[#h(0em)]
    }
    show table: it => {
        it;
        text()[#v(0.3em, weak: true)];
        text()[#h(0em)]
    }
    show math.equation: it => {
        it;
        // text()[#v(0.3em, weak: true)];
        text()[#h(0em)]
    }
    show raw: it => {
        it;
        // text()[#v(0.3em, weak: true)];
        text()[#h(0em)]
    }
    set par(
        leading: 1em,
        first-line-indent: 2em,
    )

    // 标题大小
    show heading.where(level:1): it =>{
        set text(size: 16pt, font:("Times New Roman", "SimHei"))
        align(center, it)
    }
    show heading.where(level:2): it =>{
        set text(size: 14pt, font:("Times New Roman", "SimHei"))
        it
    }
    show heading.where(level:3): it =>{
        set text(size: 12pt, font:("Times New Roman", "SimHei"))
        it
    }

    // 是否开启自动标号
    if auto-num-title != none {
        set heading(numbering: (..nums) => {
            if nums.pos().len()==1 {
                numbering("一、", nums.pos().at(0))
            } else if nums.pos().len()==2 {
                numbering("(一) ", nums.pos().at(1))
            } else if nums.pos().len()==3 {
                numbering("1.", nums.pos().at(2))
            }
        })
        body
    } else {
        body
    }

    // 结尾参考文献
    if bibliography-file != none {
        pagebreak()
        bibliography(bibliography-file, title: bibliography-title, style: bibliography-style)
    }
}

#let img(
    path: none,
    width: 80%,
    num: none,
    body
) = {
    figure(
        image(path, width: width),
        caption: [#bold(body)],
        numbering: num
    )
    text()[#v(0.3em, weak: true)];
    text()[#h(0em)]
}