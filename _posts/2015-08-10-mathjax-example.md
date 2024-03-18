---
title: "JekTeX Example"
date: 2015-08-10T08:08:50-04:00
---


Use `$$` as delimiters to enable TeX math mode, both for inline and display (i.e. block) rendering.

Here is an example equation that is inline: $$a^2 + b^2 = c^2$$, where
$$a$$, $$b$$, and $$c$$ are variables.

Here is a block rendering with no default equation numbering:

$$
\frac{1}{n^{2}}
$$

And, below is a block using the `\begin{equation}` and
`\end{equation}` LaTeX delimiters.  This equation will be numbered in
the `ams` and `all` setting for `mathjax.tags`.

$$
\begin{equation}
\mathbf{X}_{n,p} = \mathbf{A}_{n,k} \mathbf{B}_{k,p}
\end{equation}
$$


$$
\begin{align}
(x + y) (x - y) &= x^2 + xy - xy + y^2   \notag \\
    &= x^2 - y^2
\end{align}
$$
