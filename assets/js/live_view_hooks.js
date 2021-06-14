let Hooks = {}

Hooks.ContentLoaded = {
  mounted(){
    this.pushEvent("content_loaded", {})
  }
}

export default Hooks
