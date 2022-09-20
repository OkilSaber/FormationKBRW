const createReactClass = require('create-react-class')
const React = require("react")
const Qs = require('qs')
const Cookie = require('cookie')
import { Child } from './orders_list_components';
import { ErrorPage } from './error_page';
import { routes } from './routes'
import { HTTP } from './http'
require('!!file-loader?name=[name].[ext]!../webflow/orders.html')
require('!!file-loader?name=[name].[ext]!../webflow/order_details.html')
require('!!file-loader?name=[name].[ext]!../webflow/confirm_modal.html')
require('!!file-loader?name=[name].[ext]!../webflow/loader.html')
require('!!file-loader?name=[name].[ext]!../webflow/loader.svg')
require('!!file-loader?name=[name].[ext]!../webflow/logo_kbrw.svg')
require("../webflow/webflow.css")
require("../webflow/modals.css")
var browserState = {}

export default {
    reaxt_server_render(params, render) {
        console.log("reaxt_server_render")
        inferPropsChange(params.path, params.query, params.cookies)
            .then(() => {
                render(<Child {...browserState} />)
            }, (err) => {
                render(<ErrorPage message={"Not Found :" + err.url} code={err.http_code} />, err.http_code)
            })
    },
    reaxt_client_render(initialProps, render) {
        console.log("reaxt_client_render")
        browserState = initialProps
        Link.renderFunc = render
        if (typeof window != 'undefined') {
            window.addEventListener("popstate", () => { Link.onPathChange() })
        }
        Link.onPathChange()
    }
}

function inferPropsChange(path, query, cookies) { // the second part of the onPathChange function have been moved here
    browserState = {
        ...browserState,
        path: path,
        qs: query,
        Link: Link,
        Child: Child
    }

    var route, routeProps
    for (var key in routes) {
        routeProps = routes[key].match(path, query)
        if (routeProps) {
            route = key
            break
        }
    }

    if (!route) {
        return new Promise((res, reject) => reject({ http_code: 404 }))
    }
    browserState = {
        ...browserState,
        ...routeProps,
        route: route
    }

    return addRemoteProps(browserState).then(
        (props) => {
            browserState = props
        })
}

var Link = createReactClass({
    statics: {
        renderFunc: null, //render function to use (differently set depending if we are server sided or client sided)
        GoTo(route, params, query) {// function used to change the path of our browser
            var path = routes[route].path(params)
            var qs = Qs.stringify(query)
            var url = path + (qs == '' ? '' : '?' + qs)
            history.pushState({}, "", url)
            Link.onPathChange()
        },
        onPathChange() { //Updated onPathChange
            var path = location.pathname
            var qs = Qs.parse(location.search.slice(1))
            var cookies = Cookie.parse(document.cookie)
            inferPropsChange(path, qs, cookies).then( //inferPropsChange download the new props if the url query changed as done previously
                () => {
                    Link.renderFunc(<Child {...browserState} />) //if we are on server side we render 
                }, ({ http_code }) => {
                    Link.renderFunc(<ErrorPage message={"Not Found"} code={http_code} />, http_code) //idem
                }
            )
        },
        LinkTo: (route, params, query) => {
            var qs = Qs.stringify(query)
            return routes[route].path(params) + ((qs == '') ? '' : ('?' + qs))
        }
    },
    onClick(ev) {
        ev.preventDefault();
        Link.GoTo(this.props.to, this.props.params, this.props.query);
    },
    render() {//render a <Link> this way transform link into href path which allows on browser without javascript to work perfectly on the website
        return (
            <a href={Link.LinkTo(this.props.to, this.props.params, this.props.query)} onClick={this.onClick}>
                {this.props.children}
            </a>
        )
    }
})

export const formatAddress = ({ street: [street], city, postcode }) => `${street}, ${city} ${postcode}`

export const getQuantity = (items) => items.reduce((accumulator, { quantity_to_fetch }) => (accumulator + quantity_to_fetch), 0)

function addRemoteProps(props) {
    return new Promise((resolve, reject) => {
        var remoteProps = Array.prototype.concat.apply([],
            props.handlerPath
                .map((c) => c.remoteProps)
                .filter((p) => p)
        )
        remoteProps = remoteProps
            .map((spec_fun) => spec_fun(props))
            .filter((specs) => specs)
            .filter((specs) => !props[specs.prop] || props[specs.prop].url != specs.url)
        if (remoteProps.length == 0)
            return resolve(props)
        const promise_mapper = (spec) => {
            return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
        }
        const reducer = (acc, spec) => {
            acc[spec.prop] = { url: spec.url, value: spec.value }
            return acc
        }
        const promise_array = remoteProps.map(promise_mapper)
        return Promise.all(promise_array)
            .then(xs => xs.reduce(reducer, props), reject)
            .then((p) => addRemoteProps(p).then(resolve, reject), reject)
    })
}

export const cn = function () {
    var args = arguments, classes = {}
    for (var i in args) {
        var arg = args[i]
        if (!arg) continue
        if ('string' === typeof arg || 'number' === typeof arg) {
            arg.split(" ").filter((c) => c != "").map((c) => {
                classes[c] = true
            })
        } else if ('object' === typeof arg) {
            for (var key in arg) classes[key] = arg[key]
        }
    }
    return Object.keys(classes).map((k) => classes[k] && k || '').join(' ')
}