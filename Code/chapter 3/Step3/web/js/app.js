require('!!file-loader?name=[name].[ext]!../index.html')
require('../webflow/webflow.css');
const ReactDOM = require('react-dom')
const React = require("react")
const Qs = require('qs')
const Cookie = require('cookie')
import { Child, Layout, Header, Orders } from './react_components';
import "./http"

const routes = {
    "orders": {
        path: (params) => {
            return "/";
        },
        match: (path, qs) => {
            return (path == "/") && { handlerPath: [Layout, Header, Orders] }
        }
    },
    "order": {
        path: (params) => {
            return "/order/" + params;
        },
        match: (path, qs) => {
            return r && { handlerPath: [Layout, Header, Order], order_id: r[1] }
        }
    }
}

var browserState = { Child }

function onPathChange() {
    var path = location.pathname
    var qs = Qs.parse(location.search.slice(1))
    var cookies = Cookie.parse(document.cookie)
    browserState = {
        ...browserState,
        path: path,
        qs: qs,
        cookie: cookies
    }
    let routeProps = null
    let route = null
    for (var key in routes) {
        routeProps = routes[key].match(path, qs)
        if (routeProps) {
            route = key
            break;
        }
    }
    browserState = {
        ...browserState,
        ...routeProps,
        route: route
    }
    if (!route)
        return ReactDOM.render(<ErrorPage message={"Not Found"} code={404} />, document.getElementById('root'))
    ReactDOM.render(<Child {...browserState} />, document.getElementById('root'))
}

window.onload = () => {
    onPathChange()
    window.addEventListener("popstate", () => onPathChange());
};