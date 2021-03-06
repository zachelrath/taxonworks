<template>
  <div
    class="flex-wrap-column"
    v-if="panelFigures && content">
    <draggable
      v-model="depictions" :options="{ filter:'.dropzone-card', handle: '.card-handle' }"
      @start="drag=true"
      @end="drag=false, updatePosition()"
      class="item item1 column-medium flex-wrap-row">
      <figure-item
        v-for="item in depictions"
        :figure="item"
        :key="item.id"/>
      <dropzone
        class="dropzone-card"
        @vdropzone-sending="sending"
        @vdropzone-success="success"
        ref="figure"
        id="figure"
        url="/depictions"
        :use-custom-dropzone-options="true"
        :dropzone-options="dropzone"/>
    </draggable>
    <div class="item item2 column-tiny no-margin"/>
  </div>
</template>
<script>

import Draggable from 'vuedraggable'
import Dropzone from 'components/dropzone.vue'
import FigureItem from './figureItem.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { SortDepictions, GetContentDepictions } from '../request/resources'

export default {
  computed: {
    content () {
      return this.$store.getters[GetterNames.GetContentSelected]
    },
    panelFigures () {
      return this.$store.getters[GetterNames.PanelFigures]
    },
    depictions: {
      get () {
        return this.$store.getters[GetterNames.GetDepictionsList]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDepictionsList, value)
      }
    }
  },
  components: {
    Draggable: Draggable,
    Dropzone,
    FigureItem
  },
  data: function () {
    return {
      drag: false,
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here to add figures',
        acceptedFiles: 'image/*'
      }
    }
  },
  watch: {
    content (val, oldVal) {
      if (val != undefined) {
        if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
          this.loadContent()
        }
      } else {
        this.$store.commit(MutationNames.SetDepictionsList, [])
      }
    }
  },
  methods: {
    success (file, response) {
      this.$store.commit(MutationNames.AddDepictionToList, response)
      this.$refs.figure.removeFile(file)
    },
    sending (file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.content.id)
      formData.append('depiction[depiction_object_type]', 'Content')
    },
    loadContent () {
      GetContentDepictions(this.content.id).then(response => {
        this.$store.commit(MutationNames.SetDepictionsList, response.body)
      })
    },
    updatePosition () {
      SortDepictions({ depiction_ids: this.depictions.map((depiction) => depiction.id) })
    }
  }
}
</script>
