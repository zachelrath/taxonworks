<template>
  <div id="new_taxon_name_task">
    <div class="flex-separate middle">
      <h1>{{ (getTaxon.id ? 'Edit' : 'New') }} taxon name</h1>
      <div class="horizontal-right-content middle">
        <label
          v-help.section.navbar.autosave
          class="horizontal-left-content middle margin-medium-right">
          <input
            type="checkbox"
            v-model="isAutosaveActive">
          Autosave
        </label>
        <autocomplete
          v-if="!getTaxon.id"
          class="autocomplete-search-bar"
          url="/taxon_names/autocomplete"
          param="term"
          :add-params="{ 'type[]': 'Protonym' }"
          label="label_html"
          placeholder="Search a taxon name..."
          @getItem="loadTaxon"
          :clearAfter="true"/>
      </div>
    </div>
    <div>
      <nav-header :menu="menu"/>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <spinner
            :full-screen="true"
            :legend="(loading ? 'Loading...' : 'Saving changes...')"
            :logo-size="{ width: '100px', height: '100px'}"
            v-if="loading"/>
          <template v-for="(visibleSection, componentName) in menu">
            <component
              v-if="visibleSection"
              class="margin-medium-bottom"
              :key="componentName"
              :is="`${componentName.replace(' ', '')}Section`"/>
          </template>
        </div>
        <div
          v-if="getTaxon.id"
          class="cright item separate-left">
          <div id="cright-panel">
            <div class="panel content margin-medium-bottom">
              <autocomplete
                url="/taxon_names/autocomplete"
                param="term"
                :add-params="{ 'type[]': 'Protonym' }"
                label="label_html"
                placeholder="Search a taxon name..."
                @getItem="loadTaxon"
                :clearAfter="true"/>
            </div>
            <check-changes/>
            <taxon-name-box class="separate-bottom"/>
            <soft-validation class="separate-top"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Autocomplete from 'components/autocomplete'
import showForThisGroup from './helpers/showForThisGroup'
import AuthorSection from './components/sourcePicker.vue'
import RelationshipSection from './components/relationshipPicker.vue'
import StatusSection from './components/statusPicker.vue'
import NavHeader from './components/navHeader.vue'
import TaxonNameBox from './components/taxonNameBox.vue'
import EtymologySection from './components/etymology.vue'
import GenderSection from './components/gender.vue'
import CheckChanges from './components/checkChanges.vue'
import TypeSection from './components/type.vue'
import BasicinformationSection from './components/basicInformation.vue'
import OriginalcombinationSection from './components/pickOriginalCombination.vue'
import ManagesynonymySection from './components/manageSynonym'
import ClassificationSection from './components/classification.vue'
import SoftValidation from './components/softValidation.vue'
import Spinner from 'components/spinner.vue'

import { convertType } from 'helpers/types.js'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    Autocomplete,
    Spinner,
    NavHeader,
    TaxonNameBox,
    CheckChanges,
    EtymologySection,
    AuthorSection,
    StatusSection,
    RelationshipSection,
    BasicinformationSection,
    SoftValidation,
    ManagesynonymySection,
    OriginalcombinationSection,
    TypeSection,
    GenderSection,
    ClassificationSection
  },
  computed: {
    getTaxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    getSaving () {
      return this.$store.getters[GetterNames.GetSaving]
    },
    isAutosaveActive: {
      get () {
        return this.$store.getters[GetterNames.GetAutosave]
      },
      set (value) {
        this.$store.commit(MutationNames.SetAutosave, value)
      }
    },
    menu () {
      return {
        'Basic information': true,
        Author: true,
        Status: true,
        Relationship: true,
        'Manage synonymy': showForThisGroup(['GenusGroup', 'FamilyGroup'], this.getTaxon),
        Type: showForThisGroup(['SpeciesGroup', 'GenusGroup', 'FamilyGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
        'Original combination': showForThisGroup(['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
        Classification: true,
        Gender: showForThisGroup(['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
        Etymology: showForThisGroup(['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
      }
    }
  },
  data () {
    return {
      loading: true
    }
  },
  mounted () {
    const that = this
    const urlParams = new URLSearchParams(window.location.search)
    let taxonId = urlParams.get('taxon_name_id')
    const value = convertType(sessionStorage.getItem('task::newtaxonname::autosave'))

    if (value !== null) {
      this.isAutosaveActive = value
    }

    if(!taxonId) {
      taxonId = location.pathname.split('/')[4]
    }

    window.addEventListener('scroll', this.scrollBox)

    this.initLoad().then(function () {
      if (/^\d+$/.test(taxonId)) {
        that.$store.dispatch(ActionNames.LoadTaxonName, taxonId).then(function () {
          that.$store.dispatch(ActionNames.LoadTaxonStatus, taxonId)
          that.$store.dispatch(ActionNames.LoadTaxonRelationships, taxonId)
          that.loading = false
        }, () => {
          that.loading = false
        })
      } else {
        that.loading = false
      }
    })

    this.addShortcutsDescription()
  },
  methods: {
    scrollBox (event) {
      const element = document.querySelector('#new_taxon_name_task #cright-panel')
      const softValidationContainer = document.querySelector('#new_taxon_name_task .soft-validation-box')
      if (softValidationContainer) {
        const innerHeight = window.innerHeight
        const elementRect = softValidationContainer.getBoundingClientRect()

        softValidationContainer.style.maxHeight = `${innerHeight - elementRect.top - 20}px`
      }
      if (element) {
        if (((window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0) > 154) && (this.isMinor())) {
          element.classList.add('cright-fixed-top')
        } else {
          element.classList.remove('cright-fixed-top')
        }
      }
    },
    addShortcutsDescription () {
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+s`, 'Save taxon name changes', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+n`, 'Create a new taxon name', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+p`, 'Create a new taxon name with the same parent', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+d`, 'Create a child of this taxon name', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+l`, 'Clone this taxon name', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+e`, 'Go to comprehensive specimen digitization', 'New taxon name')
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    },
    isMinor: function () {
      let element = document.querySelector('#cright-panel')
      let navBar = document.querySelector('#taxonNavBar')

      if (element && navBar) {
        return ((element.offsetHeight + navBar.offsetHeight) < window.innerHeight)
      } else {
        return true
      }
    },
    showForThisGroup: showForThisGroup,
    initLoad: function () {
      let that = this
      let actions = [
        this.$store.dispatch(ActionNames.LoadRanks),
        this.$store.dispatch(ActionNames.LoadStatus),
        this.$store.dispatch(ActionNames.LoadRelationships)
      ]
      return new Promise(function (resolve, reject) {
        Promise.all(actions).then(function () {
          that.$store.commit(MutationNames.SetInitLoad, true)
          return resolve(true)
        })
      })
    },
    loadTaxon (taxon) {
      window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxon.id}`, '_self')
    }
  }
}

</script>
<style lang="scss">
  #new_taxon_name_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    .basic-information {
      .vue-autocomplete-input {
        width: 300px;
      }
    }

    .autocomplete-search-bar {
      input {
        width: 500px;
      }
    }

    .cleft, .cright {
      min-width: 350px;
      max-width: 350px;
      width: 300px;
    }
    .ccenter {
      max-width: 1240px;
    }
    #cright-panel {
      width: 350px;
      max-width: 350px;
    }
    .cright-fixed-top {
      top:68px;
      width: 1240px;
      z-index:200;
      position: fixed;
    }
    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
  }

</style>
