const React = require("react")
const createReactClass = require('create-react-class')

export const DeleteModal = createReactClass({
    render() {
        return (
            <JSXZ in="confirm_modal" sel=".modal-content">
                <Z sel=".buttons-container">
                    <JSXZ in="confirm_modal" sel=".confirm-delete-button" onClick={() => this.props.callback(true)}>
                    </JSXZ>
                    <JSXZ in="confirm_modal" sel=".cancel-delete-button" onClick={() => this.props.callback(false)}>
                    </JSXZ>
                </Z>
            </JSXZ>
        )
    }
})
export const LoaderModal = createReactClass({
    getInitialState: function () {
        this.props.promise.then(() => this.props.callback(this.props.order_id))
        return {}
    },
    render() {
        return (
            <JSXZ in="loader" sel=".loader-content">
            </JSXZ>
        )
    }
})