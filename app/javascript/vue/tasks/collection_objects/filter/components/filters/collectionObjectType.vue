<template>
  <div>
    <h2>Type</h2>
    <ul class="no_bullets">
      <li
        v-for="item in types"
        :key="item.id">
        <label>
          <input
            name="collection-object-type"
            type="radio"
            v-model="type"
            :value="item.value">
            {{ item.label }}
        </label>
      </li>
    </ul>
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
    type: {
      get () {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      types: [
        {
          label: 'All',
          value: undefined
        },
        {
          label: 'Specimen',
          value: 'Specimen'
        },
        {
          label: 'Lot',
          value: 'Lot'
        },
        {
          label: 'Ranged lot',
          value: 'RangedLot'
        }
      ]
    }
  }
}
</script>
