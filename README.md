# Ketch's personal Nvimconf

Tired to open many files when change my config, so written all config in init.lua

Run setup.sh to install and update Language Server Protocol and Language Provider. On MacOS, I use clangd as LSP for c and cpp, which is included in Xcode-CommandLine-Tools, so need to run `xcode-select --install` to install it manually.

Autoswitchim require ['macism'](https://github.com/laishulu/macism)(on Mac for Squirrel) [`im-select`](https://github.com/daipeihust/im-select)(for Linux)

Two dictionaries(one for English, another for Deutsch) include in `dict` to support words completion.

---

_italic_
**_bold italic_**

## Title

### Title

#### Title

##### Title

- [ ] Deutsch lernen

```python
print("hello, world")

```

<zengkeqi1999@163.com>

- first
- second
- third

<u>underline text </u>

$$
\alpha + \beta
$$

$a+b=c$

![figure](../../Pictures/feedback.jpeg)

[Text1][1] will link to the first link, and [Text2][2] to the second.
You [can reuse][1] names, and give longer names [like this one][a link].
You can also link text [like this] without giving the reference an explicit name.

[1]: http://www.google.com
[2]: http://stackoverflow.com/
[a link]: http://example.org/
[like this]: http://stackexchange.com/
