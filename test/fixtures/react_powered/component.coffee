
React = require 'react'

R = React.DOM

module.exports = React.createClass
  render: ->
     React.createElement 'div', { className: 'message' },
      React.createElement 'p', { ref : "p" }, "Hello #{@props.name}!!!"
    