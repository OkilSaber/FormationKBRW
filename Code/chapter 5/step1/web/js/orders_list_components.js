const React = require("react")
const createReactClass = require('create-react-class')
import { getQuantity, formatAddress, goTo, cn } from './utilities';
import { remoteProps } from './remote_props'
import { HTTP } from './http';
import { DeleteModal, LoaderModal } from './modals';

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
    getInitialState: function () {
        return { orders: this.props.orders.value }
    },
    componentWillReceiveProps(props) {
        if (props.filter) {
            this.setState({ orders: props.filter })
        } else {
            this.setState({ orders: props.orders.value })
        }
    },
    openDeleteModal(order) {
        this.props.modal({
            type: 'delete',
            callback: (value) => {
                switch (value) {
                    case true:
                        this.openLoadModal(HTTP.delete(`/api/order/${order.id}`), order.id)
                        break
                    default:
                        break
                }
            }
        })
    },
    openLoadModal(promise, order_id) {
        this.props.modal({
            type: 'load',
            promise: promise,
            order_id: order_id,
            callback: (value) => {
                this.setState({
                    orders: this.state.orders.filter((o) => {
                        return o.id != value
                    })
                })
            }
        })
    },
    render() {
        return (
            <>{
                this.state.orders.map(
                    order => (
                        <JSXZ in="orders" sel=".orders-table-container" key={order.id}>
                            <Z sel=".orders-list">
                                <JSXZ in="orders" sel=".order-number-container">
                                    <Z in="orders" sel=".order-number-text">
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
                                <JSXZ in="orders" sel=".actions-container">
                                    <Z in="orders" sel=".action-delete-button" onClick={() => this.openDeleteModal(order)}>
                                        <ChildrenZ />
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
    getInitialState: function () {
        return { search_field: "" }
    },
    search() {
        if (this.state.search_field != "") {
            const filters = this.state.search_field.split(" AND ")
            var final_query = ""
            filters.forEach((filter) => {
                const query = filter.split(":")
                final_query = final_query.concat(`&${query[0]}=${query[1]}`)
            })
            final_query = final_query.substring(1)
            console.log(final_query)
            HTTP.get(`/api/orders?${final_query}`).then(
                (response) => {
                    console.log(response)
                    this.setState(() => { return { filter: response } })
                }
            )
        }
    },
    render() {
        return (
            <JSXZ in="orders" sel=".header">
                <Z sel=".header-container">
                    <JSXZ in="orders" sel=".navbar"></JSXZ>
                    <JSXZ in="orders" sel=".container">
                        <Z sel=".search-div">
                            <JSXZ in="orders" sel=".search-div-container">
                                <Z
                                    sel=".search-form-container"
                                    onSubmit={
                                        (e) => {
                                            e.preventDefault()
                                            this.search()
                                        }
                                    }
                                >
                                    <JSXZ in="orders" sel=".search-form">
                                        <Z sel=".search-text-container">
                                            <ChildrenZ />
                                        </Z>
                                        <Z sel=".search-field" value={this.state.search_field} onChange={
                                            (e) => this.setState({ search_field: e.target.value })}>
                                            <ChildrenZ />
                                        </Z>
                                        <Z sel=".my-button" onClick={() => this.search()}>
                                            <ChildrenZ />
                                        </Z>
                                    </JSXZ>
                                </Z>
                            </JSXZ>
                        </Z>
                        <Z sel=".orders-table">
                            <JSXZ in="orders" sel=".list-categories-container"></JSXZ>
                            <this.props.Child {...this.props} filter={this.state.filter} />
                        </Z>
                        <Z sel=".pages">
                            <JSXZ in="orders" sel=".pages-container">
                                <Z sel=".previous-page-container" onClick={() => {
                                    if (parseInt(this.props.qs.page) > 0) {
                                        goTo("orders", null, { page: parseInt(this.props.qs.page) - 1 })
                                        this.setState()
                                    }
                                }} >
                                    {"<"}
                                </Z>
                                <Z sel=".current-page-container">
                                    {parseInt(this.props.qs.page) + 1}
                                </Z>
                                <Z sel=".next-page-container" onClick={() => {
                                    goTo("orders", null, { page: parseInt(this.props.qs.page) + 1 })
                                    this.setState()
                                }} >
                                    {">"}
                                </Z>
                            </JSXZ>
                        </Z>
                    </JSXZ>
                </Z >
            </JSXZ >
        )
    }
})

export const ListLayout = createReactClass({
    getInitialState: () => {
        return { modal: null };
    },
    modal(spec) {
        this.setState({
            modal: {
                ...spec, callback: (res) => {
                    this.setState({ modal: null }, () => {
                        if (spec.callback) {
                            spec.callback(res)
                        }
                    })
                }
            }
        })
    },
    render() {
        var modal_component = {
            'delete': (props) => <DeleteModal {...props} />,
            'load': (props) => <LoaderModal {...props} />
        }[this.state.modal && this.state.modal.type];
        modal_component = modal_component && modal_component(this.state.modal)
        var props = {
            ...this.props,
            modal: this.modal
        }
        return (
            <JSXZ in="orders" sel=".layout">
                <Z sel=".modal-wrapper" className={cn(classNameZ, { 'hidden': !modal_component })}>
                    {modal_component}
                </Z>
                <Z sel=".layout-container">
                    <this.props.Child {...props} />
                </Z>
            </JSXZ>
        )
    }
})