'use strict'

$ = (arg) ->
  return (require 'jquery') arg

module.exports =
class FilterEditorView
  scheduleTimeout: null
  confirmed: false

  constructor: (args) ->
    @_createFrameArea()

    @$list = $(@list)

    # Events binding
    @filterEditor.getModel().getBuffer().onDidChange =>
      @_schedulePopulateList()

    $(@filterEditor).blur (e) =>
      @cancel()

    atom.commands.add @root,
      'core:move-up': (event) =>
        first = @$list.find('li:first')
        last = @$list.find('li:last')
        selectedItem = @_getSelectedItem()

        if selectedItem.length is 0 # selected nothing
          @_selectItem(last)
        else if selectedItem is first
          @_selectItem(null)
        else
          @_selectItem(@_getSelectedItem().prev())

        event.stopPropagation()

      'core:move-down': (event) =>
        first = @$list.find('li:first')
        last = @$list.find('li:last')
        selectedItem = @_getSelectedItem()

        if selectedItem.length is 0 # slected nothing
          @_selectItem(first)
        else if selectedItem is last
          @_selectItem(null)
        else
          @_selectItem(@_getSelectedItem().next())

        event.stopPropagation()

      'core:confirm': (event) =>
        @confirm()
        event.stopPropagation()

      'core:cancel': (event) =>
        @cancel()
        event.stopPropagation()

    @$list.on 'mousedown', 'li', (e) =>
      @_selectItem($(e.target).closest('li'))
      e.preventDefault()
      false

    @$list.on 'mouseup', 'li', (e) =>
      @confirm() if $(e.target).closest('li').hasClass('selected')
      e.preventDefault()
      false

  _createFrameArea: ->
    @root = document.createElement('div')
    @root.classList.add('select-list', 'block')

    @filterEditor = document.createElement('atom-text-editor')
    @filterEditor.setAttribute('mini', true)
    @root.appendChild(@filterEditor)

    @list = document.createElement('ol')
    @list.classList.add('list-group')
    @root.appendChild(@list)

  _selectItem: ($item) ->
    if not ($item and $item.length)
      return @$list.find('.selected').removeClass('selected')

    @$list.find('.selected').removeClass('selected')
    $item.addClass('selected')
    @_scrollToItem($item)

  _scrollToItem: ($item) ->
    delta = 5
    listHeight = @$list.height()
    itemHeight = $item.outerHeight()
    scrollTop = @$list.scrollTop()
    desiredTop = $item.position().top

    if desiredTop - scrollTop > listHeight - delta
      @$list.scrollTop(desiredTop - listHeight + itemHeight)
    else if scrollTop - desiredTop > itemHeight - delta
      @$list.scrollTop(desiredTop)

  _getSelectedItem: ->
    @$list.find('.selected')

  _confirmedCallback: ->

  onConfirmed: (callback) ->
    if typeof callback is 'function'
      @_confirmedCallback = callback

  # Confirm
  confirm: ->
    console.log 'confirm...'
    @confirmed = true
    selectedItem = @_getSelectedItem()
    if selectedItem.length isnt 0
      @setText(selectedItem.text())
    @_confirmedCallback(@getText())

  # Cancel all the ongoing event
  cancel: ->
    @confirmed = false
    clearTimeout(@scheduleTimeout)
    @root.classList.remove('popover-list')
    @$list.empty()

  # Set the text of filter editor
  setText: (text) ->
    @filterEditor.getModel().setText(text)

  # Get the text of filter editor
  getText: ->
    @filterEditor.getModel().getText()

  _schedulePopulateList: ->
    clearTimeout(@scheduleTimeout)
    if @filterEditor.getModel().getText().length isnt 0
      @scheduleTimeout = setTimeout (=> @_populateList()), 200

  _filterSyncCallback: (str) ->
    []

  onFilterSync: (callback) ->
    if typeof callback is 'function'
      @_filterSyncCallback = callback

  _populateList: ->
    if @confirmed
      return @confirmed = false

    @$list.empty()
    result = @_filterSyncCallback(@getText())
    @$list.append($('<li/>').text(i)) for i in result

    if result.length > 0
      @root.classList.add('popover-list')
    else
      @root.classList.remove('popover-list')

    @_selectItem(@$list.find('li:first'))

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @root.remove()

  getElement: ->
    @root
