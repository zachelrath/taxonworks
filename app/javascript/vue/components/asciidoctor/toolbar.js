import 'codemirror-asciidoc'

class AsciiDoctorToolbar {

  #isMac = /Mac/.test(navigator.platform)

  #defaultOptions = {
    toolbar: [
      {
        name: 'italic',
        className: 'fa fa-italic',
        title: 'Italic',
        block: '_',
        default: true
      },
      {
        name: 'bold',
        className: 'fa fa-bold',
        title: 'Bold',
        default: true,
        block: '**'
      },
      {
        name: 'code',
        className: 'fa fa-code',
        title: 'Code',
        default: true,
        block: '```'
      }
    ]
  }

  constructor (element, options = {}) {
    this.options = Object.assign(this.#defaultOptions, options)
    this.that = this
    this.editor = options.editor

    this.loadFontIcons()
    this.element = typeof element === 'string' ? document.querySelector(element) : element
    this.createToolbar(this.options.toolbar)
  }

  loadFontIcons () {
    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'https://maxcdn.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css'
    document.getElementsByTagName('head')[0].appendChild(link)
  }

  fixShortcut (name) {
    if (this.#isMac) {
      name = name.replace('Ctrl', 'Cmd')
    } else {
      name = name.replace('Cmd', 'Ctrl')
    }
    return name
  }

  createToolbar (buttons) {
    buttons.forEach(button => {
      this.element.appendChild(this.createToolbarButton(button, 'button'))
    })
  }

  createToolbarButton (options, markup) {
    options = options || {}
    const el = document.createElement(markup)
    el.className = options.name
    el.setAttribute('type', markup)

    el.tabIndex = -1

    const icon = document.createElement('i')

    if (options.className) {
      options.className.split(' ').forEach(className => {
        icon.classList.add(className)
      })
    }

    el.appendChild(icon)

    if (typeof options.icon !== 'undefined') {
      el.innerHTML = options.icon
    }

    if (options.action) {
      if (typeof options.action === 'function') {
        el.onclick = (e) => {
          e.preventDefault()
          options.action(this)
        }
      } else if (typeof options.action === 'string') {
        el.onclick = function (e) {
          e.preventDefault()
          window.open(options.action, '_blank')
        }
      }
    } else {
      if (!options.hasOwnProperty('action')) {
        el.onclick = (e) => {
          e.preventDefault()
          this._toggleBlock(this.editor, '', options.block)
        }
      }
    }

    return el
  }

  createSep () {
    var el = document.createElement('i')
    el.className = 'separator'
    el.innerHTML = '|'
    return el
  }

  createTooltip (title, action, shortcuts) {
    var actionName
    var tooltip = title

    if (action) {
      actionName = this.getBindingName(action)
      if (shortcuts[actionName]) {
        tooltip += ' (' + this.fixShortcut(shortcuts[actionName]) + ')'
      }
    }

    return tooltip
  }

  _toggleBlock (editor, type, start_chars, end_chars) {
    if (/editor-preview-active/.test(editor.codemirror.getWrapperElement().lastChild.className)) { return }

    end_chars = (typeof end_chars === 'undefined') ? start_chars : end_chars
    var cm = editor.codemirror
    var stat = this.getState(cm)

    var text
    var start = start_chars
    var end = end_chars

    var startPoint = cm.getCursor('start')
    var endPoint = cm.getCursor('end')

    if (stat[type]) {
      text = cm.getLine(startPoint.line)
      start = text.slice(0, startPoint.ch)
      end = text.slice(startPoint.ch)
      if (type == 'bold') {
        start = start.replace(/(\*\*|__)(?![\s\S]*(\*\*|__))/, '')
        end = end.replace(/(\*\*|__)/, '')
      } else if (type == 'italic') {
        start = start.replace(/(\*|_)(?![\s\S]*(\*|_))/, '')
        end = end.replace(/(\*|_)/, '')
      } else if (type == 'strikethrough') {
        start = start.replace(/(\*\*|~~)(?![\s\S]*(\*\*|~~))/, '')
        end = end.replace(/(\*\*|~~)/, '')
      }
      cm.replaceRange(start + end, {
        line: startPoint.line,
        ch: 0
      }, {
        line: startPoint.line,
        ch: 99999999999999
      })

      if (type == 'bold' || type == 'strikethrough') {
        startPoint.ch -= 2
        if (startPoint !== endPoint) {
          endPoint.ch -= 2
        }
      } else if (type == 'italic') {
        startPoint.ch -= 1
        if (startPoint !== endPoint) {
          endPoint.ch -= 1
        }
      }
    } else {
      text = cm.getSelection()
      if (type == 'bold') {
        text = text.split('**').join('')
        text = text.split('__').join('')
      } else if (type == 'italic') {
        text = text.split('*').join('')
        text = text.split('_').join('')
      } else if (type == 'strikethrough') {
        text = text.split('~~').join('')
      }
      cm.replaceSelection(start + text + end)

      startPoint.ch += start_chars.length
      endPoint.ch = startPoint.ch + text.length
    }

    cm.setSelection(startPoint, endPoint)
    cm.focus()
  }

  getState (cm, pos) {
    pos = pos || cm.getCursor('start')
    var stat = cm.getTokenAt(pos)
    if (!stat.type) return {}

    var types = stat.type.split(' ')

    var ret = {}
    var data; var text
    for (var i = 0; i < types.length; i++) {
      data = types[i]
      if (data === 'strong') {
        ret.bold = true
      } else if (data === 'variable-2') {
        text = cm.getLine(pos.line)
        if (/^\s*\d+\.\s/.test(text)) {
          ret['ordered-list'] = true
        } else {
          ret['unordered-list'] = true
        }
      } else if (data === 'atom') {
        ret.quote = true
      } else if (data === 'em') {
        ret.italic = true
      } else if (data === 'quote') {
        ret.quote = true
      } else if (data === 'strikethrough') {
        ret.strikethrough = true
      } else if (data === 'comment') {
        ret.code = true
      } else if (data === 'link') {
        ret.link = true
      } else if (data === 'tag') {
        ret.image = true
      } else if (data.match(/^header(-[1-6])?$/)) {
        ret[data.replace('header', 'heading')] = true
      }
    }
    return ret
  }
}

export {
  AsciiDoctorToolbar
}
