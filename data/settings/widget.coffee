prev = (event) ->
    if (event.button == 0 and not event.shiftKey)
        self.port.emit('left-click')

    if (event.button == 2 or (event.button == 0 and event.shiftKey))
        self.port.emit('right-click')
    event.preventDefault()

this.addEventListener('click', prev, true)