<template>
  <div>
    <h2>Collectors</h2>
    <div>
      <label>Verbatim collectors</label>
      <input
        v-model="collectors.verbatim_collectors"
        type="text">
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      collectors: {
        verbatim_collectors
      }
    }
  }
}
</script>

<style>

</style>