<template>
  <div class="switch-radio">
    <template
      v-for="(item, index) in options.concat(addOption)">
      <template
        v-if="filter(item)">
        <input
          @click="emitEvent(item, index)"
          :value="useIndex ? index : item"
          :key="index"
          v-model="inputValue"
          :id="`switch-${name}-${index}`"
          :name="`switch-${name}-options`"
          type="radio"
          :checked="item === (useIndex ? index : value)"
          class="normal-input button-active"
        >
        <label
          :for="`switch-${name}-${index}`"
          :key="`${index}a`">{{ item }}
        </label>
      </template>
    </template>
  </div>
</template>
<script>
export default {
  props: {
    options: {
      type: Array,
      required: true
    },
    value: {
      type: [String, Number],
      default: undefined
    },
    addOption: {
      type: Array,
      required: false,
      default: () => {
        return []
      }
    },
    name: {
      type: String,
      required: false,
      default: () => { return Math.random().toString(36).substr(2, 5) }
    },
    filter: {
      type: Function,
      default: () => {
        return true
      }
    },
    useIndex: {
      type: Boolean,
      required: false
    }
  },
  computed: {
    inputValue: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  methods: {
    emitEvent (value, index) {
      this.$emit('index', index)
    }
  }
}

</script>
<style scoped>
  label::first-letter {
    text-transform: capitalize;
  }
</style>
