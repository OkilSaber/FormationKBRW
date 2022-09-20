export const remoteProps = {
    orders: (props) => {
        if (typeof props.qs.page == 'undefined')
            props.qs.page = 0
        return {
            url: `/api/orders?page=${props.qs.page}`,
            prop: "orders"
        }
    },
    order: (props) => {
        return {
            url: "/api/order/" + props.order_id,
            prop: "order"
        }
    }
}
