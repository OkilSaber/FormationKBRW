export const remoteProps = {
    orders: (props) => {
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
