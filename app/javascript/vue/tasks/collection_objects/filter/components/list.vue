<template>
  <div
    v-if="Object.keys(list).length"
    class="full_width overflow-scroll">
    <table class="full_width">
      <thead>
        <tr>
          <th>
            <tag-all
              :ids="ids"
              type="CollectionObject"
              class="separate-right"/>
          </th>
          <th>Collection object</th>
          <template
            v-for="(item, index) in list.column_headers">
            <th
              v-if="index > 2"
              @click="sortTable(index)">{{item}}
            </th>
          </template>
        </tr>
      </thead>
      <tbody>
        <tr
          class="contextMenuCells"
          :class="{ even: indexR % 2 }"
          v-for="(row, indexR) in list.data"
          :key="row[0]">
          <td>
            <input
              v-model="ids"
              :value="row[0]"
              type="checkbox">
          </td>
          <td>
            <a
              :href="`/tasks/collection_objects/browse?collection_object_id=${row[0]}`"
              target="_blank">
              Show
            </a>
          </td>
          <template v-for="(item, index) in row">
            <td v-if="index > 2">
              <span>{{item}}</span>
            </td>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import TagAll from './tagAll'

export default {
  components: {
    TagAll
  },
  props: {
    list: {
      type: Object,
      default: undefined
    },
    value: {
      type: Array,
      default: []
    }
  },
  computed: {
    ids: {
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
      ascending: false
    }
  },
  methods: {
    sortTable (sortProperty) {
      let that = this
      function compare (a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (that.ascending ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (that.ascending ? 1 : -1)
        return 0
      }
      this.list.data.sort(compare)
      this.ascending = !this.ascending
    }
  }
}
</script>

<style lang="scss" scoped>
  table {
    margin-top: 0px;
  }
  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
  .overflow-scroll {
    overflow: scroll;
  }
</style>
