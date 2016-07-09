Global menu on top
Tree on left
"View"/"Editor" in middle
CLI at bottom

# Boot script

    if not boot = localStorage.getItem 'boot'
      window.alert 'No boot information found'

    eval boot

# Boot data

    # Build UI

    body = document.body
    body.appendElement menu = 
