<template>
  <div>
    <h2>Style</h2>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.value">
        <label
          @click="onSelectedStyle(item.value)">
          <input
            :checked="value == item.value"
            type="radio"
            name="style-selector">
          {{ item.label }}
        </label>
      </li>
    </ul>
    <div
      v-show="value == 'custom_style'"
      class="separate-top">
      <custom-style @onNewStyle="$emit('onNewStyle', $event)"/>
    </div>
  </div>
</template>

<script>

import CustomStyle from './customStyle'

export default {
  components: {
    CustomStyle
  },
  props: {
    value: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      list: [{
        label: '4pt Insect (TAMU style)',
        value: 'ce_lbl_insect_compressed'
      },
      {
        label: '4pt Insect (NCSU style, uncompressed)',
        value: 'ce_lbl_insect'
      },
      {
        label: '4 dram Alchohol vial',
        value: 'ce_lbl_4_dram_ETOH'
      },
      {
        label: 'Custom style',
        value: 'custom_style'
      }]
    }
  },
  methods: {
    onSelectedStyle(value) {
      this.$emit('input', value)
    }
  }
}
</script>
