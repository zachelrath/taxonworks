<template>
  <div>
    <h2>{{ title }}</h2>
    <div>
      <p
        class="middle"
        v-if="data_attribute.controlled_vocabulary_term_id">
        <span class="margin-small-right">{{ ctvLabel[data_attribute.controlled_vocabulary_term_id] }}</span>
        <span
          class="button button-circle btn-undo button-default"
          @click="removeCTV"/>
      </p>
      <autocomplete
        v-else
        url="/controlled_vocabulary_terms/autocomplete"
        :add-params="{'type[]' : 'Predicate'}"
        label="label"
        min="2"
        placeholder="Select a predicate"
        :clear-after="true"
        @getItem="setCTV"
        class="margin-small-bottom"
        param="term"/>
      <div class="horizontal-left-content">
      <input
        type="text"
        placeholder="Value"
        class="full_width margin-small-right"
        v-model="data_attribute.value">
      <label class="inline">
        <input
          v-model="data_attribute.exact"
          type="checkbox">
        Exact
      </label>
      </div>
      <button
        :disabled="!data_attribute.controlled_vocabulary_term_id"
        type="button"
        class="button normal-input button-default margin-small-top"
        @click="addAttribute">Add
      </button>
    </div>
    <list-component
      :list="list"
      label="label"
      :delete-warning="false"
      @index="removeItem"
    />
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import ListComponent from 'components/displayList'

export default {
  components: {
    Autocomplete,
    ListComponent
  },
  props: {
    value: {
      type: Array,
      required: true
    },
    title: {
      type: String,
      default: 'By attribute'
    }
  },
  computed: {
    dataAttributes: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    list () {
      return this.dataAttributes.map(item => { return Object.assign({}, item, { label: this.ctvLabel[item.controlled_vocabulary_term_id] }) })
    }
  },
  data () {
    return {
      data_attribute: this.newAttribute(),
      ctvLabel: {}
    }
  },
  methods: {
    addAttribute () {
      this.dataAttributes.push(this.data_attribute)
      this.data_attribute = this.newAttribute()
    },
    newAttribute () {
      return {
        controlled_vocabulary_term_id: undefined,
        value: undefined,
        exact: false
      }
    },
    setCTV (ctv) {
      this.data_attribute.controlled_vocabulary_term_id = ctv.id
      this.$set(this.ctvLabel, ctv.id, ctv.label)
    },
    removeItem(index) {
      this.$delete(this.dataAttributes, index)
      this.$delete(this.ctvLabel, index)
    },
    removeCTV () {
      this.data_attribute.controlled_vocabulary_term_id = undefined
      this.$delete(this.ctvLabel, this.data_attribute.controlled_vocabulary_term_id)
    }
  }
}
</script>

<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>

