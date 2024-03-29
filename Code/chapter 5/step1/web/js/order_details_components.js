const React = require("react")
const createReactClass = require('create-react-class')
import { getQuantity, formatAddress, goTo } from './utilities';
import { remoteProps } from './remote_props'
export const Child = createReactClass({
    render() {
        var [ChildHandler, ...rest] = this.props.handlerPath
        return <ChildHandler {...this.props} handlerPath={rest} />
    }
})

export const DetailsOrder = createReactClass({
    render() {
        return (
            <>
                {
                    this.props.order.value.custom.items.map(item => (
                        <JSXZ in="order_details" sel=".products-list-container" key={item.item_id}>
                            <Z sel=".products-list">
                                <JSXZ in="order_details" sel=".product-name-container">
                                    <Z in="order_details" sel=".product-name-text">
                                        {item.product_title}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="order_details" sel=".product-quantity-container">
                                    <Z in="order_details" sel=".product-quantity-text">
                                        {item.quantity_to_fetch}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="order_details" sel=".product-unit-price-container">
                                    <Z in="order_details" sel=".product-unit-price-text">
                                        {item.unit_price}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="order_details" sel=".product-total-price-container">
                                    <Z in="order_details" sel=".product-total-price-text">
                                        {item.price * item.quantity_to_fetch}
                                    </Z>
                                </JSXZ>
                            </Z>
                        </JSXZ>
                    ))
                }
            </>
        )
    }
})

export const DetailsHeader = createReactClass({
    statics: {
        remoteProps: [remoteProps.order]
    },
    render() {
        return (
            <JSXZ in="order_details" sel=".header">
                <Z sel=".header-container">
                    <JSXZ in="order_details" sel=".navbar"></JSXZ>
                    <JSXZ in="order_details" sel=".container">
                        <Z sel=".order-details">
                            <JSXZ in="order_details" sel=".order-details-container">
                                <Z sel=".order-fields">
                                    <ChildrenZ />
                                </Z>
                                <Z sel=".order-data">
                                    <JSXZ in="order_details" sel=".order-data-container">
                                        <Z in="order_details" sel=".order-client-name">
                                            {this.props.order.value.custom.customer.full_name}
                                        </Z>
                                        <Z in="order_details" sel=".order-address">
                                            {formatAddress(this.props.order.value.custom.shipping_address)}
                                        </Z>
                                        <Z in="order_details" sel=".order-number">
                                            {this.props.order.value.id}
                                        </Z>
                                    </JSXZ>
                                </Z>
                            </JSXZ>
                        </Z>
                        <Z sel=".products-table">
                            <JSXZ in="order_details" sel=".list-categories-container"></JSXZ>
                            <this.props.Child {...this.props} />
                        </Z>
                        <Z in="order_details" sel=".back-container" onClick={() => goTo("orders", {}, { page: 0 })}>
                            <ChildrenZ />
                        </Z>
                    </JSXZ>
                </Z>
            </JSXZ>
        )
    }
})

export const DetailsLayout = createReactClass({
    render() {
        return (
            <JSXZ in="order_details" sel=".layout">
                <Z sel=".layout-container">
                    <this.props.Child {...this.props} />
                </Z>
            </JSXZ>
        )
    }
})