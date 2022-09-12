export const remoteProps = {
    orders: (props) => {
        return {
            url: "/orders",
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
