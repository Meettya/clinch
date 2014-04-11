/** @jsx React.DOM */

React = require('react');

module.exports = React.createClass({
  render: function() {
    return (
      <div className="message">
        <p ref="p">Hello {this.props.name}!!!</p>
      </div>
    );
  }
});