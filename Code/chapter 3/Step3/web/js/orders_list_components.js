const React = require("react")
const createReactClass = require('create-react-class')
import {getQuantity, formatAddress, goTo} from './utilities';
import { remoteProps } from './remote_props'
export const Child = createReactClass({
    render() {
        var [ChildHandler, ...rest] = this.props.handlerPath
        return <ChildHandler {...this.props} handlerPath={rest} />
    }
})

export const ListOrders = createReactClass({
    statics: {
        remoteProps: [remoteProps.orders]
    },
    render() {
        return (
            <>{
                this.props.orders.value.map(
                    order => (
                        <JSXZ in="orders" sel=".products-table-container" key={order.id}>
                            <Z sel=".commands-list">
                                <JSXZ in="orders" sel=".command-number-container">
                                    <Z in="orders" sel=".command-number-text">
                                        {order.id}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".customer-container">
                                    <Z in="orders" sel=".customer-text">
                                        {order.custom.customer.full_name}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".address-container">
                                    <Z in="orders" sel=".address-text">
                                        {formatAddress(order.custom.shipping_address)}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".quantity-container">
                                    <Z in="orders" sel=".quantity-text">
                                        {getQuantity(order.custom.items)}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".details-container">
                                    <Z in="orders" sel=".details-link">
                                        <a onClick={() => goTo("order", order.id, {})}>Details</a>
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".pay-container">
                                    <Z in="orders" sel=".pay-text">
                                        Status: {order.status.state}
                                    </Z>
                                </JSXZ>
                            </Z>
                        </JSXZ>
                    )
                )
            }</>
        )
    }
})

export const ListHeader = createReactClass({
    render() {
        return (
            <JSXZ in="orders" sel=".header">
                <Z sel=".header-container">
                    <JSXZ in="orders" sel=".navbar"></JSXZ>
                    <JSXZ in="orders" sel=".container">
                        <Z sel=".search-div">
                            <JSXZ in="orders" sel=".search-div-container"></JSXZ>
                        </Z>
                        <Z sel=".products-table">
                            <JSXZ in="orders" sel=".list-categories-container"></JSXZ>
                            <this.props.Child {...this.props} />
                        </Z>
                        <Z sel=".pages">
                            <ChildrenZ />
                            {/* <JSXZ in="orders" sel=".pages-container"></JSXZ> */}
                        </Z>
                    </JSXZ>
                </Z>
            </JSXZ>
        )
    }
})

export const ListLayout = createReactClass({
    render() {
        return (
            <JSXZ in="orders" sel=".layout">
                <Z sel=".layout-container">
                    <this.props.Child {...this.props} />
                </Z>
            </JSXZ>
        )
    }
})