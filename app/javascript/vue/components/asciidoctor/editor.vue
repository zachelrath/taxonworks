<template>
  <div>
    <button
      type="button"
      @click="setPreview">Preview</button>
    <div class="asciidoctor-toolbar"/>
    <textarea v-model="test" ref="editor"/>
    <div ref="preview"/>
  </div>
</template>

<script>

import { AsciiDoctorEditor } from './asciidoctorEditor.js'
import { AsciiDoctorToolbar } from './toolbar.js'

export default {
  data () {
    return {
      options: {},
      asciidoctorEditor: undefined,
      toolbar: undefined,
      test: ''
    }
  },
  mounted () {
    this.asciidoctorEditor = new AsciiDoctorEditor(this.$refs.editor, {
      lineNumbers: true,
      lineWrapping: true,
      mode: 'asciidoc'
    })
    this.toolbar = new AsciiDoctorToolbar('.asciidoctor-toolbar', {
      editor: this.asciidoctorEditor
    })
  },
  methods: {
    setPreview () {
      this.$refs.preview.innerHTML = this.asciidoctorEditor.previewRender()
    }
  }
}
</script>
