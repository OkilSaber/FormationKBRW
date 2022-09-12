const React = require("react")
const createReactClass = require('create-react-class')
const orders = []

export const Child = createReactClass({
    render() {
        var [ChildHandler, ...rest] = this.props.handlerPath
        return <ChildHandler {...this.props} handlerPath={rest} />
    }
})

export const Orders = createReactClass({
    render() {
        return (
            <>{
                orders.map(
                    order => (
                        <JSXZ in="orders" sel=".products-table-container">
                            <Z sel=".commands-list">
                                <JSXZ in="orders" sel=".command-number-container">
                                    <Z in="orders" sel=".command-number-text">
                                        {order.remoteid}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".customer-container">
                                    <Z in="orders" sel=".customer-text">
                                        {order.custom.customer.full_name}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".address-container">
                                    <Z in="orders" sel=".address-text">
                                        {order.custom.billing_address}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".quantity-container">
                                    <Z in="orders" sel=".quantity-text">
                                        {order.items}
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".details-container">
                                    <Z in="orders" sel=".details-link">
                                        See details
                                    </Z>
                                </JSXZ>
                                <JSXZ in="orders" sel=".pay-container">
                                    <Z in="orders" sel=".pay-text">
                                        {order.remoteid}
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

export const Header = createReactClass({
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

                    </JSXZ>
                </Z>
            </JSXZ>
        )
    }
})

export const Layout = createReactClass({
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