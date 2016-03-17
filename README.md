# filter-editor-view package

A filter text editor that allow you to filter keywords by the input.

# Screenshot

![A screenshot of your package](http://i.imgur.com/wXYmY8V.png)

## Constructor Params
None (currently)

## Methods
### `::getElement()`
Returns the DOM element.

### `::getText()`
Returns the text of the `filter-editor-view`.

### `::setText(text)`
Set the text of the `filter-editor-view`.
 * `text` the text

### `::confirm()`
Confirm the text of the `filter-editor-view`.  
This will trigger the callback of the `::onConfirmed(callback)`

### `::cancel()`
Cancel the ongoing keywords filter timeout.

### `::onConfirmed(callback)`
Set the confirmed callback when confirming the input.
 * `callback(text)` the callback when confirming the input.
  * `text` the confirmed input text.

### `::onFilter(callback)`
Set the filter callback when beginning filter keywords.
 * `callback(token, text, cb)` the callback when beginning filter keywords.  
  ** the callback is Async **
  * `token` a string that represent the current filter session.
  * `text` the filter text.
  * `cb(token, result)` the callback the must be called when finished filter.
    * `token` the token of the filter session (Usually the token above).
    * `result` an array of the filtered keywords. Each item is a string (currently).

## Example
```coffee
@filterEditor = new FilterEditorView()

@filterEditor.onFilter (token, text, cb) ->
   setTimeout -> # represent an Async HTTP request
     cb(token, [text.toUpperCase()])
   , 1000

@filterEditor.onConfirmed (text) ->
  console.log "confirmed #{text}"

@root.appendChild(@filterEditor.getElement())


```
