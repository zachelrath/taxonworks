import CodeMirror from 'codemirror'
import 'codemirror-asciidoc'
import Asciidoctor from 'asciidoctor'

class AsciiDoctorEditor {
  constructor (element, options = {}) {
    this.asciidoctor = new Asciidoctor()
    this.codemirror = CodeMirror.fromTextArea(element, {
      lineNumbers: true,
      lineWrapping: true,
      mode: 'asciidoc'
    })
  }

  previewRender () {
    return this.asciidoctor.convert(this.codemirror.getDoc().getValue())
  }

  undo (editor) {
    var cm = editor.codemirror
    cm.undo()
    cm.focus()
  }

  redo (editor) {
    var cm = editor.codemirror
    cm.redo()
    cm.focus()
  }

  getEditor () {
    return this.codemirror
  }

  setCustomLink (item) {
    var cm = this.simplemde.codemirror
    var output = ''
    var selectedText = cm.getSelection()
    var text = selectedText || item.label

    output = `${item.link}[${text}]`
    cm.replaceSelection(output)
  }

  drawLink (editor) {
    var cm = editor.codemirror
    var stat = getState(cm)
    var options = editor.options
    var url = 'https://'
    if (options.promptURLs) {
      url = prompt(options.promptTexts.link, 'https://')
      if (!url) {
        return false
      }
    }
    _replaceSelection(cm, stat.link, options.insertTexts.link, url)
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
  AsciiDoctorEditor
}
