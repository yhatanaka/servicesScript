# Your HyperMD editor is here

| 氏名 | 地域 |
| ------- | ------- |
| 畠中   |遊佐   |
| 五十嵐  |飛島   |

Maybe you prefer the hard ~~core~~ code way, want to import all libraries manually 🤘.

No problem! HyperMD provides ai1 (all-in-one) single-file bundle :gift:!

**Check-out this page's source code.** It just imports all the stuff, without any trick!

-------------------

All built-in features are ready-to-go. You may manipulate the editor via `cm` or `HyperMD` global variables. Try out:

1. `HyperMD.switchToNormal(cm)`
2. `HyperMD.switchToHyperMD(cm)`
3. `cm.getValue()` returns the Markdown source text

> Note: This is a very basic example, therefore some features that rely on your implementation, like MathPreview, are unavaliable.
> Please read related documentation pages and implement them, if you need.

**Note**: This demo is using these powerpacks and 3rd-party libs and services. Special thanks to them!

1. **fold-math-with-mathjax** uses _MathJax_ the TeX formular renderer.
2. **hover-with-marked** uses _marked_ to render tooltip content.
3. **paste-with-turndown** uses _turndown_ to convert HTML from clipboard to markdown text.
4. **insert-file-with-smms** uses https://sm.ms/ the free image hosting service.
5. **fold-emoji-with-emojione** uses EmojiOne, and Emoji icons provided free by [EmojiOne](https://www.emojione.com/)


[hypermd-doc]: https://laobubu.net/HyperMD/docs/ HyperMD documentation
[cm-manual]: https://codemirror.net/doc/manual.html CodeMirror User manual

