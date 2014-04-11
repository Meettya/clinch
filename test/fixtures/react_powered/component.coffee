
React = require 'react'

R = React.DOM

module.exports = React.createClass
  render: ->
    R.div { className: 'message' },
      R.p { ref : "p" }, "Hello #{@props.name}!!!"
    