<template>
  <div>
    <h2>Date</h2>
    <div class="horizontal-left-content">
      <div class="field label-above margin-medium-right">
        <label>Start year</label>
        <input
          type="text"
          class="full_width"
          :maxlength="4"
          v-model="source.year_start">
      </div>
      <div class="field label-above">
        <label>End year</label>
        <input
          type="text"
          :maxlength="4"
          class="full_width"
          v-model="source.year_end">
      </div>
    </div>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    source: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      authors: []
    }
  },
  watch: {
    authors: {
      handler (newVal) {
        this.source.author_ids = this.authors.map(author => { return author.id })
      },
      deep: true
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    this.source.year_start = urlParams.year_start
    this.source.year_end = urlParams.year_end
  },
  methods: {
    addAuthor (author) {
      this.authors.push(author)
    }
  }
}
</script>
