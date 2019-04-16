<template>
  <div>
    <div ref="audioPlayer"/>
    <div
      v-if="spectrogram" 
      ref="spectrogram"/>
    <div v-if="controls">
      <button
        type="button"
        class="button normal-input button-default"
        @click="play">
        Play
      </button>
      <button
        type="button"
        class="button normal-input button-default"
        @click="stop">
        Stop
      </button>
    </div>
  </div>
</template>

<script>

import Wavesurfer from 'wavesurfer.js'
import Spectrogram from 'wavesurfer.js/dist/plugin/wavesurfer.spectrogram.min.js'

export default {
  props: {
    soundFile: {
      type: String,
      required: true
    },
    spectrogram: {
      type: Boolean,
      default: false
    },
    controls: {
      type: Boolean,
      default: true
    },
    autoplay: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      soundPlayer: undefined
    }
  },
  mounted() {
    this.createWaveSurfer()
    this.soundPlayer.load(this.soundFile)
    this.events()
  },
  methods: {
    events() {
      let that = this
      that.soundPlayer.on('ready', () => {
        this.soundPlayer.play()
      })
    },
    play() {
      this.soundPlayer.play()
    },
    stop() {
      this.soundPlayer.stop()
    },
    pause() {
      this.soundPlayer.pause()
    },
    createWaveSurfer(plugins = undefined) {
      let that = this
      this.soundPlayer = Wavesurfer.create({
        wavesurfer: this.soundPlayer,
        container: this.$refs.audioPlayer,
        labels: true,
        mediaControls: this.controls,
        plugins: this.getPlugins()
      })
    },
    load(url) {
      this.soundPlayer.load(url)
    },
    getPlugins() {
      let plugins = []
      let that = this

      if(this.spectrogram)
        plugins.push(
          Spectrogram.create({
            wavesurfer: that.soundPlayer,
            container: that.$refs.spectrogram,
            labels: true
          })
        )
      
      return plugins
    }
  }
}
</script>
