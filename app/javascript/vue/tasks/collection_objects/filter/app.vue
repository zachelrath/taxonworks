<template>
  <div>
    <div class="flex-separate middle">
      <h1>Collection objects filter</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter">
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJSONRequest">
            Show JSON Request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="append">
            Append results
          </label>
        </li>
      </ul>
    </div>
    <div
      v-show="activeJSONRequest"
      class="panel content separate-bottom">
      <div class="flex-separate middle">
        <span>
          JSON Request: {{ urlRequest }}
        </span>
      </div>
    </div>

    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        ref="filterComponent"
        v-show="activeFilter"
        @urlRequest="urlRequest = $event"
        @result="loadList"
        @pagination="pagination = getPagination($event)"
        @reset="resetTask"/>
      <div class="full_width">
        <div 
          v-if="recordsFound"
          class="horizontal-left-content flex-separate separate-left separate-bottom">
          <div class="horizontal-left-content">
            <csv-button
              :url="urlRequest"
              :options="{ fields: csvFields }"/>
            <span class="separate-left separate-right">|</span>
            <button
              v-if="ids.length"
              type="button"
              @click="ids = []"
              class="button normal-input button-default">
              Unselect all
            </button>
            <button
              v-else
              type="button"
              @click="ids = coIds"
              class="button normal-input button-default">
              Select all
            </button>
          </div>
        </div>
        <div
          class="flex-separate margin-medium-bottom"
          v-if="pagination">
          <pagination-component
            v-if="pagination"
            @nextPage="loadPage"
            :pagination="pagination"/>
          <div class="horizontal-left-content">
            <span
              v-if="list.data.length"
              class="horizontal-left-content">{{ list.data.length }} records.
            </span>
            <div class="margin-small-left">
              <select v-model="per">
                <option
                  v-for="records in maxRecords"
                  :key="records"
                  :value="records">
                  {{ records }}
                </option>
              </select>
              records per page.
            </div>
          </div>
        </div>
        <list-component
          v-model="ids"
          :class="{ 'separate-left': activeFilter }"
          :list="list"/>
        <h2
          v-if="alreadySearch && !list"
          class="subtle middle horizontal-center-content no-found-message">No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from './components/csvDownload'
import PaginationComponent from 'components/pagination'
import GetPagination from 'helpers/getPagination'

export default {
  components: {
    PaginationComponent,
    FilterComponent,
    ListComponent,
    CsvButton
  },
  computed: {
    csvFields () {
      if (!Object.keys(this.list).length) return []
      return this.list.column_headers.map((item, index) => {
        return {
          label: item,
          value: (row, field) => row[index] || field.default,
          default: ''
        }
      })
    },
    coIds () {
      return Object.keys(this.list).length ? this.list.data.map(item => { return item[0] }) : []
    },
    recordsFound() {
      return Object.keys(this.list).length && this.list.data.length
    }
  },
  data () {
    return {
      list: {},
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
      ids: [],
      pagination: undefined,
      maxRecords: [50, 100, 250, 500, 1000],
      per: 500
    }
  },
  watch: {
    per(newVal) {
      this.$refs.filterComponent.params.settings.per = newVal
      this.loadPage(1)
    }
  },
  methods: {
    resetTask () {
      this.alreadySearch = false
      this.list = {}
      this.urlRequest = ''
      this.pagination = undefined
      history.pushState(null, null, '/tasks/collection_objects/filter')
    },
    loadList(newList) {
      if(this.append && this.list) {
        let concat = newList.data.concat(this.list.data)

        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i[0] === item[0]
          ))
        )
        newList.data = concat
        this.list = newList
      }
      else {
        this.list = newList
      }
      this.alreadySearch = true
    },
    loadPage(event) {
      this.$refs.filterComponent.loadPage(event.page)
    },
    getPagination: GetPagination
  }
}
</script>
<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>