import { Component } from 'react';

export default class ErrorBoundary extends Component {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  render() {
    if (this.state.failed) return <main className="auth-loading"><div className="glass error-state" role="alert"><h1>This page could not be displayed</h1><p>Please reload the portal and try again.</p><button className="button primary" onClick={() => window.location.reload()}>Reload portal</button></div></main>;
    return this.props.children;
  }
}
