<template>
  <div>
    <h2>OTUs</h2>
    <ul class="no_bullets">
      <li
        v-for="option in options">
        <label>
          <input
            :value="option.value"
            v-model="optionValue"
            type="radio">
          {{ option.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      default: undefined
    }
  },
  computed: {
    optionValue: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  data() {
    return {
      options: [
        {
          label: 'With/out OTU',
          value: undefined
        },
        { 
          label: 'With OTUs',
          value: true
        },
        { 
          label: 'Without OTU',
          value: false
        }
      ]
    }
  },
  mounted () {
    this.optionValue = URLParamsToJSON(location.href).otus
  }
}
</script>