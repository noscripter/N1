_ = require 'underscore-plus'
React = require "react"
Tooltip = require "./tooltip"
{ComponentRegistry} = require("inbox-exports")

module.exports =
  item: null # The DOM item the main React component renders into

  activate: (@state={}) ->
    @item = document.createElement("div")
    @item.setAttribute("id", "tooltip-container")
    @item.setAttribute("class", "tooltip-container")
    @tooltip = React.render(React.createElement(Tooltip), @item)
    document.querySelector(atom.workspaceViewParentSelector).appendChild(@item)

    @mouseOverListener = _.bind(@tooltip.onMouseOver, @tooltip)
    @mouseOutListener = _.bind(@tooltip.onMouseOut, @tooltip)

    window.addEventListener("mouseover", @mouseOverListener)
    window.addEventListener("mouseout", @mouseOutListener)

  deactivate: ->
    React.unmountComponentAtNode(@item)
    document.querySelector(atom.workspaceViewParentSelector).removeChild(@item)

    window.removeEventListener("mouseover", @mouseOverListener)
    window.removeEventListener("mouseout", @mouseOutListener)

  serialize: -> @state