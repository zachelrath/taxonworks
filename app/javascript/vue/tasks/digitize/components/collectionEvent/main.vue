<template>
  <block-layout :warning="!collectingEvent.id">
    <div slot="header">
      <h3>Collecting Event</h3>
    </div>
    <div
      slot="options"
      class="horizontal-left-content separate-right"
    >
      <span v-if="collectingEvent.id">Sequential uses: {{ (this.subsequentialUses == 0 ? '-' : this.subsequentialUses) }}</span>
      <div
        v-if="collectingEvent.id"
        class="horizontal-left-content separate-left separate-right"
      >
        <radial-annotator :global-id="collectingEvent.global_id" />
        <radial-object :global-id="collectingEvent.global_id" />
        <pin-component
          :object-id="collectingEvent.id"
          type="CollectingEvent"
        />
      </div>
    </div>
    <div
      slot="body">
      <fieldset class="separate-bottom">
        <legend>Selector</legend>
        <div class="horizontal-left-content align-start separate-bottom">
          <smart-selector
            class="full_width"
            ref="smartSelector"
            model="collecting_events"
            target="CollectionObject"
            klass="CollectionObject"
            pin-section="CollectingEvents"
            pin-type="CollectingEvent"
            @selected="setCollectingEvent"/>
          <div class="horizontal-right-content">
            <lock-component
              class="circle-button-margin"
              v-model="locked.collecting_event"
            />
          </div>
        </div>
        <div
          v-if="collectingEvent.id"
          class="horizontal-left-content"
        >
          <p v-html="collectingEvent.object_tag" />
          <span
            class="circle-button button-default btn-undo"
            @click="cleanCollectionEvent"
          />
          <button
            type="button"
            class="button normal-input button-submit margin-small-right"
            @click="cloneCE"
          >
            Clone
          </button>
          <a :href="`/tasks/collecting_events/browse?collecting_event_id=${collectingEvent.id}`">Browse</a>
        </div>
      </fieldset>
      <div class="horizontal-left-content align-start">
        <block-verbatin class="separate-right half_width" />
        <block-geography class="separate-left separate-right full_width" />
        <block-map class="separate-left full_width" />
      </div>
    </div>
  </block-layout>
</template>

<script>

import BlockVerbatin from './components/verbatimLayout.vue'
import BlockGeography from './components/GeographyLayout.vue'
import SmartSelector from 'components/smartSelector.vue'
import LockComponent from 'components/lock.vue'
import BlockMap from './components/map/main.vue'
import BlockLayout from 'components/blockLayout.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import PinComponent from 'components/pin.vue'

import { CloneCollectionEvent } from '../../request/resources.js'
import makeCollectingEvent from '../../const/collectingEvent.js'
import refreshSmartSelector from '../shared/refreshSmartSelector'

export default {
  mixins: [refreshSmartSelector],
  components: {
    BlockLayout,
    BlockVerbatin,
    BlockGeography,
    SmartSelector,
    RadialAnnotator,
    RadialObject,
    PinComponent,
    BlockMap,
    LockComponent
  },
  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    actualComponent () {
      return (this.view + 'Component')
    },
    subsequentialUses: {
      get () {
        return this.$store.getters[GetterNames.GetSubsequentialUses]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSubsequentialUses, value)
      }
    },
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    }
  },
  watch: {
    collectingEvent (newVal, oldVal) {
      if (!(newVal.hasOwnProperty('id') &&
        oldVal.hasOwnProperty('id') &&
        newVal.id == oldVal.id)) {
        this.subsequentialUses = 0
      }
    }
  },
  methods: {
    setCollectingEvent (ce) {
      this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), ce))
      this.$store.dispatch(ActionNames.GetLabels, ce.id)
    },
    cleanCollectionEvent () {
      this.$store.dispatch(ActionNames.NewCollectionEvent)
    },
    cloneCE () {
      CloneCollectionEvent(this.collectingEvent.id).then(response => {
        this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), response.body))
        this.$store.dispatch(ActionNames.SaveDigitalization)
      })
    }
  }
}
</script>
