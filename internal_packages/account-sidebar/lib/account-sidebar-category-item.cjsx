React = require 'react'
classNames = require 'classnames'
{Actions,
 Utils,
 UnreadCountStore,
 WorkspaceStore,
 NamespaceStore,
 FocusedCategoryStore,
 ChangeLabelsTask,
 ChangeFolderTask,
 CategoryStore} = require 'nylas-exports'
{RetinaImg, DropZone} = require 'nylas-component-kit'

class AccountSidebarCategoryItem extends React.Component
  @displayName: 'AccountSidebarCategoryItem'

  constructor: (@props) ->
    @state =
      unreadCount: UnreadCountStore.count() ? 0

  componentWillMount: =>
    @_usub = UnreadCountStore.listen @_onUnreadCountChange

  componentWillUnmount: =>
    @_usub()

  _onUnreadCountChange: =>
    @setState unreadCount: UnreadCountStore.count()

  shouldComponentUpdate: (nextProps, nextState) =>
    !Utils.isEqualReact(@props, nextProps) or !Utils.isEqualReact(@state, nextState)

  render: =>
    unread = []
    if @props.item.name is "inbox" and @state.unreadCount > 0
      unread = <div className="unread item-count-box">{@state.unreadCount}</div>

    containerClass = classNames
      'item': true
      'selected': @props.select
      'dropping': @state.isDropping

    <DropZone className={containerClass}
         onClick={@_onClick}
         id={@props.item.id}
         shouldAcceptDrop={@_shouldAcceptDrop}
         onDragStateChange={ ({isDropping}) => @setState({isDropping}) }
         onDrop={@_onDrop}>
      {unread}
      <RetinaImg name={"#{@props.item.name}.png"} fallback={'folder.png'} mode={RetinaImg.Mode.ContentIsMask} />
      <span className="name"> {@props.item.displayName}</span>
    </DropZone>

  _shouldAcceptDrop: (e) =>
    return false if @props.item.name in CategoryStore.LockedCategoryNames
    return false if @props.item.name is FocusedCategoryStore.categoryName()
    'nylas-thread-ids' in e.dataTransfer.types

  _onDrop: (e) =>
    jsonString = e.dataTransfer.getData('nylas-thread-ids')
    try
      ids = JSON.parse(jsonString)
    catch err
      console.error("AccountSidebarCategoryItem onDrop: JSON parse #{err}")
    return unless ids

    if NamespaceStore.current().usesLabels()
      currentLabel = FocusedCategoryStore.category()
      if currentLabel and not (currentLabel in CategoryStore.LockedCategoryNames)
        labelsToRemove = [currentLabel]

      task = new ChangeLabelsTask
        threadIds: ids,
        labelsToAdd: [@props.item],
        labelsToRemove: labelsToRemove
    else
      task = new ChangeFolderTask
        folderOrId: @props.item,
        threadIds: ids

    Actions.queueTask(task)

  _onClick: (event) =>
    event.preventDefault()
    Actions.selectRootSheet(WorkspaceStore.Sheet.Threads)
    Actions.focusCategory(@props.item)

module.exports = AccountSidebarCategoryItem