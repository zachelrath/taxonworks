<template>
  <div>
    <h2>Curator metadata</h2>
    <input
      type="text"
      class="full_width"
      v-model="metadata">
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      default: undefined
    }
  },
  computed: {
    metadata: {
      get () {
        return this.value
      },
      set (value) {
        return this.$emit('input', value)
      }
    }
  }
}
</script>
