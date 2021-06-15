let Hooks = {}

Hooks.ContentLoaded = {
  mounted(){
    if (this.el.complete) {
      this.pushEvent("content_loaded", {})
    }
    this.el.addEventListener("load", e => {
      this.pushEvent("content_loaded", {})
    });
  }
}

Hooks.ContentLoadedText = {
  mounted(){
    this.pushEvent("content_loaded", {})
  }
}

export default Hooks
