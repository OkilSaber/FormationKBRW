import { ListLayout, ListHeader, ListOrders } from './orders_list_components';
import { DetailsLayout, DetailsHeader, DetailsOrder } from './order_details_components';

export const routes = {
    "orders": {
        path: (params) => {
            return "/";
        },
        match: (path, qs) => {
            return (path == "/") && { handlerPath: [ListLayout, ListHeader, ListOrders] }
        }
    },
    "order": {
        path: (params) => {
            return "/order/" + params;
        },
        match: (path, qs) => {
            var r = new RegExp("/order/([^/]*)$").exec(path)
            return r && { handlerPath: [DetailsLayout, DetailsHeader, DetailsOrder], order_id: r[1] }
        }
    }
}