<template>
  <div
    v-shortkey="[getMacKey(), 'p']"
    @shortkey="createNewWithParent(true)">
    <div
      v-shortkey="[getMacKey(), 'd']"
      @shortkey="createNewWithChild(true)"/>
    <modal
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Confirm</h3>
      <div slot="body">Are you sure you want to create a new taxon name? All unsaved changes will be lost.</div>
      <div slot="footer">
        <button
          @click="reloadPage()"
          type="button"
          class="normal-input button button-default">New
        </button>
      </div>
    </modal>
    <button
      type="button"
      class="normal-input button button-default"
      v-shortkey="[getMacKey(), 'n']"
      @shortkey="createNew()"
      @click="createNew()">New
    </button>
  </div>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import Modal from 'components/modal.vue'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    Modal
  },
  computed: {
    unsavedChanges () {
      return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
    },
    getParent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    getTaxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  data: function () {
    return {
      showModal: false,
      url: RouteNames.NewTaxonName
    }
  },
  methods: {
    reloadPage() {
      window.location.href = this.url
      this.url = RouteNames.NewTaxonName
    },
    loadWithParent() {
      return ((this.getParent && this.getParent.hasOwnProperty('id')) ? `${RouteNames.NewTaxonName}?parent_id=${this.getParent.id}` : RouteNames.NewTaxonName)
    },
    createNew (newUrl = this.url) {
      this.url = newUrl
      if (this.unsavedChanges) {
        this.showModal = true
      } else {
        this.reloadPage()
      }
    },
    createNewWithChild() {
      this.createNew((this.getTaxon.id ? `${RouteNames.NewTaxonName}?parent_id=${this.getTaxon.id}` : RouteNames.NewTaxonName))
    },
    createNewWithParent() {
      this.createNew((this.getParent && this.getParent.hasOwnProperty('id') ? `${RouteNames.NewTaxonName}?parent_id=${this.getParent.id}` : RouteNames.NewTaxonName))
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    }
  }
}
</script>
