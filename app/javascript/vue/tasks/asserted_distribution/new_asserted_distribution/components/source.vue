<template>
  <fieldset>
    <legend>Source</legend>
    <smart-selector
      model="sources"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      ref="smartSelector"
      pin-section="Sources"
      pin-type="Source"
      v-model="assertedDistribution.citation.source">
      <div slot="footer">
        <template v-if="assertedDistribution.citation.source">
          <p class="horizontal-left-content">
            <span data-icon="ok"/>
            <span v-html="assertedDistribution.citation.source.object_tag"/>
            <span
              class="button circle-button btn-undo button-default"
              @click="unset"/>
          </p>
        </template>
        <div
          class="horizontal-left-content middle margin-medium-top">
          <label class="margin-small-right">
            <input
              class="pages"
              v-model="assertedDistribution.citation.pages"
              placeholder="Pages"
              type="text">
          </label>
          <ul class="no_bullets context-menu">
            <li>
              <label>
                <input
                  type="checkbox"
                  v-model="assertedDistribution.citation.is_original">
                Is original
              </label>
            </li>
            <li>
              <label>
                <input
                  v-model="assertedDistribution.is_absent"
                  type="checkbox">
                Is absent
              </label>
            </li>
          </ul>
        </div>
      </div>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    assertedDistribution: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  methods: {
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.assertedDistribution.citation.source = undefined
    }
  }
}
</script>

<style scoped>
  .pages {
    widows: 80px;
  }
</style>

